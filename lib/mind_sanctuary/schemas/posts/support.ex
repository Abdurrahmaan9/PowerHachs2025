defmodule MindSanctuary.Posts.Support do
  use Ecto.Schema
  import Ecto.Changeset

  schema "supports" do
    belongs_to :post, MindSanctuary.Posts.Post
    belongs_to :user, MindSanctuary.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(support, attrs) do
    support
    |> cast(attrs, [:post_id, :user_id])
    |> validate_required([:post_id, :user_id])
    |> unique_constraint([:post_id, :user_id], name: :supports_post_id_user_id_index)
    |> assoc_constraint(:post)
    |> assoc_constraint(:user)
  end
end
