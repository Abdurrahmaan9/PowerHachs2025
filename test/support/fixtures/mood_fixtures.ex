defmodule MindSanctuary.MoodFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MindSanctuary.Mood` context.
  """

  alias MindSanctuary.Mood
  alias MindSanctuary.Accounts.User

  @doc """
  Generate a entry.
  """
  def entry_fixture(%User{} = user, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        mood: "happy",
        journal_entry: "some journal entry",
        energy_level: 8,
        stress_level: 3,
        sleep_hours: 7.5
      })

    {:ok, entry} = Mood.create_entry(user, attrs)

    entry
  end
end
