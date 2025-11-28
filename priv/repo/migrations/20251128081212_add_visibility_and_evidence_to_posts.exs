defmodule MindSanctuary.Repo.Migrations.AddVisibilityAndEvidenceToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :visibility, :string, default: "all", null: false
      add :is_evidence, :boolean, default: false, null: false
    end
  end
end
