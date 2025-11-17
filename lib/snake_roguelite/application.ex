defmodule SnakeRoguelite.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Telemetry supervisor
      SnakeRogueliteWeb.Telemetry,
      # PubSub system for real-time features
      {Phoenix.PubSub, name: SnakeRoguelite.PubSub},
      # Registry for game sessions
      SnakeRoguelite.GameRegistry,
      # Game state supervisor - manages all active game sessions
      {DynamicSupervisor, name: SnakeRoguelite.GameSupervisor, strategy: :one_for_one},
      # Start the Endpoint (http/https)
      SnakeRogueliteWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SnakeRoguelite.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SnakeRogueliteWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
