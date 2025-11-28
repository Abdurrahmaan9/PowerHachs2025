defmodule MindSanctuary.Posts do
  @moduledoc """
  The Posts context for managing support boards and posts.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias MindSanctuary.Repo

  alias MindSanctuary.Posts.Board
  alias MindSanctuary.Posts.Post
  alias MindSanctuary.Posts.Support
  alias MindSanctuary.Posts.Attachment

  @doc """
  Returns the list of boards.

  ## Examples

      iex> list_boards()
      [%Board{}, ...]

  """
  def list_boards do
    Repo.all(Board |> order_by(asc: :name))
  end

  @doc """
  Gets a single board.

  Raises `Ecto.NoResultsError` if the Board does not exist.

  ## Examples

      iex> get_board!(123)
      %Board{}

      iex> get_board!(456)
      ** (Ecto.NoResultsError)

  """
  def get_board!(id), do: Repo.get!(Board, id)

  @doc """
  Creates a board.

  ## Examples

      iex> create_board(%{field: value})
      {:ok, %Board{}}

      iex> create_board(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_board(attrs \\ %{}) do
    %Board{}
    |> Board.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns the list of posts for a given board, filtered by user role and visibility.

  ## Examples

      iex> list_posts_for_board(board_id, user_role)
      [%Post{}, ...]

  """
  def list_posts_for_board(board_id, user_role \\ "user") do
    Post
    |> where([p], p.board_id == ^board_id)
    |> where([p], p.is_evidence == false)
    |> filter_by_visibility(user_role)
    |> order_by(desc: :inserted_at)
    |> preload([:user, :board, :attachments])
    |> Repo.all()
  end

  @doc """
  Returns the list of evidence posts for admins.

  ## Examples

      iex> list_evidence_posts()
      [%Post{}, ...]

  """
  def list_evidence_posts do
    Post
    |> where([p], p.is_evidence == true)
    |> order_by(desc: :inserted_at)
    |> preload([:user, :board, :attachments])
    |> Repo.all()
  end

  # Private helper to filter posts by visibility based on user role
  defp filter_by_visibility(query, "admin") do
    # Admins can see all posts (admins, admins_volunteers, all)
    query
  end

  defp filter_by_visibility(query, "volunteer") do
    # Volunteers can see posts marked for admins_volunteers and all
    query |> where([p], p.visibility in ["admins_volunteers", "all"])
  end

  defp filter_by_visibility(query, _user_role) do
    # Regular users can only see posts marked as "all"
    query |> where([p], p.visibility == "all")
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    Post
    |> preload([:user, :board, :attachments])
    |> Repo.get!(id)
  end

  @doc """
  Creates a post with optional attachments.

  ## Examples

      iex> create_post_with_attachments(%{field: value}, [])
      {:ok, %Post{}}

      iex> create_post_with_attachments(%{field: value}, [%Plug.Upload{}])
      {:ok, %Post{}}

  """
  def create_post_with_attachments(attrs, uploads \\ []) do
    Repo.transaction(fn ->
      with {:ok, post} <- create_post(attrs) do
        _attachments =
          uploads
          |> Enum.map(fn upload ->
            save_attachment(upload, post.id)
          end)
          |> Enum.filter(fn result ->
            case result do
              {:ok, _} -> true
              {:error, _} -> false
            end
          end)
          |> Enum.map(fn {:ok, attachment} -> attachment end)

        # Reload post with attachments
        post = get_post!(post.id)
        post
      end
    end)
  end

  @doc """
  Saves a file upload as an attachment.

  ## Examples

      iex> save_attachment(%Plug.Upload{}, post_id)
      {:ok, %Attachment{}}

  """
  def save_attachment(upload, post_id) when is_map(upload) do
    # Handle LiveView uploaded file (already saved to disk)
    attachment_attrs = Map.put(upload, :post_id, post_id)

    %Attachment{}
    |> Attachment.changeset(attachment_attrs)
    |> Repo.insert()
  end

  def save_attachment(%Plug.Upload{} = upload, post_id) do
    # Generate unique filename using timestamp
    timestamp = System.system_time(:millisecond)
    filename = "#{timestamp}_#{upload.filename}"

    # Create uploads directory if it doesn't exist
    upload_dir = "priv/static/uploads"
    File.mkdir_p!(upload_dir)

    # Save file to disk
    file_path = Path.join(upload_dir, filename)
    File.copy!(upload.path, file_path)

    # Create attachment record
    attachment_attrs = %{
      filename: filename,
      original_filename: upload.filename,
      content_type: upload.content_type,
      size: upload.path |> File.stat!() |> Map.get(:size),
      path: file_path,
      post_id: post_id
    }

    %Attachment{}
    |> Attachment.changeset(attachment_attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Checks if a user has already supported a post.

  ## Examples

      iex> user_supported_post?(user_id, post_id)
      true

      iex> user_supported_post?(user_id, post_id)
      false

  """
  def user_supported_post?(user_id, post_id) do
    Support
    |> where([s], s.user_id == ^user_id and s.post_id == ^post_id)
    |> Repo.exists?()
  end

  @doc """
  Creates a support for a post and increments the support count.
  Returns error if user has already supported the post.

  ## Examples

      iex> support_post(user_id, post_id)
      {:ok, %Support{}}

      iex> support_post(user_id, post_id)
      {:error, %Ecto.Changeset{}}

  """
  def support_post(user_id, post_id) do
    %Support{}
    |> Support.changeset(%{user_id: user_id, post_id: post_id})
    |> Repo.insert()
    |> case do
      {:ok, support} ->
        # Increment the post's support count
        post = get_post!(post_id)
        {:ok, _updated_post} = increment_support_count(post)
        {:ok, support}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Increments the support count for a post.

  ## Examples

      iex> increment_support_count(post)
      {:ok, %Post{}}

  """
  def increment_support_count(%Post{} = post) do
    post
    |> Ecto.Changeset.change(%{support_count: post.support_count + 1})
    |> Repo.update()
  end
end
