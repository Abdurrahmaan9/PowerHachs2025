defmodule MindSanctuary.Mentorships.Mentorship do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mentorships" do
    field :status, :string, default: "pending"
    field :message, :string
    field :accepted_at, :utc_datetime
    field :rejected_at, :utc_datetime

    belongs_to :mentee, MindSanctuary.Accounts.User
    belongs_to :mentor, MindSanctuary.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(mentorship, attrs) do
    mentorship
    |> cast(attrs, [:status, :message, :accepted_at, :rejected_at, :mentee_id, :mentor_id])
    |> validate_required([:mentee_id, :mentor_id, :message])
    |> validate_inclusion(:status, ["pending", "accepted", "rejected", "completed", "cancelled"])
    |> validate_mentee_not_mentor()
    |> unique_constraint([:mentee_id, :mentor_id], name: :unique_mentor_mentee_pair)
  end

  defp validate_mentee_not_mentor(changeset) do
    mentee_id = get_field(changeset, :mentee_id)
    mentor_id = get_field(changeset, :mentor_id)

    if mentee_id && mentor_id && mentee_id == mentor_id do
      add_error(changeset, :mentee_id, "cannot be the same as mentor")
    else
      changeset
    end
  end
end
