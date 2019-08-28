defmodule LiveChat.ChatServer do
  use GenServer

  def init(_opts) do
    state = %{
      messages: [],
      typing: %{}
    }

    send(self(), :update_typing)

    {:ok, state}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_messages do
    GenServer.call(__MODULE__, :get_messages)
  end

  def new_message(user, message) do
    GenServer.cast(__MODULE__, {:new_message, user, message})
  end

  def user_typing(user) do
    GenServer.cast(__MODULE__, {:user_typing, user})
  end

  def handle_call(:get_messages, _from, %{messages: messages} = state) do
    {:reply, messages, state}
  end

  def handle_cast({:new_message, user, message}, %{messages: messages, typing: typing} = state) do
    new_message = %{user: user, message: message}
    messages = messages ++ [new_message]

    typing = Map.delete(typing, user)

    Phoenix.PubSub.broadcast(LiveChat.PubSub, "lobby", {:new_message, new_message})

    {:noreply, %{state | messages: messages, typing: typing}}
  end

  def handle_cast({:user_typing, user}, state) do
    expiry = :os.system_time(:seconds) + 3

    typing = Map.put(state.typing, user, expiry)

    {:noreply, %{state | typing: typing}}
  end

  def handle_info(:update_typing, state) do
    Process.send_after(self(), :update_typing, 1_000)

    now = :os.system_time(:seconds)

    typing =
      state.typing
      |> Enum.reject(fn {_, expiry} -> now >= expiry end)
      |> Enum.into(%{})

    Phoenix.PubSub.broadcast(LiveChat.PubSub, "lobby", {:users_typing, Map.keys(typing)})

    {:noreply, %{state | typing: typing}}
  end
end
