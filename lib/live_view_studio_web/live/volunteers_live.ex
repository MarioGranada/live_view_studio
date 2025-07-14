defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  # alias LiveViewStudio.Volunteers.Volunteer
  alias LiveViewStudioWeb.VolunteerFormComponent
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Volunteers.subscribe()
    end

    volunteers = Volunteers.list_volunteers()

    # changeset = Volunteers.change_volunteer(%Volunteer{})

    # socket =
    #   assign(socket,
    #     volunteers: volunteers,
    #     form: to_form(changeset)
    #   )

    socket =
      socket
      |> stream(:volunteers, volunteers)
      |> assign(:count, length(volunteers))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <%!-- <.form for={@form} phx-submit="save" phx-change="validate">
        <.input field={@form[:name]} placeholder="Name" autocomplete="off" phx-debounce="2000" />
        <.input field={@form[:phone]} type="tel" placeholder="Phone" autocomplete="off" phx-debounce="blur" />
        <.button phx-disable-with="Saving...">Check In</.button>
      </.form> --%>

      <.live_component module={VolunteerFormComponent} id={:new} count={@count}  />

      <%!-- <div
        :for={volunteer <- @volunteers}
        class={"volunteer #{if volunteer.checked_out, do: "out"}"}
      > --%>

      <div id="volunteers" phx-update="stream">
        <.volunteer :for={{volunteer_dom_id, volunteer} <- @streams.volunteers} id={volunteer_dom_id} volunteer={volunteer}  />
      </div>
    </div>
    """
  end

  def volunteer(assigns) do
    ~H"""
    <div
        class={"volunteer #{if @volunteer.checked_out, do: "out"}"}
        id={@id}
      >
        <div class="name">
          <%= @volunteer.name %>
        </div>
        <div class="phone">
          <%= @volunteer.phone %>
        </div>
        <div class="status">
          <%!-- <button phx-click="toggle-status" phx-value-id={@volunteer.id}>
            <%= if @volunteer.checked_out, do: "Check In", else: "Check Out" %>
          </button> --%>
          <button phx-click={toggle_volunteer_status(@volunteer.id, @id)}>
            <%= if @volunteer.checked_out, do: "Check In", else: "Check Out" %>
          </button>
        </div>
        <%!-- <.link
          class="delete"
          phx-click="delete"
          phx-value-id={@volunteer.id}
          data-confirm="Are you sure?">
            <.icon name="hero-trash-solid" />
        </.link> --%>

        <.link
          class="delete"
          phx-click={delete_volunteer(@volunteer.id, @id)}
          data-confirm="Are you sure?">
            <.icon name="hero-trash-solid" />
        </.link>
      </div>
    """
  end

  def handle_event("delete", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, _volunteer} =
      Volunteers.delete_volunteer(volunteer)

    # socket = stream_delete(socket, :volunteers, volunteer)

    {:noreply, socket}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, _volunteer} =
      Volunteers.update_volunteer(volunteer, %{checked_out: !volunteer.checked_out})

    # socket = stream_insert(socket, :volunteers, volunteer)

    {:noreply, socket}
  end

  def handle_info({:volunteer_created, volunteer}, socket) do
    socket = update(socket, :count, &(&1 + 1))
    socket = stream_insert(socket, :volunteers, volunteer, at: 0)
    {:noreply, socket}
  end

  def handle_info({:volunteer_updated, volunteer}, socket) do
    socket = stream_insert(socket, :volunteers, volunteer)
    {:noreply, socket}
  end

  def handle_info({:volunteer_deleted, volunteer}, socket) do
    socket = update(socket, :count, &(&1 - 1))
    socket = stream_delete(socket, :volunteers, volunteer)
    {:noreply, socket}
  end

  def toggle_volunteer_status(id, volunteer_dom_id) do
    JS.push("toggle-status", value: %{:id => id})
    |> JS.transition("shake", to: "##{volunteer_dom_id}", time: 500)
  end

  def delete_volunteer(id, volunteer_dom_id) do
    JS.push("delete", value: %{:id => id})
    |> JS.hide(
      to: "##{volunteer_dom_id}",
      transition: "ease duration-1000 scale-150"
    )
  end
end
