defmodule LiveViewStudio.DemoReset do
  @moduledoc """
  Keeps the public demo tidy: once a day (04:00 UTC) it empties every table,
  including registered users, and re-runs `priv/repo/seeds.exs`.

  On boot it also seeds an empty database, so a fresh deploy needs no manual
  seeding step. Started only when `DEMO_RESET=true` (set on the hosted demo).
  """

  use GenServer
  require Logger

  alias LiveViewStudio.Repo

  @hour_utc 4

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @doc "Truncates the demo tables and loads the seed in one transaction."
  def reset! do
    tables =
      Repo.query!("""
      SELECT tablename FROM pg_tables
      WHERE schemaname = current_schema() AND tablename <> 'schema_migrations'
      """).rows
      |> List.flatten()

    seeds = Application.app_dir(:live_view_studio, "priv/repo/seeds.exs")

    {:ok, _} =
      Repo.transaction(
        fn ->
          if tables != [] do
            quoted = Enum.map_join(tables, ", ", &~s("#{&1}"))
            Repo.query!("TRUNCATE #{quoted} RESTART IDENTITY CASCADE")
          end

          Code.eval_file(seeds)
        end,
        timeout: :infinity
      )

    :ok
  end

  @impl true
  def init(_opts) do
    schedule()
    {:ok, nil, {:continue, :seed_if_empty}}
  end

  # A freshly provisioned database gets the seed on first boot.
  @impl true
  def handle_continue(:seed_if_empty, state) do
    if Repo.aggregate(LiveViewStudio.Boats.Boat, :count) == 0 do
      reset!()
      Logger.info("Empty database seeded")
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:reset, state) do
    try do
      reset!()
      Logger.info("Demo data reset to seed")
    rescue
      e -> Logger.error("Demo reset failed: " <> Exception.message(e))
    end

    schedule()
    {:noreply, state}
  end

  defp schedule do
    Process.send_after(self(), :reset, ms_until_next_run(DateTime.utc_now()))
  end

  @doc false
  def ms_until_next_run(now) do
    today = DateTime.new!(DateTime.to_date(now), Time.new!(@hour_utc, 0, 0), "Etc/UTC")
    next = if DateTime.compare(today, now) == :gt, do: today, else: DateTime.add(today, 1, :day)
    DateTime.diff(next, now, :millisecond)
  end
end
