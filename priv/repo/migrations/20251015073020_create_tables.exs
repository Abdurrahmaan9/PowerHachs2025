defmodule MindSanctuary.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def up do
    create_tables()
    # alter_tables()
    # Oban.Migrations.up()
    # table_index()
    # create_sequence()
  end

  def down do
    # Oban.Migrations.down()
    # drop_tables()
  end

  def create_tables() do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create_if_not_exists table(:users) do
      add :username, :string, null: false
      add :role, :string, null: false
      add :email, :citext, null: false
      add :hashed_password, :string
      add :confirmed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists unique_index(:users, [:email, :username])

    create_if_not_exists table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      add :authenticated_at, :utc_datetime

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create_if_not_exists index(:users_tokens, [:user_id])
    create_if_not_exists unique_index(:users_tokens, [:context, :token])

    create_if_not_exists table(:resources) do
      add :type, :string, null: false
      add :category, :string, null: false
      add :access_level, :string, null: false
      add :title, :string, null: false
      add :description, :string
      add :url, :string, null: false
      add :is_featured, :boolean
      add :is_active, :boolean, default: true

      timestamps(type: :utc_datetime)
    end

    create_if_not_exists table(:chats) do
      add :title, :string, null: false
      add :type, :string, null: false

      timestamps()
    end

    create_if_not_exists table(:chat_users) do
      add :chat_id, references(:chats, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create_if_not_exists unique_index(:chat_users, [:chat_id, :user_id])

    create_if_not_exists table(:chat_messages) do
      add :body, :text, null: false
      add :chat_id, references(:chats, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create_if_not_exists index(:chat_messages, [:user_id, :chat_id, :inserted_at])
  end

  def alter_tables() do
  end

  def drop_tables() do
    drop_if_exists table(:users)
    drop_if_exists table(:users_tokens)
  end
end
