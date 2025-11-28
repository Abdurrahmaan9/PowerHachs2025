defmodule MindSanctuary.Repo.Migrations.CreateAttachments do
  use Ecto.Migration

  def change do
    create table(:attachments) do
      add :filename, :string, null: false
      add :original_filename, :string, null: false
      add :content_type, :string, null: false
      add :size, :integer, null: false
      add :path, :string, null: false
      add :post_id, references(:posts, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:attachments, [:post_id])
  end
end
