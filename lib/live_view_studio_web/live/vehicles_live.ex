defmodule LiveViewStudioWeb.VehiclesLive do
  use LiveViewStudioWeb, :live_view
  alias LiveViewStudio.Vehicles

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        vehicles: [],
        make_model: "",
        loading: false
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>🚙 Find a Vehicle 🚘</h1>
    <div id="vehicles">
      <form phx-submit="search">
        <input
          type="text"
          name="query"
          value={@make_model}
          placeholder="Make or model"
          autofocus
          autocomplete="off"
          readonly={@loading}
        />

        <button>
          <img src="/images/search.svg" />
        </button>
      </form>

      <div :if={@loading} class="loader">
        Loading...
      </div>

      <div class="vehicles">
        <ul>
          <li :for={vehicle <- @vehicles}>
            <span class="make-model">
              <%= vehicle.make_model %>
            </span>
            <span class="color">
              <%= vehicle.color %>
            </span>
            <span class={"status #{vehicle.status}"}>
              <%= vehicle.status %>
            </span>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("search", %{"query" => make_model}, socket) do
    send(self(), {:run_search, make_model})

    socket = assign(socket, make_model: make_model, vehicles: [], loading: true)

    {:noreply, socket}
  end

  def handle_info({:run_search, make_model}, socket) do
    socket =
      assign(socket,
        make_model: make_model,
        vehicles: Vehicles.search(make_model),
        loading: false
      )

    {:noreply, socket}
  end
end
