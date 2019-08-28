defmodule LiveChatWeb.SidebarLive do
  use Phoenix.LiveView
  alias LiveChatWeb.ChatView
  alias LiveChat.Presence

  def mount(%{visible: visible}, socket) do
    assigns = [
      visible: visible,
      users: %{}
    ]
    socket = assign(socket, assigns)
    {:ok, socket}
  end

  def render(assigns) do
    ChatView.render("sidebar.html", assigns)
  end
end
