defmodule MindSanctuary.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MindSanctuaryWeb.Telemetry,
      MindSanctuary.Repo,
      {DNSCluster, query: Application.get_env(:mind_sanctuary, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MindSanctuary.PubSub},
      # Start a worker by calling: MindSanctuary.Worker.start_link(arg)
      # {MindSanctuary.Worker, arg},
      # Start to serve requests, typically the last entry
      MindSanctuaryWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MindSanctuary.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MindSanctuaryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
