defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  # mount
  # render
  # handle_event

  # First callback when the page comes in. It's executed at the very first render of the page.
  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: 10)
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
        <span style={"width: #{@brightness}%"}>
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
    </div>
    """
  end

  def handle_event("on", _payload, socket) do
    socket = assign(socket, brightness: 100)
    {:noreply, socket}
  end

  def handle_event("down", _payload, socket) do
    # brightness = socket.assigns.brightness - 10
    # socket = assign(socket, brightness: brightness)
    socket = update(socket, :brightness, &(&1 - 10))
    {:noreply, socket}
  end

  def handle_event("up", _payload, socket) do
    # brightness = socket.assigns.brightness + 10
    # socket = assign(socket, brightness: brightness)
    socket = update(socket, :brightness, &(&1 + 10))
    {:noreply, socket}
  end

  def handle_event("off", _payload, socket) do
    socket = assign(socket, brightness: 0)
    {:noreply, socket}
  end
end
