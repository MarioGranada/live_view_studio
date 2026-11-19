defmodule LiveViewStudio.Release do
  @moduledoc """
  Tasks for production releases, where Mix is not available.

      bin/live_view_studio eval "LiveViewStudio.Release.migrate()"

  On Gigalixir migrations run on boot instead (`MIGRATE_ON_BOOT`), because
  the free database allows only two connections and the app holds both.
  """

  @app :live_view_studio

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos, do: Application.fetch_env!(@app, :ecto_repos)

  defp load_app do
    Application.ensure_all_started(:ssl)
    Application.load(@app)
  end
end
