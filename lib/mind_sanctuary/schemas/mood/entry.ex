defmodule MindSanctuary.Mood.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mood_entries" do
    field :mood, :string
    field :journal_entry, :string
    field :energy_level, :integer
    field :stress_level, :integer
    field :sleep_hours, :float
    belongs_to :user, MindSanctuary.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:mood, :journal_entry, :energy_level, :stress_level, :sleep_hours, :user_id])
    |> validate_required([:mood, :user_id])
    |> validate_inclusion(:mood, ["happy", "calm", "neutral", "sad", "anxious", "angry", "tired"])
    |> validate_number(:energy_level,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 10,
      message: "must be between 1 and 10"
    )
    |> validate_number(:stress_level,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 10,
      message: "must be between 1 and 10"
    )
    |> validate_number(:sleep_hours,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 24,
      message: "must be between 0 and 24"
    )
    |> foreign_key_constraint(:user_id)
  end
end
