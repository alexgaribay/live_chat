defmodule LiveChatWeb.ChatLive do
  use Phoenix.LiveView
  import Ecto.Changeset
  alias LiveChatWeb.ChatView
  alias LiveChat.PubSub
  alias LiveChat.ChatServer, as: Chat

  def mount(%{user: user}, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(PubSub, "lobby")
    end

    assigns = [
      user: user,
      messages: Chat.get_messages(),
      changeset: message_changeset()
    ]
    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    ChatView.render("chat.html", assigns)
  end

  def handle_info({:messages, messages}, socket) do
    {:noreply, assign(socket, messages: messages)}
  end

  def handle_event("send", %{"chat" => attrs}, socket) do
    attrs
    |> message_changeset()
    |> case do
      %{valid?: true, changes: %{message: message}} ->
          Chat.new_message(socket.assigns.user, message)
          assigns = [
            changeset: message_changeset()
          ]
          {:noreply, assign(socket, assigns)}
      %{valid?: false} = changeset ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @types %{message: :string}
  defp message_changeset(attrs \\ %{}) do
    cast(
      {%{}, @types},
      attrs,
      [:message]
    )
    |> validate_required([:message])
    |> validate_length(:message, max: 100)
  end
end
