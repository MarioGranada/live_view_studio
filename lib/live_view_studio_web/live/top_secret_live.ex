defmodule LiveViewStudioWeb.TopSecretLive do
  use LiveViewStudioWeb, :live_view

  # on_mount {LiveViewStudioWeb.UserAuth, :ensure_authenticated} # Managed by live_session hook on router

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="top-secret">
      <img src="/images/spy.svg" />
      <div class="mission">
        <h1>Top Secret</h1>
        <h2>Your Mission</h2>
        <h3>00<%= @current_user.id %> </h3>
        <p>
          Storm the castle and capture 3 bottles of Elixir.
        </p>
      </div>
    </div>
    """
  end
end
