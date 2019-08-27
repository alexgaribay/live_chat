defmodule LiveChatWeb.ChatLive do
  use Phoenix.LiveView

  def mount(_params, socket) do
    send(self(), :count)
    {:ok, assign(socket, :count, 0)}
  end

  def render(assigns) do
    ~L"""
    Count: <%= @count %>
    """
  end

  def handle_info(:count, socket) do
    Process.send_after(self(), :count, 1_000)
    count = socket.assigns.count + 1

    {:noreply, assign(socket, :count, count)}
  end
end
