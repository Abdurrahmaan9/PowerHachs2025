defmodule MindSanctuary.Mood do
  @moduledoc """
  The Mood context.
  """

  import Ecto.Query, warn: false
  alias MindSanctuary.Repo

  alias MindSanctuary.Mood.Entry
  alias MindSanctuary.Accounts.User

  @doc """
  Returns the list of mood entries for a user.

  ## Examples

      iex> list_entries(user)
      [%Entry{}, ...]

  """
  def list_entries(%User{} = user) do
    Entry
    |> where(user_id: ^user.id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single entry.

  Raises `Ecto.NoResultsError` if the Entry does not exist.

  ## Examples

      iex> get_entry!(123)
      %Entry{}

      iex> get_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_entry!(id), do: Repo.get!(Entry, id)

  @doc """
  Gets a single entry for a specific user.
  Returns nil if the entry doesn't exist or doesn't belong to the user.
  """
  def get_user_entry(%User{} = user, id) do
    Entry
    |> where(id: ^id, user_id: ^user.id)
    |> Repo.one()
  end

  @doc """
  Creates a mood entry.

  ## Examples

      iex> create_entry(user, %{field: value})
      {:ok, %Entry{}}

      iex> create_entry(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_entry(%User{} = user, attrs \\ %{}) do
    %Entry{}
    |> Entry.changeset(Map.put(attrs, "user_id", user.id))
    |> Repo.insert()
  end

  @doc """
  Updates a entry.

  ## Examples

      iex> update_entry(entry, %{field: new_value})
      {:ok, %Entry{}}

      iex> update_entry(entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_entry(%Entry{} = entry, attrs) do
    entry
    |> Entry.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a entry.

  ## Examples

      iex> delete_entry(entry)
      {:ok, %Entry{}}

      iex> delete_entry(entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_entry(%Entry{} = entry) do
    Repo.delete(entry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking entry changes.

  ## Examples

      iex> change_entry(entry)
      %Ecto.Changeset{data: %Entry{}}

  """
  def change_entry(%Entry{} = entry, attrs \\ %{}) do
    Entry.changeset(entry, attrs)
  end

  @doc """
  Gets the most recent entry for a user.
  """
  def get_latest_entry(%User{} = user) do
    Entry
    |> where(user_id: ^user.id)
    |> order_by(desc: :inserted_at)
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Gets entries for a user within a date range.
  """
  def get_entries_in_range(%User{} = user, start_date, end_date) do
    Entry
    |> where(user_id: ^user.id)
    |> where([e], e.inserted_at >= ^start_date and e.inserted_at <= ^end_date)
    |> order_by(asc: :inserted_at)
    |> Repo.all()
  end
end
