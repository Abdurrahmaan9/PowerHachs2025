defmodule MindSanctuary.Chats.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_messages" do
    field :body, :string
    belongs_to :chat, MindSanctuary.Chats.Chat
    belongs_to :user, MindSanctuary.Accounts.User
    timestamps()
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:body, :chat_id, :user_id])
    |> validate_required([:body, :chat_id, :user_id])
  end
end
