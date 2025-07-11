defmodule LiveViewStudioWeb.FlightsLive do
  use LiveViewStudioWeb, :live_view
  alias LiveViewStudio.Flights
  alias LiveViewStudio.Airports

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        airport: "",
        flights: [],
        loading: false,
        matches: []
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Find a Flight</h1>
    <div id="flights">
      <form phx-submit="search" phx-change="suggest">
        <input
          type="text"
          name="airport"
          value={@airport}
          placeholder="Airport Code"
          autofocus
          autocomplete="off"
          readonly={@loading}
          list="matches"
          phx-debounce="500"
        />

        <button>
          <img src="/images/search.svg" />
        </button>
      </form>

      <datalist id="matches">
        <option :for={{code, name} <- @matches} value={code}>
          <%= name %>
        </option>
      </datalist>

      <div :if={@loading} class="loader">
        Loading...
      </div>

      <div class="flights">
        <ul>
          <%!-- <%= for flight <- @flights do %> --%>
          <%!-- <li> --%>
          <li :for={flight <- @flights}>
            <div class="first-line">
              <div class="number">
                Flight #<%= flight.number %>
              </div>
              <div class="origin-destination">
                <%= flight.origin %> to <%= flight.destination %>
              </div>
            </div>
            <div class="second-line">
              <div class="departs">
                Departs: <%= flight.departure_time %>
              </div>
              <div class="arrives">
                Arrives: <%= flight.arrival_time %>
              </div>
            </div>
          </li>
          <%!-- <% end %> --%>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("search", %{"airport" => airport}, socket) do
    # socket =
    #   assign(socket,
    #     airport: airport,
    #     flights: Flights.search_by_airport(airport),
    #     loading: true
    #   )

    send(self(), {:run_search, airport})

    socket =
      assign(socket,
        airport: airport,
        flights: [],
        loading: true
      )

    {:noreply, socket}
  end

  def handle_event("suggest", %{"airport" => airport}, socket) do
    suggestions = Airports.suggest(airport)
    socket = assign(socket, airport: airport, matches: suggestions)
    {:noreply, socket}
  end

  def handle_info({:run_search, airport}, socket) do
    socket =
      assign(socket,
        airport: airport,
        flights: Flights.search_by_airport(airport),
        loading: false
      )

    {:noreply, socket}
  end
end
