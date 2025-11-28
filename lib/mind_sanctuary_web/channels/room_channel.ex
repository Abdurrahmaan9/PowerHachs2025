defmodule MindSanctuaryWeb.RoomChannel do
  use MindSanctuaryWeb, :channel

  alias MindSanctuary.Chats, as: Chat

  @impl true
  def join("room:public", _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def join("room:private:" <> chat_id, _payload, socket) do
    user_id = socket.assigns.user_id

    # Verify user has access to this private chat
    case Chat.user_has_access?(chat_id, user_id) do
      true ->
        send(self(), {:after_join_private, chat_id})
        {:ok, assign(socket, :chat_id, chat_id)}
      false ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_info(:after_join, socket) do
    # Load recent public messages
    messages = Chat.list_public_messages(limit: 50)
    push(socket, "presence_state", %{})
    push(socket, "messages", %{messages: format_messages(messages)})
    {:noreply, socket}
  end

  def handle_info({:after_join_private, chat_id}, socket) do
    # Load recent private messages
    messages = Chat.list_chat_messages(chat_id, limit: 50)
    push(socket, "messages", %{messages: format_messages(messages)})
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_msg", %{"body" => body}, socket) do
    user_id = socket.assigns.user_id

    case socket.assigns[:chat_id] do
      nil ->
        # Public chat (chat_id = 1)
        handle_public_message(body, user_id, socket)
      chat_id ->
        # Private chat
        handle_private_message(body, user_id, chat_id, socket)
    end
  end

  defp handle_public_message(body, user_id, socket) do
    case Chat.create_message(%{body: body, user_id: user_id, chat_id: 1}) do
      {:ok, message} ->
        message = Chat.preload_message(message)
        broadcast!(socket, "new_msg", format_message(message))
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  defp handle_private_message(body, user_id, chat_id, socket) do
    case Chat.create_message(%{body: body, user_id: user_id, chat_id: chat_id}) do
      {:ok, message} ->
        message = Chat.preload_message(message)
        broadcast!(socket, "new_msg", format_message(message))
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  defp format_messages(messages) do
    Enum.map(messages, &format_message/1)
  end

  defp format_message(message) do
    %{
      id: message.id,
      body: message.body,
      user: %{
        id: message.user.id,
        username: message.user.username || message.user.email
      },
      inserted_at: message.inserted_at
    }
  end
end
