defmodule LiveViewStudioWeb.DonationsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations

  def mount(_params, _session, socket) do
    # donations = Donations.list_donations()

    # socket =
    #   assign(socket,
    #     donations: donations
    #   )

    {:ok, socket, temporary_assigns: [donations: []]}
  end

  def handle_params(params, _url, socket) do
    # sort_by = (params["sort_by"] || "id") |> String.to_atom()
    # sort_order = (params["sort_order"] || "asc") |> String.to_atom()
    sort_by = valid_sort_by(params)
    sort_order = valid_sort_order(params)

    # page = (params["page"] || "1") |> String.to_integer()
    # per_page = (params["per_page"] || "5") |> String.to_integer()
    page = param_to_integer(params["page"], 1)
    per_page = param_to_integer(params["per_page"], 5)
    donation_count = Donations.count_donations()

    options = %{
      sort_by: sort_by,
      sort_order: sort_order,
      page: page,
      per_page: per_page
    }

    donations = Donations.list_donations(options)

    socket =
      assign(socket, donations: donations, options: options, donation_count: donation_count)

    {:noreply, socket}
  end

  attr :sort_by, :atom, required: true
  attr :options, :map, required: true
  slot :inner_block, required: true

  def sort_link(assigns) do
    params = %{
      assigns.options
      | sort_by: assigns.sort_by,
        sort_order: next_sort_order(assigns.options.sort_order)
    }

    assigns = assign(assigns, params: params)

    ~H"""
    <.link patch={~p"/donations?#{@params}"}>
    <%= render_slot(@inner_block) %> <span><%= sort_indicator(@sort_by, @options) %></span>
    </.link>
    """
  end

  def handle_event("handle-keyup", %{"key" => "ArrowLeft"}, socket) do
    if socket.assigns.options.page > 1 do
      socket =
        push_patch(socket,
          to: ~p"/donations?#{%{socket.assigns.options | page: socket.assigns.options.page - 1}}"
        )

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("handle-keyup", %{"key" => "ArrowRight"}, socket) do
    if more_pages?(socket.assigns.options, socket.assigns.donation_count) do
      socket =
        push_patch(socket,
          to: ~p"/donations?#{%{socket.assigns.options | page: socket.assigns.options.page + 1}}"
        )

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("handle-window-keyup", _, socket) do
    {:noreply, socket}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    params = %{socket.assigns.options | per_page: per_page}
    socket = push_patch(socket, to: ~p"/donations?#{params}")
    {:noreply, socket}
  end

  defp next_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      :desc -> :asc
      _ -> :asc
    end
  end

  defp sort_indicator(column, %{sort_by: sort_by, sort_order: sort_order})
       when column == sort_by do
    case sort_order do
      :asc -> "👆"
      :desc -> "👇"
    end
  end

  defp sort_indicator(_, _), do: ""

  defp valid_sort_by(%{"sort_by" => sort_by})
       when sort_by in ~w(item quantity days_until_expires) do
    String.to_atom(sort_by)
  end

  defp valid_sort_by(_params), do: :id

  defp valid_sort_order(%{"sort_order" => sort_order})
       when sort_order in ~w(asc desc) do
    String.to_atom(sort_order)
  end

  defp valid_sort_order(_params), do: :asc

  defp param_to_integer(nil, default), do: default

  defp param_to_integer(param, default) do
    case Integer.parse(param) do
      {number, _} ->
        number

      :error ->
        default
    end
  end

  defp more_pages?(options, donation_count) do
    options.page * options.per_page < donation_count
  end

  defp pages(options, donation_count) do
    page_count = ceil(donation_count / options.per_page)

    for page_number <- (options.page - 2)..(options.page + 2),
        page_number > 0 do
      if page_number <= page_count do
        current_page? = page_number == options.page
        {page_number, current_page?}
      end
    end
  end
end
