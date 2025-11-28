defmodule MindSanctuary.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field :title, :string
    field :type, :string, default: "private"
    many_to_many :users, MindSanctuary.Accounts.User, join_through: "chat_users"
    has_many :messages, MindSanctuary.Chats.Message
    timestamps()
  end

  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:title, :type])
    |> validate_required([:title, :type])
  end
end
