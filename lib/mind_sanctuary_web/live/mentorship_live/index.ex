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
