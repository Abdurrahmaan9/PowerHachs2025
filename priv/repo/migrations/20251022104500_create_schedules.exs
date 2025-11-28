defmodule MindSanctuary.Repo.Migrations.CreateSchedules do
  use Ecto.Migration

  def change do
    create table(:schedules) do
      add :title, :string, null: false
      add :description, :text
      add :starts_at, :naive_datetime, null: false
      add :ends_at, :naive_datetime
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:schedules, [:user_id])
    create index(:schedules, [:starts_at])
  end
end
