defmodule LiveViewStudioWeb.VolunteerFormComponent do
  use LiveViewStudioWeb, :live_component

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(socket) do
    changeset = Volunteers.change_volunteer(%Volunteer{})

    {:ok, assign(socket, :form, to_form(changeset))}
  end

  def update(assigns, socket) do
    socket = socket |> assign(assigns) |> assign(:count, assigns.count + 1)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="count">
        Go for it! You'll be volunteer #{@count}
      </div>
      <.form for={@form} phx-submit="save" phx-change="validate" phx-target={@myself}>
        <.input field={@form[:name]} placeholder="Name" autocomplete="off" phx-debounce="2000" />
        <.input field={@form[:phone]} type="tel" placeholder="Phone" autocomplete="off" phx-debounce="blur" phx-hook="PhoneInputHook" />
        <.button phx-disable-with="Saving...">Check In</.button>
      </.form>
    </div>
    """
  end

  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case Volunteers.create_volunteer(volunteer_params) do
      {:ok, _volunteer} ->
        # socket = update(socket, :volunteers, fn volunteers -> [volunteer | volunteers] end)

        # socket = stream_insert(socket, :volunteers, volunteer, at: 0)

        # send(self(), {:volunteer_created, volunteer}) # Handled by broadcast message in Volunteers context file

        changeset = Volunteers.change_volunteer(%Volunteer{})
        socket = put_flash(socket, :info, "Volunteer successfully checked in!")
        {:noreply, assign(socket, :form, to_form(changeset))}

      {:error, changeset} ->
        socket = put_flash(socket, :error, "Volunteer could not be successfully checked in!")
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do
    changeset =
      %Volunteer{} |> Volunteers.change_volunteer(volunteer_params) |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end
end
