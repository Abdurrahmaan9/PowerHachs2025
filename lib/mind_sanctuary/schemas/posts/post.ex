defmodule MindSanctuary.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :content, :string
    field :anonymous, :boolean, default: true
    field :support_count, :integer, default: 0
    field :visibility, :string, default: "all"
    field :is_evidence, :boolean, default: false

    belongs_to :board, MindSanctuary.Posts.Board
    belongs_to :user, MindSanctuary.Accounts.User
    has_many :attachments, MindSanctuary.Posts.Attachment

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content, :anonymous, :support_count, :board_id, :user_id, :visibility, :is_evidence])
    |> validate_required([:title, :content, :board_id, :user_id, :visibility])
    |> validate_length(:title, min: 5, max: 200)
    |> validate_length(:content, min: 20, max: 2000)
    |> validate_number(:support_count, greater_than_or_equal_to: 0)
    |> validate_inclusion(:visibility, ["all", "admins_volunteers", "admins"])
    |> assoc_constraint(:board)
    |> assoc_constraint(:user)
  end
end
