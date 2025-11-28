defmodule MindSanctuary.Chats.ChatUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_users" do
    belongs_to :chat, MindSanctuary.Chats.Chat
    belongs_to :user, MindSanctuary.Accounts.User

    timestamps()
  end

  def changeset(chat_user, attrs) do
    chat_user
    |> cast(attrs, [:chat_id, :user_id])
    |> validate_required([:chat_id, :user_id])
    |> unique_constraint([:chat_id, :user_id])
  end
end
