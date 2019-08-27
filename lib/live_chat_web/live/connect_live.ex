defmodule LiveChatWeb.ConnectLive do
  use Phoenix.LiveView
  alias LiveChatWeb.ChatView

  def mount(_params, socket) do
    {:ok, socket}
  end

  def render(%{name: _name} = assigns) do
    ~L"""
    <div class="fullscreen">
      Welcome, <%= @name %>!
    </div>
    """
  end

  def render(assigns) do
    ChatView.render("connect.html", assigns)
  end

  def handle_event("join", %{"user" => user}, socket) do
    name = user["name"]
    email = user["email"]

    assigns = [
      name: name,
      email: email
    ]

    {:noreply, assign(socket, assigns)}
  end
end
