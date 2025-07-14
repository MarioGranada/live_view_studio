defmodule LiveViewStudioWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :live_view_studio,
    pubsub_server: LiveViewStudio.PubSub

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(LiveViewStudio.PubSub, topic)
  end

  def track_user(topic, user, %{is_playing: is_playing}) do
    # Presence.track(self(), @topic, current_user.id, %{
    #       username: current_user.email |> String.split("@") |> hd(),
    #       is_playing: false
    #     })

    track(self(), topic, user.id, %{
      username: user.email |> String.split("@") |> hd(),
      is_playing: is_playing,
      online_at: Timex.now() |> Timex.format!("%H:%M", :strftime)
    })
  end

  def list_users(topic) do
    list(topic)
  end

  def update_user(user, topic, new_meta) do
    update(self(), topic, user.id, new_meta)
  end

  def remove_presences(socket, leaves) do
    user_ids = Enum.map(leaves, fn {user_id, _} -> user_id end)
    presences = Map.drop(socket.assigns.presences, user_ids)
    Phoenix.Component.assign(socket, :presences, presences)
  end

  def add_presences(socket, joins) do
    presences = Map.merge(socket.assigns.presences, simple_presence_map(joins))
    Phoenix.Component.assign(socket, :presences, presences)
  end

  def simple_presence_map(presences) do
    # Enum.into(presences, %{}, fn {key, value} -> {key, value}  end)
    Enum.into(presences, %{}, fn {user_id, %{metas: [meta | _]}} -> {user_id, meta} end)
  end

  def handle_diff("presence_diff", diff, socket) do
    socket |> remove_presences(diff.leaves) |> add_presences(diff.joins)
  end
end
