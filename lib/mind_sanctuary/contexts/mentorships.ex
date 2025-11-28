defmodule MindSanctuary.Mentorships do
  @moduledoc """
  The Mentorships context for managing mentorship applications and relationships.
  """

  import Ecto.Query, warn: false
  alias MindSanctuary.Repo

  alias MindSanctuary.Mentorships.Mentorship

  @doc """
  Gets the list of mentorships.
  """
  def list_mentorships do
    Repo.all(Mentorship)
  end

  @doc """
  Gets a single mentorship.
  """
  def get_mentorship!(id), do: Repo.get!(Mentorship, id)

  @doc """
  Creates a mentorship application.
  """
  def create_mentorship_application(attrs) do
    %Mentorship{}
    |> Mentorship.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mentorship.
  """
  def update_mentorship(%Mentorship{} = mentorship, attrs) do
    mentorship
    |> Mentorship.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a mentorship.
  """
  def delete_mentorship(%Mentorship{} = mentorship) do
    Repo.delete(mentorship)
  end

  @doc """
  Gets mentorships for a specific mentee.
  """
  def get_mentorships_for_mentee(mentee_id) do
    Mentorship
    |> where([m], m.mentee_id == ^mentee_id)
    |> Repo.all()
  end

  @doc """
  Gets mentorships for a specific mentor.
  """
  def get_mentorships_for_mentor(mentor_id) do
    Mentorship
    |> where([m], m.mentor_id == ^mentor_id)
    |> Repo.all()
  end

  @doc """
  Gets pending mentorship applications for a mentor.
  """
  def get_pending_applications_for_mentor(mentor_id) do
    Mentorship
    |> where([m], m.mentor_id == ^mentor_id and m.status == "pending")
    |> Repo.all()
  end

  @doc """
  Gets available mentors (users with admin or volunteer role).
  """
  def get_available_mentors do
    alias MindSanctuary.Accounts.User

    User
    |> where([u], u.role in ["admin", "volunteer"])
    |> select([u], %{id: u.id, username: u.username, role: u.role})
    |> Repo.all()
  end

  @doc """
  Changeset for creating a mentorship application.
  """
  def change_mentorship_application(%Mentorship{} = mentorship, attrs \\ %{}) do
    Mentorship.changeset(mentorship, attrs)
  end
end
