defmodule LiveChatWeb.ChatLive do
  use Phoenix.LiveView
  import Ecto.Changeset
  alias LiveChat.PubSub
  alias LiveChatWeb.ChatView
  alias LiveChat.ChatServer, as: Chat
  alias LiveChat.Presence

  def mount(%{user: user}, socket) do
    Phoenix.PubSub.subscribe(PubSub, "lobby")

    {:ok, _} =
      Presence.track(self(), "lobby", user.name, %{
        name: user.name,
        email: user.email,
        joined_at: :os.system_time(:seconds)
      })

    assigns = [
      messages: Chat.get_messages(),
      changeset: message_changeset(),
      user: user,
      sidebar_open?: false,
      users_typing: []
    ]
    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    ChatView.render("chat.html", assigns)
  end

  def handle_event("show_online", _, socket) do
    {:noreply, assign(socket, :sidebar_open?, !socket.assigns.sidebar_open?)}
  end

  def handle_event("send", %{"chat" => attrs}, socket) do
    attrs
    |> message_changeset()
    |> case do
      %{valid?: true, changes: %{message: message}} ->
        Chat.new_message(socket.assigns.user, message)
        {:noreply, assign(socket, changeset: message_changeset())}

      %{valid?: false} = changeset ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("update", _, socket) do
    Chat.user_typing(socket.assigns.user.name)
    {:noreply, socket}
  end

  def handle_info({:messages, messages}, socket) do
    {:noreply, assign(socket, :messages, messages)}
  end

  def handle_info({:users_typing, user_list}, socket) do
    {:noreply,
     assign(socket, :users_typing, Enum.reject(user_list, &(&1 == socket.assigns.user.name)))}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  @schema {%{message: ""}, %{message: :string}}
  defp message_changeset(attrs \\ %{}) do
    cast(
      @schema,
      attrs,
      [:message]
    )
    |> validate_required([:message])
    |> update_change(:message, &String.trim/1)
    |> validate_required([:message])
  end
end
