defmodule MindSanctuary.Repo.Migrations.CreateMoodEntries do
  use Ecto.Migration

  def change do
    create table(:mood_entries) do
      add :mood, :string, null: false
      add :journal_entry, :text
      add :energy_level, :integer
      add :stress_level, :integer
      add :sleep_hours, :float
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:mood_entries, [:user_id])
    create index(:mood_entries, [:inserted_at])
  end
end
