defmodule MindSanctuary.Repo do
  use Ecto.Repo,
    otp_app: :mind_sanctuary,
    adapter: Ecto.Adapters.Postgres
end
