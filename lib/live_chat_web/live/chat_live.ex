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
      user: user,
      messages: Chat.get_messages(),
      changeset: message_changeset(),
      counter: 0,
      sidebar_open?: false
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
    {:noreply, assign(socket, messages: [message])}
  end

  def handle_event("send", %{"chat" => attrs}, socket) do
    attrs
    |> message_changeset()
    |> case do
      %{valid?: true, changes: %{message: message}} ->
          Chat.new_message(socket.assigns.user, message)
          assigns = [
            changeset: message_changeset(%{counter: socket.assigns.counter}),
            counter: socket.assigns.counter + 1
          ]
          {:noreply, assign(socket, assigns)}
      %{valid?: false} = changeset ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("show_online", _params, socket) do
    {:noreply, assign(socket, :sidebar_open?, !socket.assigns.sidebar_open?)}
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
