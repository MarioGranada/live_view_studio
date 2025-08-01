defmodule LiveViewStudioWeb.AthletesLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Athletes

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        filter: %{sport: "", status: ""},
        athletes: Athletes.list_athletes()
      )

    {:ok, socket, temporary_assigns: [athletes: []]}
  end

  def render(assigns) do
    ~H"""
    <h1>Athletes</h1>
    <div id="athletes">
      <form phx-change="filter">
        <div class="filters">
          <select name="sport">
            <%= Phoenix.HTML.Form.options_for_select(
              sport_options(),
              @filter.sport
            ) %>
          </select>
          <select name="status">
            <%= Phoenix.HTML.Form.options_for_select(
              status_options(),
              @filter.status
            ) %>
          </select>
        </div>
      </form>
      <div class="athletes">
        <div :for={athlete <- @athletes} class="athlete">
          <div class="emoji">
            <%= athlete.emoji %>
          </div>
          <div class="name">
            <%= athlete.name %>
          </div>
          <div class="details">
            <span class="sport">
              <%= athlete.sport %>
            </span>
            <span class="status">
              <%= athlete.status %>
            </span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("filter", %{"status" => status, "sport" => sport}, socket) do
    filter = %{status: status, sport: sport}
    athletes = Athletes.list_athletes(filter)
    {:noreply, assign(socket, athletes: athletes, filter: filter)}
  end

  defp sport_options do
    [
      "All Sports": "",
      Surfing: "Surfing",
      Rowing: "Rowing",
      Swimming: "Swimming"
    ]
  end

  defp status_options do
    [
      "All Statuses": "",
      Training: :training,
      Competing: :competing,
      Resting: :resting
    ]
  end
end
