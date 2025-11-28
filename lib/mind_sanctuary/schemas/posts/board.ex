defmodule MindSanctuary.Posts.Board do
  use Ecto.Schema
  import Ecto.Changeset

  schema "boards" do
    field :name, :string
    field :description, :string
    field :category, :string
    field :color, :string, default: "blue"

    has_many :posts, MindSanctuary.Posts.Post

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:name, :description, :category, :color])
    |> validate_required([:name, :description, :category])
    |> validate_length(:name, min: 3, max: 100)
    |> validate_length(:description, min: 10, max: 500)
    |> validate_inclusion(:category, ["domestic_violence", "sexual_assault", "harassment", "stalking", "emotional_abuse", "financial_abuse", "support_resources"])
    |> validate_inclusion(:color, ["blue", "red", "green", "purple", "yellow", "pink", "indigo"])
    |> unique_constraint(:name)
  end
end
