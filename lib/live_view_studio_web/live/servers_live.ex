defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server
  alias LiveViewStudioWeb.ServerFormComponent

  def mount(_params, _session, socket) do
    servers = Servers.list_servers()

    changeset = Servers.change_server(%Server{})

    socket =
      assign(socket,
        servers: servers,
        coffees: 0
        # form: to_form(changeset)
      )

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    server = Servers.get_server!(id)
    {:noreply, assign(socket, selected_server: server, page_title: "What's up #{server.name}?")}

    # server = Servers.get_server!(id)

    # {:noreply,
    #  assign(socket,
    #    selected_server: server,
    #    page_title: "What's up #{server.name}?"
    #  )}
  end

  def handle_params(_, _uri, socket) do
    # {:noreply, assign(socket, selected_server: hd(socket.assigns.servers))}

    socket =
      if socket.assigns.live_action == :new do
        changeset = Servers.change_server(%Server{})

        assign(socket,
          selected_server: nil
          # form: to_form(changeset)
        )
      else
        assign(socket,
          selected_server: hd(socket.assigns.servers)
        )
      end

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
        <div class="nav">
          <%!-- <a
            :for={server <- @servers}
            href={~p"/servers/#{server.id}"}
            class={if server == @selected_server, do: "selected"}
          > --%>

          <%!--href={~p"/servers?#{[id: server]}"}  --> It takes id as default param, but it maps any params in the keyword list  --%>
          <%!-- <a
            :for={server <- @servers}
            href={~p"/servers?#{[id: server.id]}"}
            class={if server == @selected_server, do: "selected"}
          >
            <span class={server.status}></span>
            <%= server.name %>
          </a> --%>

          <%!-- <.link> included by default in liveview projects --%>
          <%!--
          <.link
            :for={server <- @servers}
            href={~p"/servers?#{[id: server]}"}
            class={if server == @selected_server, do: "selected"}
          >
            <span class={server.status}></span>
            <%= server.name %>
          </.link> --%>

          <%!-- <.link
            :for={server <- @servers}
            patch={~p"/servers?#{[id: server]}"}
            class={if server == @selected_server, do: "selected"}
          >
            <span class={server.status}></span>
            <%= server.name %>
          </.link> --%>

    <.link patch={~p"/servers/new"} class="add">
    + Add New Server
    </.link>

          <.link
            :for={server <- @servers}
            patch={~p"/servers/#{server}"}
            class={if server == @selected_server, do: "selected"}
          >
            <span class={server.status}></span>
            <%= server.name %>
          </.link>
        </div>
        <div class="coffees">
          <button phx-click="drink">
            <img src="/images/coffee.svg" />
            <%= @coffees %>
          </button>
        </div>
      </div>
      <div class="main">
        <div class="wrapper">
          <%= if @live_action == :new do %>
            <%!-- <.form for={@form} phx-submit="save" phx-change="validate">
              <div class="field">
                <.input field={@form[:name]} placeholder="Name" phx-debounce="2000" />
              </div>
              <div class="field">
                <.input field={@form[:framework]} placeholder="Framework" phx-debounce="2000" />
              </div>
              <div class="field">
                <.input
                  field={@form[:size]}
                  placeholder="Size (MB)"
                  type="number"
                  phx-debounce="blur"
                />
              </div>
              <.button phx-disable-with="Saving...">
                Save
              </.button>
              <.link patch={~p"/servers"} class="cancel">
                Cancel
              </.link>

            </.form> --%>
            <.live_component module={LiveViewStudioWeb.ServerFormComponent} id={"new"} />
          <% else %>
          <div class="server">
            <div class="header">
              <h2><%= @selected_server.name %></h2>
              <%!-- <span class={@selected_server.status}>
                <%= @selected_server.status %>
              </span> --%>
              <button class={@selected_server.status} phx-click="toggle-status" phx-value-id={@selected_server.id}>
                <%= @selected_server.status %>
              </button>
            </div>
            <div class="body">
              <div class="row">
                <span>
                  <%= @selected_server.deploy_count %> deploys
                </span>
                <span>
                  <%= @selected_server.size %> MB
                </span>
                <span>
                  <%= @selected_server.framework %>
                </span>
              </div>
              <h3>Last Commit Message:</h3>
              <blockquote>
                <%= @selected_server.last_commit_message %>
              </blockquote>
            </div>
          </div>
          <% end %>


          <div class="links">
            <.link navigate={~p"/light"}>
              Adjust Links
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    server = Servers.get_server!(id)
    new_status = if server.status == "up", do: "down", else: "up"

    {:ok, server} = Servers.update_server(server, %{status: new_status})

    servers =
      Enum.map(socket.assigns.servers, fn s ->
        if s.id == server.id, do: server, else: s
      end)

    # {:noreply, assign(socket, selected_server: server, servers: Servers.list_servers())}
    {:noreply, assign(socket, selected_server: server, servers: servers)}
  end

  def handle_event("drink", _, socket) do
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def handle_info({ServerFormComponent, :server_created, server}, socket) do
    socket =
      update(
        socket,
        :servers,
        fn servers -> [server | servers] end
      )

    socket = push_patch(socket, to: ~p"/servers/#{server}")
    {:noreply, socket}
  end
end
