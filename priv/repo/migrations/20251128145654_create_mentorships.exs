defmodule MindSanctuary.Repo.Migrations.CreateMentorships do
  use Ecto.Migration

  def change do
    create table(:mentorships) do
      add :status, :string, default: "pending", null: false
      add :message, :string, null: false
      add :accepted_at, :utc_datetime
      add :rejected_at, :utc_datetime
      add :mentee_id, references(:users, on_delete: :delete_all), null: false
      add :mentor_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:mentorships, [:mentee_id])
    create index(:mentorships, [:mentor_id])
    create index(:mentorships, [:status])
    create unique_index(:mentorships, [:mentee_id, :mentor_id], name: :unique_mentor_mentee_pair)
  end
end
