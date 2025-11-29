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
    <div class="min-h-screen bg-gradient-to-br from-blue-100 via-white to-purple-100">
      <!-- Background Elements -->
      <div class="absolute inset-0 overflow-hidden">
        <div class="absolute -top-40 -right-40 w-80 h-80 bg-gradient-to-br from-blue-400/20 to-purple-400/20 rounded-full blur-3xl"></div>
        <div class="absolute -bottom-40 -left-40 w-80 h-80 bg-gradient-to-br from-purple-400/20 to-pink-400/20 rounded-full blur-3xl"></div>
      </div>

      <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <!-- Header Section -->
        <div class="text-center mb-12">
          <div class="flex items-center justify-center mb-4">
            <div class="w-16 h-16 bg-gradient-to-br from-blue-600 to-purple-600 rounded-2xl flex items-center justify-center">
              <.icon name="hero-academic-cap" class="w-8 h-8 text-white" />
            </div>
          </div>
          <h1 class="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
            <span class="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-600">Mentorship Management</span>
          </h1>
          <p class="text-xl text-gray-600 max-w-3xl mx-auto">
            Manage mentorship applications from users seeking guidance and support
          </p>
        </div>

        <!-- Stats Overview -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-12">
          <div class="bg-white/80 backdrop-blur-sm rounded-2xl p-6 border border-white/20 shadow-lg">
            <div class="flex items-center">
              <div class="w-12 h-12 bg-amber-100 rounded-xl flex items-center justify-center">
                <.icon name="hero-clock" class="w-6 h-6 text-amber-600" />
              </div>
              <div class="ml-4">
                <p class="text-sm text-gray-600">Pending</p>
                <p class="text-2xl font-bold text-gray-900">{length(@pending_applications)}</p>
              </div>
            </div>
          </div>
          <div class="bg-white/80 backdrop-blur-sm rounded-2xl p-6 border border-white/20 shadow-lg">
            <div class="flex items-center">
              <div class="w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center">
                <.icon name="hero-check-circle" class="w-6 h-6 text-green-600" />
              </div>
              <div class="ml-4">
                <p class="text-sm text-gray-600">Accepted</p>
                <p class="text-2xl font-bold text-gray-900">
                  {Enum.count(@all_mentorships, &(&1.status == "accepted"))}
                </p>
              </div>
            </div>
          </div>
          <div class="bg-white/80 backdrop-blur-sm rounded-2xl p-6 border border-white/20 shadow-lg">
            <div class="flex items-center">
              <div class="w-12 h-12 bg-red-100 rounded-xl flex items-center justify-center">
                <.icon name="hero-x-circle" class="w-6 h-6 text-red-600" />
              </div>
              <div class="ml-4">
                <p class="text-sm text-gray-600">Rejected</p>
                <p class="text-2xl font-bold text-gray-900">
                  {Enum.count(@all_mentorships, &(&1.status == "rejected"))}
                </p>
              </div>
            </div>
          </div>
          <div class="bg-white/80 backdrop-blur-sm rounded-2xl p-6 border border-white/20 shadow-lg">
            <div class="flex items-center">
              <div class="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center">
                <.icon name="hero-users" class="w-6 h-6 text-blue-600" />
              </div>
              <div class="ml-4">
                <p class="text-sm text-gray-600">Total</p>
                <p class="text-2xl font-bold text-gray-900">{length(@all_mentorships)}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Pending Applications -->
        <div class="mb-12">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-2xl font-bold text-gray-900">Pending Applications</h2>
            <div class="flex items-center space-x-2">
              <div class="w-2 h-2 bg-amber-400 rounded-full animate-pulse"></div>
              <span class="text-sm text-gray-600">
                {length(@pending_applications)} awaiting review
              </span>
            </div>
          </div>

          <%= if @pending_applications == [] do %>
            <div class="bg-white/80 backdrop-blur-sm rounded-3xl p-12 text-center border border-white/20 shadow-lg">
              <div class="w-20 h-20 bg-gray-100 rounded-3xl flex items-center justify-center mx-auto mb-6">
                <.icon name="hero-inbox" class="w-10 h-10 text-gray-400" />
              </div>
              <h3 class="text-xl font-bold text-gray-900 mb-3">No Pending Applications</h3>
              <p class="text-gray-600 max-w-md mx-auto">
                All mentorship applications have been reviewed. Check back later for new applications from users seeking guidance.
              </p>
            </div>
          <% else %>
            <div class="space-y-6">
              <%= for mentorship <- @pending_applications do %>
                <div class="bg-white/80 backdrop-blur-sm rounded-2xl p-8 border border-white/20 shadow-lg hover:shadow-xl transition-all duration-300">
                  <div class="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-6">
                    <div class="flex-1">
                      <div class="flex items-center mb-4">
                        <div class="w-12 h-12 bg-gradient-to-br from-amber-500 to-orange-600 rounded-xl flex items-center justify-center">
                          <.icon name="hero-user" class="w-6 h-6 text-white" />
                        </div>
                        <div class="ml-4">
                          <h3 class="text-lg font-bold text-gray-900">
                            From: <%= get_mentee_name(mentorship) %>
                          </h3>
                          <p class="text-sm text-gray-500">
                            Applied: <%= format_date(mentorship.inserted_at) %>
                          </p>
                        </div>
                      </div>

                      <div class="bg-gray-50 rounded-xl p-4 mb-4">
                        <p class="text-gray-700 leading-relaxed">
                          <%= mentorship.message %>
                        </p>
                      </div>
                    </div>

                    <div class="flex-shrink-0">
                      <div class="flex flex-col sm:flex-row gap-3">
                        <button
                          phx-click="accept_application"
                          phx-value-mentorship_id={mentorship.id}
                          class="group inline-flex items-center px-6 py-3 bg-gradient-to-r from-green-600 to-emerald-700 text-white font-semibold rounded-xl shadow-md hover:shadow-lg transition-all duration-300 hover:scale-105"
                        >
                          <.icon name="hero-check-circle" class="w-5 h-5 mr-2 group-hover:scale-110 transition-transform duration-200" />
                          Accept
                        </button>
                        <button
                          phx-click="reject_application"
                          phx-value-mentorship_id={mentorship.id}
                          class="group inline-flex items-center px-6 py-3 bg-gradient-to-r from-red-600 to-red-700 text-white font-semibold rounded-xl shadow-md hover:shadow-lg transition-all duration-300 hover:scale-105"
                        >
                          <.icon name="hero-x-circle" class="w-5 h-5 mr-2 group-hover:scale-110 transition-transform duration-200" />
                          Reject
                        </button>
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
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-2xl font-bold text-gray-900">All Your Mentorships</h2>
            <div class="flex items-center space-x-2">
              <div class="w-2 h-2 bg-blue-400 rounded-full"></div>
              <span class="text-sm text-gray-600">
                {length(@all_mentorships)} total mentorships
              </span>
            </div>
          </div>

          <%= if @all_mentorships == [] do %>
            <div class="bg-white/80 backdrop-blur-sm rounded-3xl p-12 text-center border border-white/20 shadow-lg">
              <div class="w-20 h-20 bg-gray-100 rounded-3xl flex items-center justify-center mx-auto mb-6">
                <.icon name="hero-academic-cap" class="w-10 h-10 text-gray-400" />
              </div>
              <h3 class="text-xl font-bold text-gray-900 mb-3">No Mentorships Yet</h3>
              <p class="text-gray-600 max-w-md mx-auto">
                You haven't established any mentorship relationships yet. Once users apply and you accept their applications, they'll appear here.
              </p>
            </div>
          <% else %>
            <div class="space-y-6">
              <%= for mentorship <- @all_mentorships do %>
                <div class="bg-white/80 backdrop-blur-sm rounded-2xl p-8 border border-white/20 shadow-lg hover:shadow-xl transition-all duration-300">
                  <div class="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-6">
                    <div class="flex-1">
                      <div class="flex items-center mb-4">
                        <div class="w-12 h-12 bg-gradient-to-br from-blue-500 to-purple-600 rounded-xl flex items-center justify-center">
                          <.icon name="hero-user" class="w-6 h-6 text-white" />
                        </div>
                        <div class="ml-4">
                          <h3 class="text-lg font-bold text-gray-900">
                            Mentee: <%= get_mentee_name(mentorship) %>
                          </h3>
                          <p class="text-sm text-gray-500">
                            Applied: <%= format_date(mentorship.inserted_at) %>
                          </p>
                        </div>
                      </div>

                      <div class="bg-gray-50 rounded-xl p-4 mb-4">
                        <p class="text-gray-700 leading-relaxed">
                          <%= mentorship.message %>
                        </p>
                      </div>

                      <%= if mentorship.status == "accepted" do %>
                        <div class="bg-green-50 rounded-xl p-4 border border-green-200">
                          <div class="flex items-center justify-between">
                            <div class="flex items-center">
                              <.icon name="hero-check-circle" class="w-5 h-5 text-green-600 mr-2" />
                              <span class="text-green-800 font-medium">Mentorship Active</span>
                            </div>
                            <div>
                              <%= case get_mentor_chat_id(mentorship) do %>
                                <% nil -> %>
                                  <div class="flex items-center text-green-700">
                                    <.icon name="hero-clock" class="w-4 h-4 mr-1 animate-spin" />
                                    <span class="text-sm">Chat room being created...</span>
                                  </div>
                                <% chat_id -> %>
                                  <.link
                                    navigate={~p"/chat/#{chat_id}"}
                                    class="group inline-flex items-center px-4 py-2 bg-gradient-to-r from-green-600 to-emerald-700 text-white font-semibold rounded-xl shadow-md hover:shadow-lg transition-all duration-300 hover:scale-105"
                                  >
                                    <.icon name="hero-chat-bubble-left-right" class="w-4 h-4 mr-2 group-hover:scale-110 transition-transform duration-200" />
                                    Open Chat
                                  </.link>
                              <% end %>
                            </div>
                          </div>
                        </div>
                      <% end %>
                    </div>

                    <div class="flex-shrink-0">
                      <span class={[
                        "inline-flex items-center px-4 py-2 rounded-full text-sm font-semibold",
                        mentorship.status == "pending" && "bg-amber-100 text-amber-800",
                        mentorship.status == "accepted" && "bg-green-100 text-green-800",
                        mentorship.status == "rejected" && "bg-red-100 text-red-800"
                      ]}>
                        <.icon
                          name={
                            mentorship.status == "pending" && "hero-clock" ||
                            mentorship.status == "accepted" && "hero-check-circle" ||
                            "hero-x-circle"
                          }
                          class="w-4 h-4 mr-2"
                        />
                        <%= String.capitalize(mentorship.status) %>
                      </span>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
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
