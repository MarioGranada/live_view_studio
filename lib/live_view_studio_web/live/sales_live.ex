defmodule LiveViewStudioWeb.SalesLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Sales

  def mount(_params, _session, socket) do
    # socket =
    #   assign(socket,
    #     new_orders: Sales.new_orders(),
    #     sales_amount: Sales.sales_amount(),
    #     satisfaction: Sales.satisfaction()
    #   )

    # {:ok, socket}

    if connected?(socket) do
      # ******** Here -> NEED TO CHECK IF THE SOCKET IS CONNECTED
      # ***************************************************** VVV
      # why?, because mount is called twice: 1 for the first http request that comes to the browser and another one when the socket is connected.
      # We want to manipulate data once we have a stateful process (which is created when the socket connection is created and stable)
      :timer.send_interval(1000, self(), :tick)
    end

    {:ok, assign_stats(socket)}
  end

  def render(assigns) do
    ~H"""
    <h1>Snappy Sales 📊</h1>
    <div id="sales">
      <div class="stats">
        <div class="stat">
          <span class="value">
            <%= @new_orders %>
          </span>
          <span class="label">
            New Orders
          </span>
        </div>
        <div class="stat">
          <span class="value">
            $<%= @sales_amount %>
          </span>
          <span class="label">
            Sales Amount
          </span>
        </div>
        <div class="stat">
          <span class="value">
            <%= @satisfaction %>%
          </span>
          <span class="label">
            Satisfaction
          </span>
        </div>
      </div>

      <button phx-click="refresh">
        <img src="/images/refresh.svg" /> Refresh
      </button>
    </div>
    """
  end

  def handle_event("refresh", _params, socket) do
    {:noreply, assign_stats(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, assign_stats(socket)}
  end

  defp assign_stats(socket) do
    assign(socket,
      new_orders: Sales.new_orders(),
      sales_amount: Sales.sales_amount(),
      satisfaction: Sales.satisfaction()
    )
  end
end
