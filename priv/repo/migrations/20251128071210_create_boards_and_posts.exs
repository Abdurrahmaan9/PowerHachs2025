defmodule MindSanctuary.Repo.Migrations.CreateBoardsAndPosts do
  use Ecto.Migration

  def change do
    create table(:boards) do
      add :name, :string, null: false
      add :description, :string, null: false
      add :category, :string, null: false
      add :color, :string, default: "blue"

      timestamps()
    end

    create unique_index(:boards, [:name])

    create table(:posts) do
      add :title, :string, null: false
      add :content, :text, null: false
      add :anonymous, :boolean, default: true
      add :support_count, :integer, default: 0
      add :board_id, references(:boards, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :visibility, :string, default: "all", null: false
      add :is_evidence, :boolean, default: false, null: false

      timestamps()
    end

    create index(:posts, [:board_id])
    create index(:posts, [:user_id])
    create index(:posts, [:inserted_at])
  end
end
