defmodule MindSanctuary.Resources.Resource do
  use Ecto.Schema
  import Ecto.Changeset

  schema "resources" do
    field :type, :string
    field :category, :string
    field :access_level, :string
    field :title, :string
    field :description, :string
    field :url, :string
    field :is_featured, :boolean, default: false
    field :upload_file, :string, default: "false", virtual: true, redact: true
    field :is_active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [
      :type,
      :category,
      :access_level,
      :title,
      :description,
      :url,
      :is_featured,
      :is_active
    ])
    |> validate_required([:type, :category, :url, :title])
    |> validate_inclusion(:type, ["article", "audio", "video", "document"])
    |> validate_inclusion(:access_level, ["public", "student", "volunteer"])
    |> validate_inclusion(:category, ["mental health", "academic", "career", "wellness", "safety"])
    |> validate_length(:title, min: 3, max: 255)
  end
end
