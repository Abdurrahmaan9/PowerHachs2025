defmodule MindSanctuary.Posts.Attachment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "attachments" do
    field :filename, :string
    field :original_filename, :string
    field :content_type, :string
    field :size, :integer
    field :path, :string

    belongs_to :post, MindSanctuary.Posts.Post

    timestamps()
  end

  @doc false
  def changeset(attachment, attrs) do
    attachment
    |> cast(attrs, [:filename, :original_filename, :content_type, :size, :path, :post_id])
    |> validate_required([:filename, :original_filename, :content_type, :size, :path, :post_id])
    |> validate_number(:size, greater_than: 0)
    |> assoc_constraint(:post)
  end
end
