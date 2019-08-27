defmodule LiveChat.ChatServer do
  use GenServer

  def init(_opts) do
    send(self(), :update_typing)

    state = %{
      messages: [],
      typing: %{}
    }

    {:ok, state}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def user_typing(user) do
    GenServer.cast(__MODULE__, {:user_typing, user})
  end

  def get_messages do
    GenServer.call(__MODULE__, :get_messages)
  end

  def new_message(user, message) do
    GenServer.cast(__MODULE__, {:new_message, user, message})
  end

  def handle_call(:get_messages, _from, %{messages: messages} = state) do
    {:reply, messages, state}
  end

  def handle_cast({:new_message, user, message}, %{messages: messages} = state) do
    new_message = %{user: user, message: message}
    messages = messages ++ [new_message]

    typing = Map.delete(state.typing, user)

    Phoenix.PubSub.broadcast(LiveChat.PubSub, "lobby", {:new_message, new_message})
    Phoenix.PubSub.broadcast(LiveChat.PubSub, "lobby", {:users_typing, Map.keys(typing)})

    {:noreply, %{state | messages: messages, typing: typing}}
  end

  def handle_cast({:user_typing, user}, state) do
    expiry = :os.system_time(:seconds) + 3
    typing = Map.put(state.typing, user, expiry)

    Phoenix.PubSub.broadcast(LiveChat.PubSub, "lobby", {:users_typing, Map.keys(typing)})
    {:noreply, %{state | typing: typing}}
  end

  def handle_info(:update_typing, %{typing: typing} = state) do
    Process.send_after(self(), :update_typing, 1_000)

    now = :os.system_time(:seconds)

    typing =
      for {user, expiry} <- typing, expiry >= now, into: %{} do
        {user, expiry}
      end

    Phoenix.PubSub.broadcast(LiveChat.PubSub, "lobby", {:users_typing, Map.keys(typing)})

    {:noreply, %{state | typing: typing}}
  end
end
