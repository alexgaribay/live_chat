defmodule LiveChatWeb.SidebarLive do
  use Phoenix.LiveView
  alias LiveChatWeb.ChatView
  alias LiveChat.Presence

  def mount(%{visible: visible}, socket) do
    assigns = [
      visible: visible,
      users: %{"user_1" => nil}
    ]

    socket =
      socket
      |> assign(assigns)
      |> handle_joins()

    {:ok, socket}
  end

  def render(assigns) do
    ChatView.render("sidebar.html", assigns)
  end

  defp handle_joins(socket), do: socket
end
