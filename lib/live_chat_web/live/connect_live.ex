defmodule LiveChatWeb.ConnectLive do
  use Phoenix.LiveView
  alias LiveChatWeb.ChatView

  def mount(_, socket) do
    {:ok, socket}
  end

  def render(%{name: _} = assigns) do
    ~L"""
    Welcome, <%= @name %>
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
