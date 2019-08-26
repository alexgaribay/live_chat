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

  def new_message(user, message) do
    GenServer.cast(__MODULE__, {:new_message, user, message})
  end

  def get_messages do
    GenServer.call(__MODULE__, :get_messages)
  end

	def user_typing(user) do
		GenServer.cast(__MODULE__, {:user_typing, user})
	end

  def handle_cast({:new_message, user, message}, %{messages: messages, typing: typing} = state) do
    new_message = %{user: user, message: message, created_at: :os.system_time()}
    new_messages = messages ++ [new_message]
		typing = Map.delete(typing, user.name)
    Phoenix.PubSub.broadcast!(LiveChat.PubSub, "lobby", {:new_message, new_message})
    Phoenix.PubSub.broadcast!(LiveChat.PubSub, "lobby", {:users_typing, Map.keys(typing)})
    {:noreply, %{state | messages: new_messages, typing: typing}}
  end

	def handle_cast({:user_typing, user},  %{typing: typing} = state) do
		expiry = :os.system_time(:seconds) + 3
		typing = Map.put(typing, user, expiry)

    Phoenix.PubSub.broadcast!(LiveChat.PubSub, "lobby", {:users_typing, Map.keys(typing)})

		{:noreply, %{state | typing: typing}}
	end

  def handle_call(:get_messages, _, %{messages: messages} = state) do
    {:reply, messages, state}
  end

	def handle_info(:update_typing, %{typing: typing} = state) do
		now = :os.system_time(:seconds)

		typing =
			for {user, expiry} <- typing, expiry >= now, into: %{} do
				{user, expiry}
			end

    Phoenix.PubSub.broadcast!(LiveChat.PubSub, "lobby", {:users_typing, Map.keys(typing)})

		Process.send_after(self(), :update_typing, 1_000)

		{:noreply, %{state | typing: typing}}
	end
end
