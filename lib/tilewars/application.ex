defmodule Tilewars.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TilewarsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Tilewars.PubSub},
      # Start the Endpoint (http/https)
      TilewarsWeb.Endpoint,
      Tilewars.GameServer,
      {Tilewars.PlayerRegistry, name: PReg},
      {Tilewars.PlayerSup, name: PlayerSup, strategy: :temporary}

      # Start a worker by calling: Tilewars.Worker.start_link(arg)
      # {Tilewars.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tilewars.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TilewarsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
