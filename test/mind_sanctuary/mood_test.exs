defmodule MindSanctuary.MoodTest do
  use MindSanctuary.DataCase

  alias MindSanctuary.Mood
  alias MindSanctuary.AccountsFixtures

  describe "entries" do
    alias MindSanctuary.Mood.Entry

    @valid_attrs %{
      mood: "happy",
      journal_entry: "some journal entry",
      energy_level: 8,
      stress_level: 3,
      sleep_hours: 7.5
    }
    @update_attrs %{
      mood: "calm",
      journal_entry: "updated journal entry",
      energy_level: 6,
      stress_level: 4,
      sleep_hours: 8.0
    }
    @invalid_attrs %{mood: nil, journal_entry: nil, user_id: nil}

    setup do
      user = AccountsFixtures.user_fixture()
      %{user: user}
    end

    test "list_entries/1 returns all entries for a user", %{user: user} do
      {:ok, entry} = Mood.create_entry(user, @valid_attrs)
      assert Mood.list_entries(user) == [entry]
    end

    test "get_entry!/1 returns the entry with given id", %{user: user} do
      {:ok, entry} = Mood.create_entry(user, @valid_attrs)
      assert Mood.get_entry!(entry.id) == entry
    end

    test "get_user_entry/2 returns the entry with given id for a user", %{user: user} do
      {:ok, entry} = Mood.create_entry(user, @valid_attrs)
      assert Mood.get_user_entry(user, entry.id) == entry

      other_user = AccountsFixtures.user_fixture()
      assert Mood.get_user_entry(other_user, entry.id) == nil
    end

    test "create_entry/2 with valid data creates a entry", %{user: user} do
      assert {:ok, %Entry{} = entry} = Mood.create_entry(user, @valid_attrs)
      assert entry.mood == "happy"
      assert entry.journal_entry == "some journal entry"
      assert entry.energy_level == 8
      assert entry.stress_level == 3
      assert entry.sleep_hours == 7.5
      assert entry.user_id == user.id
    end

    test "create_entry/2 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Mood.create_entry(user, @invalid_attrs)
    end

    test "update_entry/2 with valid data updates the entry", %{user: user} do
      {:ok, entry} = Mood.create_entry(user, @valid_attrs)
      assert {:ok, %Entry{} = entry} = Mood.update_entry(entry, @update_attrs)
      assert entry.mood == "calm"
      assert entry.journal_entry == "updated journal entry"
      assert entry.energy_level == 6
      assert entry.stress_level == 4
      assert entry.sleep_hours == 8.0
    end

    test "update_entry/2 with invalid data returns error changeset", %{user: user} do
      {:ok, entry} = Mood.create_entry(user, @valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Mood.update_entry(entry, @invalid_attrs)
      assert entry == Mood.get_entry!(entry.id)
    end

    test "delete_entry/1 deletes the entry", %{user: user} do
      {:ok, entry} = Mood.create_entry(user, @valid_attrs)
      assert {:ok, %Entry{}} = Mood.delete_entry(entry)
      assert_raise Ecto.NoResultsError, fn -> Mood.get_entry!(entry.id) end
    end

    test "change_entry/1 returns a entry changeset", %{user: user} do
      {:ok, entry} = Mood.create_entry(user, @valid_attrs)
      assert %Ecto.Changeset{} = Mood.change_entry(entry)
    end

    test "get_latest_entry/1 returns the most recent entry", %{user: user} do
      {:ok, entry1} = Mood.create_entry(user, @valid_attrs)
      {:ok, entry2} = Mood.create_entry(user, @update_attrs)

      assert Mood.get_latest_entry(user) == entry2
    end
  end
end
