defmodule LiveChatWeb.SidebarLive do
  use Phoenix.LiveView
  alias LiveChatWeb.ChatView
  alias LiveChat.Presence

  def mount(%{visible: visible}, socket) do
    assigns = [
      visible: visible,
      users: %{},
    ]

    socket =
      socket
      |> assign(assigns)
      |> handle_joins(Presence.list("lobby"))
    {:ok, socket}
  end

  def render(assigns) do
    ChatView.render("sidebar.html", assigns)
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff},
        socket
      ) do
    socket =
      socket
      |> handle_leaves(diff.leaves)
      |> handle_joins(diff.joins)
    {:noreply, socket}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  defp handle_leaves(socket, leaves) do
    Enum.reduce(leaves, socket, fn
      {user, _}, socket ->
        assign(socket, :users, Map.delete(socket.assigns.users, user))
    end)
  end

  defp handle_joins(socket, joins) do
    Enum.reduce(joins, socket, fn
      {user, %{metas: [meta | _]}}, socket ->
        assign(socket, :users, Map.put(socket.assigns.users, user, meta))
    end)
  end
end
