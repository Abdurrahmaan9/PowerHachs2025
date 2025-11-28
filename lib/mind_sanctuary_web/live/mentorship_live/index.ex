defmodule MindSanctuaryWeb.MentorshipLive.Index do
  use MindSanctuaryWeb, :live_view

  import Ecto.Query
  alias MindSanctuary.Repo
  alias MindSanctuary.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_scope.user
    available_mentors = MindSanctuary.Mentorships.get_available_mentors()
    user_mentorships = MindSanctuary.Mentorships.get_mentorships_for_mentee(current_user.id)

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:available_mentors, available_mentors)
     |> assign(:user_mentorships, user_mentorships)
     |> assign(:form, to_form(MindSanctuary.Mentorships.change_mentorship_application(%MindSanctuary.Mentorships.Mentorship{})))}
  end

  @impl true
  def handle_params(params, url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Mentorship Program")
  end

  @impl true
  def handle_event("apply_mentorship", %{"mentorship" => mentorship_params}, socket) do
    current_user = socket.assigns.current_user

    # Add the current user as mentee
    mentorship_params = Map.put(mentorship_params, "mentee_id", current_user.id)

    case MindSanctuary.Mentorships.create_mentorship_application(mentorship_params) do
      {:ok, _mentorship} ->
        # Refresh the mentorships list
        user_mentorships = MindSanctuary.Mentorships.get_mentorships_for_mentee(current_user.id)

        {:noreply,
         socket
         |> assign(:user_mentorships, user_mentorships)
         |> put_flash(:info, "Your mentorship application has been submitted successfully!")
         |> push_patch(to: ~p"/mentorship")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset))
         |> put_flash(:error, "There was an error submitting your application.")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={%{user: @current_user}}>
      <div class="max-w-4xl mx-auto px-4 py-8">
        <.header>
          Mentorship Program
          <:subtitle>Connect with experienced mentors for guidance and support</:subtitle>
        </.header>

        <!-- Current Mentorships -->
        <div class="mb-8">
          <h2 class="text-xl font-semibold text-gray-900 mb-4">Your Mentorship Applications</h2>

          <%= if @user_mentorships == [] do %>
            <div class="bg-gray-50 rounded-lg p-6 text-center">
              <p class="text-gray-600">You haven't applied for any mentorships yet.</p>
            </div>
          <% else %>
            <div class="space-y-4">
              <%= for mentorship <- @user_mentorships do %>
                <div class="bg-white shadow rounded-lg p-6">
                  <div class="flex justify-between items-start">
                    <div>
                      <h3 class="font-medium text-gray-900">
                        Mentor: <%= get_mentor_name(mentorship) %>
                      </h3>
                      <p class="text-sm text-gray-600 mt-1">
                        Applied: <%= format_date(mentorship.inserted_at) %>
                      </p>
                      <p class="text-sm text-gray-700 mt-2">
                        <%= mentorship.message %>
                      </p>
                    </div>
                    <div class="flex-shrink-0">
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
              <% end %>
            </div>
          <% end %>
        </div>

        <!-- Apply for Mentorship -->
        <div class="bg-white shadow rounded-lg p-6">
          <h2 class="text-xl font-semibold text-gray-900 mb-4">Apply for Mentorship</h2>

          <.simple_form for={@form} phx-submit="apply_mentorship">
            <.input
              field={@form[:mentor_id]}
              type="select"
              label="Select a Mentor"
              options={mentor_options(@available_mentors)}
              prompt="Choose a mentor..."
            />

            <.input
              field={@form[:message]}
              type="textarea"
              label="Why do you want mentorship?"
              placeholder="Tell us about yourself and what you hope to gain from mentorship..."
              rows="4"
            />

            <:actions>
              <.button phx-disable-with="Submitting...">
                Apply for Mentorship
              </.button>
            </:actions>
          </.simple_form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp mentor_options(mentors) do
    Enum.map(mentors, fn mentor ->
      {"#{mentor.username} (#{mentor.role})", mentor.id}
    end)
  end

  defp get_mentor_name(mentorship) do
    # This would ideally be preloaded, but for now we'll use a simple approach
    case Repo.get(User, mentorship.mentor_id) do
      nil -> "Unknown Mentor"
      user -> user.username
    end
  end

  defp format_date(datetime) do
    Calendar.strftime(datetime, "%B %d, %Y")
  end
end
