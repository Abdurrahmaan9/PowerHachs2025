defmodule MindSanctuary.Chats do
  import Ecto.Query
  alias MindSanctuary.Repo
  alias MindSanctuary.Chats.{Chat, Message, ChatUser}

  def list_public_messages(opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)

    Message
    |> where([m], m.chat_id == 1)
    |> order_by([m], desc: m.inserted_at)
    |> limit(^limit)
    |> preload(:user)
    |> Repo.all()
    |> Enum.reverse()
  end

  def list_chat_messages(chat_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)

    Message
    |> where([m], m.chat_id == ^chat_id)
    |> order_by([m], desc: m.inserted_at)
    |> limit(^limit)
    |> preload(:user)
    |> Repo.all()
    |> Enum.reverse()
  end

  def create_message(attrs) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  def preload_message(message) do
    Repo.preload(message, :user)
  end

  def user_has_access?(chat_id, user_id) do
    query =
      from cu in ChatUser,
        where: cu.chat_id == ^chat_id and cu.user_id == ^user_id

    Repo.exists?(query)
  end

  def list_user_chats(user_id) do
    query =
      from c in Chat,
        join: cu in ChatUser,
        on: cu.chat_id == c.id,
        where: cu.user_id == ^user_id and c.type == "private",
        preload: [messages: :user],
        order_by: [desc: c.updated_at]

    Repo.all(query)
  end

  def get_or_create_private_chat(user_id, other_user_id, chat_name \\ "Private Chat") do
    if user_id == other_user_id do
      {:error, :cannot_chat_with_self}
    else
      case find_private_chat_between_users(user_id, other_user_id, chat_name) do
        nil -> create_private_chat([user_id, other_user_id], chat_name)
        chat -> {:ok, chat}
      end
    end
  end

  def private_chat_changeset(%ChatUser{} = chat, attr \\ %{}) do
    chat
    |> ChatUser.changeset(attr)
    # Repo.transaction(fn ->
    #   chat = Repo.insert!(%Chat{title: "Private Chat", type: "private"})

    #   Enum.each(user_ids, fn user_id ->
    #     Repo.insert!(%ChatUser{chat_id: chat.id, user_id: user_id})
    #   end)

    #   chat
    # end)
  end

  defp find_private_chat_between_users(user_id, other_user_id, chat_name) do
    # Subquery to find chats with exactly 2 participants
    chats_with_two_users =
      from(cu in ChatUser,
        group_by: cu.chat_id,
        having: count(cu.user_id) == 2,
        select: cu.chat_id
      )

    # Find private chat where both users are participants
    from(c in Chat,
      join: cu1 in ChatUser,
      on: cu1.chat_id == c.id and cu1.user_id == ^user_id,
      join: cu2 in ChatUser,
      on: cu2.chat_id == c.id and cu2.user_id == ^other_user_id,
      where: c.type == "private",
      where: c.title == ^chat_name,
      where: c.id in subquery(chats_with_two_users),
      select: c,
      limit: 1
    )
    |> Repo.one()
  end

  defp create_private_chat(user_ids, chat_name) do
    Repo.transaction(fn ->
      chat = Repo.insert!(%Chat{title: chat_name, type: "private"})

      Enum.each(user_ids, fn user_id ->
        [chat.id, user_id] |>IO.inspect(label: "===")
        user_id =
          if is_binary(user_id) do
            String.to_integer(user_id)
          else
            user_id
        end
        Repo.insert!(%ChatUser{chat_id: chat.id, user_id: user_id})
      end)

      chat
    end)
  end
end
