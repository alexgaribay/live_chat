defmodule LiveChatWeb.ChatLive do
  use Phoenix.LiveView

  def mount(%{user: user}, socket) do
    assigns = [
      user: user
    ]
    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    ~L"""
    <div class="fullscreen">Welcome to chat, <%= @user.name %>!</div>
    """
  end
end
