defmodule MindSanctuary.Repo.Migrations.CreateSupports do
  use Ecto.Migration

  def change do
    create table(:supports) do
      add :post_id, references(:posts, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:supports, [:post_id, :user_id], unique: true, name: :supports_post_id_user_id_index)
  end
end
