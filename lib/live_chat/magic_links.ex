defmodule LiveChat.MagicLinks do
  @salt "magic"

  def child_spec(_) do
    %{
      id: LiveChat.MagicLinks,
      start: {LiveChat.MagicLinks, :start_link, []}
    }
  end

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get_token(%{name: name, email: email} = user) do
    token = Phoenix.Token.sign(LiveChatWeb.Endpoint, @salt, "#{name}-#{email}")
    Agent.update(__MODULE__, fn map -> Map.put(map, token, user) end)
    token
  end

  def verify_token(token) do
    case Agent.get_and_update(__MODULE__, fn map -> Map.pop(map, token) end) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
