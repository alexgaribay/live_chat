defmodule LiveChat.ChatServer do
  use GenServer

  def init(_opts) do
    state = %{
      messages: []
    }

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

  def handle_call(:get_messages, _from, %{messages: messages} = state) do
    {:reply, messages, state}
  end

  def handle_cast({:new_message, user, message}, %{messages: messages} = state) do
    new_message = %{user: user, message: message}
    messages = messages ++ [new_message]
    Phoenix.PubSub.broadcast(LiveChat.PubSub, "lobby", {:new_message, new_message})
    {:noreply, %{state | messages: messages}}
  end
end
