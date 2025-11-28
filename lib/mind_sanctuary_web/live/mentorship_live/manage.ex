defmodule MindSanctuaryWeb.MentorshipLive.Manage do
  use MindSanctuaryWeb, :live_view

  import Ecto.Query
  alias MindSanctuary.Repo
  alias MindSanctuary.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_scope.user

    # Only allow admins and volunteers to access this page
    if current_user.role in ["admin", "volunteer"] do
      pending_applications = MindSanctuary.Mentorships.get_pending_applications_for_mentor(current_user.id)
      all_mentorships = MindSanctuary.Mentorships.get_mentorships_for_mentor(current_user.id)

      {:ok,
       socket
       |> assign(:current_user, current_user)
       |> assign(:pending_applications, pending_applications)
       |> assign(:all_mentorships, all_mentorships)}
    else
      {:noreply,
       socket
       |> put_flash(:error, "Access denied. Only admins and volunteers can manage mentorships.")
       |> redirect(to: ~p"/dashboard")}
    end
  end

  @impl true
  def handle_params(params, url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Mentorship Management")
  end

  @impl true
  def handle_event("accept_application", %{"mentorship_id" => mentorship_id}, socket) do
    current_user = socket.assigns.current_user

    case MindSanctuary.Mentorships.get_mentorship!(mentorship_id) do
      mentorship ->
        if mentorship.mentor_id == current_user.id do
          case MindSanctuary.Mentorships.update_mentorship(mentorship, %{
            "status" => "accepted",
            "accepted_at" => DateTime.utc_now()
          }) do
            {:ok, _updated_mentorship} ->
              # Create a private chat room for mentor and mentee
              IO.puts("Creating mentorship chat between mentor #{mentorship.mentor_id} and mentee #{mentorship.mentee_id}")

              case MindSanctuary.Chats.get_or_create_private_chat(
                mentorship.mentor_id,
                mentorship.mentee_id,
                "Mentor"
              ) do
                {:ok, chat} ->
                  # Chat created successfully
                  IO.puts("Successfully created mentorship chat with ID: #{chat.id}")

                {:error, reason} ->
                  # Log error but don't fail the mentorship acceptance
                  IO.puts("Failed to create mentorship chat: #{inspect(reason)}")
              end

              # Refresh the applications
              pending_applications = MindSanctuary.Mentorships.get_pending_applications_for_mentor(current_user.id)
              all_mentorships = MindSanctuary.Mentorships.get_mentorships_for_mentor(current_user.id)

              {:noreply,
               socket
               |> assign(:pending_applications, pending_applications)
               |> assign(:all_mentorships, all_mentorships)
               |> put_flash(:info, "Mentorship application accepted! A private chat room has been created.")}

            {:error, _changeset} ->
              {:noreply,
               socket
               |> put_flash(:error, "Failed to accept application.")}
          end
        else
          {:noreply,
           socket
           |> put_flash(:error, "Access denied.")}
        end

      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Application not found.")}
    end
  end

  @impl true
  def handle_event("reject_application", %{"mentorship_id" => mentorship_id}, socket) do
    current_user = socket.assigns.current_user

    case MindSanctuary.Mentorships.get_mentorship!(mentorship_id) do
      mentorship ->
        if mentorship.mentor_id == current_user.id do
          case MindSanctuary.Mentorships.update_mentorship(mentorship, %{
            "status" => "rejected",
            "rejected_at" => DateTime.utc_now()
          }) do
            {:ok, _updated_mentorship} ->
              # Refresh the applications
              pending_applications = MindSanctuary.Mentorships.get_pending_applications_for_mentor(current_user.id)
              all_mentorships = MindSanctuary.Mentorships.get_mentorships_for_mentor(current_user.id)

              {:noreply,
               socket
               |> assign(:pending_applications, pending_applications)
               |> assign(:all_mentorships, all_mentorships)
               |> put_flash(:info, "Mentorship application rejected.")}

            {:error, _changeset} ->
              {:noreply,
               socket
               |> put_flash(:error, "Failed to reject application.")}
          end
        else
          {:noreply,
           socket
           |> put_flash(:error, "Access denied.")}
        end

      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Application not found.")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={%{user: @current_user}}>
      <div class="max-w-4xl mx-auto px-4 py-8">
        <.header>
          Mentorship Management
          <:subtitle>Manage mentorship applications from users seeking guidance</:subtitle>
        </.header>

        <!-- Pending Applications -->
        <div class="mb-8">
          <h2 class="text-xl font-semibold text-gray-900 mb-4">Pending Applications</h2>

          <%= if @pending_applications == [] do %>
            <div class="bg-gray-50 rounded-lg p-6 text-center">
              <p class="text-gray-600">No pending applications at the moment.</p>
            </div>
          <% else %>
            <div class="space-y-4">
              <%= for mentorship <- @pending_applications do %>
                <div class="bg-white shadow rounded-lg p-6">
                  <div class="flex justify-between items-start">
                    <div class="flex-1">
                      <h3 class="font-medium text-gray-900">
                        From: <%= get_mentee_name(mentorship) %>
                      </h3>
                      <p class="text-sm text-gray-600 mt-1">
                        Applied: <%= format_date(mentorship.inserted_at) %>
                      </p>
                      <p class="text-sm text-gray-700 mt-2">
                        <%= mentorship.message %>
                      </p>
                    </div>
                    <div class="flex-shrink-0 ml-4">
                      <div class="flex space-x-2">
                        <.button
                          phx-click="accept_application"
                          phx-value-mentorship_id={mentorship.id}
                          class="bg-green-600 text-white px-3 py-1 rounded text-sm hover:bg-green-700"
                        >
                          Accept
                        </.button>
                        <.button
                          phx-click="reject_application"
                          phx-value-mentorship_id={mentorship.id}
                          class="bg-red-600 text-white px-3 py-1 rounded text-sm hover:bg-red-700"
                        >
                          Reject
                        </.button>
                      </div>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>

        <!-- All Mentorships -->
        <div>
          <h2 class="text-xl font-semibold text-gray-900 mb-4">All Your Mentorships</h2>

          <%= if @all_mentorships == [] do %>
            <div class="bg-gray-50 rounded-lg p-6 text-center">
              <p class="text-gray-600">You don't have any mentorships yet.</p>
            </div>
          <% else %>
            <div class="space-y-4">
              <%= for mentorship <- @all_mentorships do %>
                <div class="bg-white shadow rounded-lg p-6">
                  <div class="flex justify-between items-start">
                    <div>
                      <h3 class="font-medium text-gray-900">
                        Mentee: <%= get_mentee_name(mentorship) %>
                      </h3>
                      <p class="text-sm text-gray-600 mt-1">
                        Applied: <%= format_date(mentorship.inserted_at) %>
                      </p>
                      <p class="text-sm text-gray-700 mt-2">
                        <%= mentorship.message %>
                      </p>
                      <%= if mentorship.status == "accepted" do %>
                        <div class="mt-3">
                          <%= case get_mentor_chat_id(mentorship) do %>
                            <% nil -> %>
                              <span class="text-sm text-gray-500">
                                Chat room being created...
                              </span>
                            <% chat_id -> %>
                              <.link
                                navigate={~p"/chat/#{chat_id}"}
                                class="inline-flex items-center px-3 py-1 border border-transparent text-sm leading-4 font-medium rounded-md text-indigo-600 bg-indigo-100 hover:bg-indigo-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                              >
                                <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/>
                                </svg>
                                Open Chat
                              </.link>
                          <% end %>
                        </div>
                      <% end %>
                    </div>
                    <div class="flex-shrink-0">
                      <div class="flex flex-col items-end space-y-2">
                        <span class={[
                          "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium",
                          mentorship.status == "pending" && "bg-yellow-100 text-yellow-800",
                          mentorship.status == "accepted" && "bg-green-100 text-green-800",
                          mentorship.status == "rejected" && "bg-red-100 text-red-800"
                        ]}>
                          <%= String.capitalize(mentorship.status) %>
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp get_mentee_name(mentorship) do
    case Repo.get(User, mentorship.mentee_id) do
      nil -> "Unknown User"
      user -> user.username
    end
  end

  defp get_mentor_chat_id(mentorship) do
    # Get all private chats for the mentor and find the one with the mentee titled "Mentor"
    IO.puts("Looking for mentor chat between mentor #{mentorship.mentor_id} and mentee #{mentorship.mentee_id}")

    case MindSanctuary.Chats.list_user_chats(mentorship.mentor_id) do
      chats when is_list(chats) ->
        IO.puts("Found #{length(chats)} chats for mentor")

        result = Enum.find_value(chats, fn chat ->
          IO.puts("Checking chat: #{chat.title} (ID: #{chat.id})")

          if chat.title == "Mentor" do
            # Check if this chat includes the mentee
            mentee_in_chat = case chat.users do
              nil ->
                IO.puts("Chat users is nil")
                false
              users when is_list(users) ->
                user_ids = Enum.map(users, & &1.id)
                IO.puts("Chat users: #{inspect(user_ids)}")
                mentee_in = Enum.any?(users, fn user -> user.id == mentorship.mentee_id end)
                IO.puts("Mentee #{mentorship.mentee_id} in chat: #{mentee_in}")
                mentee_in
              _ ->
                IO.puts("Chat users is not a list")
                false
            end
            if mentee_in_chat, do: chat.id, else: nil
          else
            nil
          end
        end)

        IO.puts("Final result: #{inspect(result)}")
        result

      _ ->
        # Handle case where list_user_chats returns something unexpected
        IO.puts("list_user_chats returned unexpected value")
        nil
    end
  end

  defp format_date(datetime) do
    Calendar.strftime(datetime, "%B %d, %Y")
  end
end
