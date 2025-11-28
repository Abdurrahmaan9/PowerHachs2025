defmodule MindSanctuary.Repo.Migrations.CreateEmails do
  use Ecto.Migration

  def change do
    create table(:emails) do
      add :to, :string, null: false
      add :from, :string, null: false
      add :subject, :string, null: false
      add :body, :text, null: false
      add :html_body, :text
      add :status, :string, default: "sent", null: false
      add :sent_at, :utc_datetime

      timestamps()
    end
  end
end
