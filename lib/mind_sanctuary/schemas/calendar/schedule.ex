defmodule MindSanctuary.Calendar.Schedule do
  use Ecto.Schema
  import Ecto.Changeset

  schema "schedules" do
    field :title, :string
    field :description, :string
    field :starts_at, :naive_datetime
    field :ends_at, :naive_datetime
    belongs_to :user, MindSanctuary.Accounts.User

    timestamps()
  end

  def changeset(schedule, attrs) do
    schedule
    |> cast(attrs, [:title, :description, :starts_at, :ends_at])
    |> validate_required([:title, :starts_at])
    |> validate_end_after_start()
  end

  defp validate_end_after_start(changeset) do
    s = get_field(changeset, :starts_at)
    e = get_field(changeset, :ends_at)

    cond do
      is_nil(s) or is_nil(e) -> changeset
      NaiveDateTime.compare(e, s) in [:gt, :eq] -> changeset
      true -> add_error(changeset, :ends_at, "must be after or equal to start time")
    end
  end
end
