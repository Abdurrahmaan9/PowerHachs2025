defmodule MindSanctuary.Accounts.Email do
  use Ecto.Schema
  import Ecto.Changeset

  schema "emails" do
    field :to, :string
    field :from, :string
    field :subject, :string
    field :body, :string
    field :html_body, :string
    field :status, :string, default: "sent"
    field :sent_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:to, :from, :subject, :body, :html_body, :status, :sent_at])
    |> validate_required([:to, :from, :subject, :body])
    |> validate_inclusion(:status, ["sent", "failed", "pending"])
  end
end
