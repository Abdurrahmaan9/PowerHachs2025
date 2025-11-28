# lib/mind_sanctuary_web/live/chat_live/index.ex
defmodule MindSanctuaryWeb.ChatLive.Index do
  use MindSanctuaryWeb, :live_view
  alias MindSanctuary.{Chats, Accounts}
  alias MindSanctuary.Chats.{ChatUser}

  @impl true
  def mount(params, _session, socket) do
    user_id = socket.assigns.current_scope.user.id

    {:ok,
     socket
     |> assign(:messages, [])
     |> assign(:message_body, "")
     |> assign(:user_chats, Chats.list_user_chats(user_id))
     |> assign(:new_chat, false)
     |> assign(:show_mobile_sidebar, false)
     |> get_live_action(socket.assigns.live_action, params)
     |> assign(:chat_changeset, to_form(Chats.private_chat_changeset(%ChatUser{}, %{})))}
  end

  defp get_live_action(socket, :index, _params) do
    socket
    |> assign(:live_action, :index)
    |> assign(:chat_id, nil)
    |> assign(:public_tab_active?, true)
    |> push_event("join_channel", %{topic: "room:public"})
  end

  defp get_live_action(socket, :private, params) do
    %{"id" => chat_id} = params
    user_id = socket.assigns.current_scope.user.id

    # Verify access
    if Chats.user_has_access?(chat_id, user_id) do
      socket
      |> assign(:live_action, :private)
      |> assign(:chat_id, chat_id)
    |> assign(:public_tab_active?, false)
      |> push_event("join_channel", %{topic: "room:private:#{chat_id}"})
    else
      socket
      |> put_flash(:error, "Access denied")
      |> push_navigate(to: ~p"/chat")
    end
  end

  # @impl true
  # def handle_params(%{"id" => chat_id}, _uri, socket) do

  #   # Verify access
  #   if Chats.user_has_access?(chat_id, user_id) do
  #     {:noreply,
  #      socket
  #      |> assign(:live_action, :private)
  #      |> assign(:chat_id, chat_id)
  #      |> push_event("join_channel", %{topic: "room:private:#{chat_id}"})}
  #   else
  #     {:noreply,
  #      socket
  #      |> put_flash(:error, "Access denied")
  #      |> push_navigate(to: ~p"/chat")}
  #   end
  # end

  # def handle_params(_params, _uri, socket) do
  #   {:noreply,
  #    socket
  #    |> assign(:live_action, :index)
  #    |> assign(:chat_id, nil)
  #    |> push_event("join_channel", %{topic: "room:public"})}
  # end

  @impl true
  def handle_event("send_message", %{"message" => %{"body" => _body}}, socket) do
    # Message will be sent via JavaScript hook
    {:noreply, assign(socket, :message_body, "")}
  end

  def handle_event("new_message", message, socket) do
    {:noreply, update(socket, :messages, fn messages -> messages ++ [message] end)}
  end

  def handle_event("load_messages", %{"messages" => messages}, socket) do
    {:noreply, assign(socket, :messages, messages)}
  end

  def handle_event("create_new_chat", _params, socket) do
    {:noreply, assign(socket, :new_chat, true)}
  end

  def handle_event("cancel_new_chat", _params, socket) do
    {:noreply, assign(socket, :new_chat, false)}
  end

  def handle_event("switch_tab", _params, socket) do
    {:noreply, assign(socket, :public_tab_active?, !socket.assigns.public_tab_active?)}
  end

  def handle_event("start_chat", %{"chat_user" => %{"user_id" => other_user_id}}, socket) do
    current_user = socket.assigns.current_scope.user
    other_user_id_filter = String.to_integer(other_user_id)

    selected_user =
      Enum.find(Accounts.users_select_id_list(), fn
        {_display_name, user_id} when user_id == other_user_id_filter -> true
        _ -> false
      end)

    chat_name =
      case selected_user do
        {display_name, ^other_user_id_filter} ->
          [username_part | _] = String.split(display_name, " - ")
          "#{username_part}, #{current_user.username}"

        nil ->
          "Champ #{other_user_id}, #{current_user.username}"
      end

    case Chats.get_or_create_private_chat(current_user.id, other_user_id, chat_name) do
      {:ok, chat} ->
        {:noreply, push_navigate(socket, to: ~p"/chat/#{chat.id}")}

      {:error, :cannot_chat_with_self} ->
        {:noreply, put_flash(socket, :error, "You cannot chat with yourself")}
    end
  end

  # Add this event handler
  def handle_event("toggle_mobile_sidebar", _params, socket) do
    {:noreply, assign(socket, show_mobile_sidebar: !socket.assigns.show_mobile_sidebar)}
  end
end
