defmodule LiveViewStudio.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        # Start the Telemetry supervisor
        LiveViewStudioWeb.Telemetry,
        # Start the Ecto repository
        LiveViewStudio.Repo,
        # Run pending migrations on boot in releases (reuses the Repo pool)
        {Ecto.Migrator,
         repos: Application.fetch_env!(:live_view_studio, :ecto_repos),
         skip: not Application.get_env(:live_view_studio, :migrate_on_boot, false)},
        # Start the PubSub system
        {Phoenix.PubSub, name: LiveViewStudio.PubSub},
        LiveViewStudioWeb.Presence,
        # Start Finch
        {Finch, name: LiveViewStudio.Finch},
        # Start the Endpoint (http/https)
        LiveViewStudioWeb.Endpoint
      ] ++ demo_reset_children()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveViewStudio.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Nightly demo reset, enabled with DEMO_RESET=true (see config/runtime.exs).
  defp demo_reset_children do
    if Application.get_env(:live_view_studio, :demo_reset, false),
      do: [LiveViewStudio.DemoReset],
      else: []
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveViewStudioWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
