defmodule LiveChatWeb.ChatLive do
  use Phoenix.LiveView
  import Ecto.Changeset
  alias LiveChatWeb.ChatView
  alias LiveChat.PubSub
  alias LiveChat.ChatServer, as: Chat
  alias LiveChat.Presence

  def mount(%{user: user}, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(PubSub, "lobby")
      {:ok, _} =
        Presence.track(self(), "lobby:presence", user.name, %{
          name: user.name,
          email: user.email,
          joined_at: :os.system_time(:seconds)
        })
    end

    assigns = [
      changeset: message_changeset(),
      messages: Chat.get_messages(),
      user: user,
      sidebar_open?: false,
      users_typing: []
    ]

    socket =
      socket
      |> assign(assigns)
      |> configure_temporary_assigns([:messages])

    {:ok, socket}
  end

  def render(assigns) do
    ChatView.render("chat.html", assigns)
  end

  def handle_info({:new_message, message}, socket) do
    {:noreply, assign(socket, :messages, [message])}
  end

  def handle_info({:users_typing, users}, socket) do
    users_typing = Enum.reject(users, fn user -> user == socket.assigns.user end)

    {:noreply, assign(socket, :users_typing, users_typing)}
  end

  def handle_event("show_online", _attrs, socket) do
    {:noreply, assign(socket, :sidebar_open?, !socket.assigns.sidebar_open?)}
  end

  def handle_event("update", _, socket) do
    Chat.user_typing(socket.assigns.user)
    {:noreply, socket}
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
    |> update_change(:message, &String.trim/1)
    |> validate_required([:message])
  end
end
