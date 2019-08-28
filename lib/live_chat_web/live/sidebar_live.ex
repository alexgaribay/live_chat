defmodule LiveChatWeb.SidebarLive do
  use Phoenix.LiveView
  alias LiveChatWeb.ChatView
  alias LiveChat.Presence

  def mount(%{visible: visible}, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(LiveChat.PubSub, "lobby:presence")
    end
    assigns = [
      visible: visible,
      users: %{}
    ]
    socket =
      socket
      |> assign(assigns)
      |> handle_joins(Presence.list("lobby:presence"))
    {:ok, socket}
  end

  def render(assigns) do
    ChatView.render("sidebar.html", assigns)
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff}, socket) do
    socket =
      socket
      |> handle_leaves(diff.leaves)
      |> handle_joins(diff.joins)
    {:noreply, socket}
  end

  defp handle_joins(socket, joins) do
    Enum.reduce(joins, socket, fn
      {user_name, %{metas: [meta | _]}}, socket ->
        assign(socket, :users, Map.put(socket.assigns.users, user_name, meta))
    end)
  end

  defp handle_leaves(socket, leaves) do
    Enum.reduce(leaves, socket, fn
      {user_name, _}, socket ->
        assign(socket, :users, Map.delete(socket.assigns.users, user_name))
    end)
  end
end
