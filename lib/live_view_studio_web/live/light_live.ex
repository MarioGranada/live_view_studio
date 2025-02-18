defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  # mount
  # render
  # handle_event

  # First callback when the page comes in. It's executed at the very first render of the page.
  def mount(_params, _session, socket) do
    init_temperature = %{temperature: "3000", hex_temperature: temp_color("3000")}

    socket =
      assign(socket,
        brightness: 10,
        temperature: init_temperature.temperature,
        hex_temperature: init_temperature.hex_temperature
      )

    IO.inspect(socket)
    {:ok, socket}
  end

  def render(assigns) do
    # Heex template
    # Heex = HTML + ex
    ~H"""
    <h1>Front Porch Light</h1>
    <div id="light">
      <div class="meter">
        <span style={"width: #{@brightness}%; background-color: #{@hex_temperature}"}>
          <%!-- <%= assigns.brightness %> --%>
          <%= @brightness %>%
        </span>
      </div>
      <button phx-click="off">
        <img src="/images/light-off.svg" alt="light-off" />
      </button>

      <button phx-click="down">
        <img src="/images/down.svg" alt="down" />
      </button>
      <button phx-click="up">
        <img src="/images/up.svg" alt="up" />
      </button>
      <button phx-click="on">
        <img src="/images/light-on.svg" alt="light-on" />
      </button>
      <button phx-click="random">
        <img src="/images/fire.svg" alt="fire" />
      </button>
    </div>
    <form phx-change="slider-change">
      <input
        type="range"
        min="0"
        max="100"
        name="brightness-slider"
        value={@brightness}
      />
    </form>

    <form phx-change="temp-change">
      <div class="temps">
        <%= for temp <- ["3000", "4000", "5000"] do %>
          <div>
            <input
              type="radio"
              id={temp}
              name="temp"
              value={temp}
              checked={@temperature == temp}
            />
            <label for={temp}><%= temp %></label>
          </div>
        <% end %>
      </div>
    </form>
    """
  end

  def handle_event("on", _payload, socket) do
    socket = assign(socket, brightness: 100)
    {:noreply, socket}
  end

  def handle_event("down", _payload, socket) do
    # brightness = socket.assigns.brightness - 10
    # socket = assign(socket, brightness: brightness)
    socket = update(socket, :brightness, &max(&1 - 10, 0))
    {:noreply, socket}
  end

  def handle_event("up", _payload, socket) do
    # brightness = socket.assigns.brightness + 10
    # socket = assign(socket, brightness: brightness)
    socket = update(socket, :brightness, &min(&1 + 10, 100))
    {:noreply, socket}
  end

  def handle_event("off", _payload, socket) do
    socket = assign(socket, brightness: 0)
    {:noreply, socket}
  end

  def handle_event("random", _payload, socket) do
    # socket = assign(socket, brightness: 0)
    random_number = :rand.uniform(100)
    IO.puts("in here oe random #{random_number}")
    socket = assign(socket, brightness: random_number)
    {:noreply, socket}
  end

  def handle_event("slider-change", params, socket) do
    %{"brightness-slider" => new_brightness} = params
    socket = assign(socket, brightness: new_brightness)
    {:noreply, socket}
  end

  def handle_event("temp-change", params, socket) do
    %{"temp" => new_temperature} = params

    socket =
      assign(socket, temperature: new_temperature, hex_temperature: temp_color(new_temperature))

    {:noreply, socket}
  end

  defp temp_color("3000"), do: "#F1C40D"
  defp temp_color("4000"), do: "#FEFF66"
  defp temp_color("5000"), do: "#99CCFF"
end
