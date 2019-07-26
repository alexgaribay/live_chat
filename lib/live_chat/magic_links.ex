defmodule LiveChat.MagicLinks do
  @moduledoc """
  Helper for one-time token generation and verification.
  """

  # In production, use a stronger salt much longer than 4 characters :)
  @salt "magic"

  @type user :: %{name: String.t(), email: String.t()}

  def child_spec(_) do
    %{
      id: LiveChat.MagicLinks,
      start: {LiveChat.MagicLinks, :start_link, []}
    }
  end

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Creates a new token based on user information.
  """
  @spec generate_token(user()) :: String.t()
  def generate_token(%{name: name, email: email} = user) do
    token = Phoenix.Token.sign(LiveChatWeb.Endpoint, @salt, "#{name}-#{email}")
    Agent.update(__MODULE__, fn map -> Map.put(map, token, user) end)
    token
  end

  @doc """
  Verifies a token. If valid, the user's information is returned.
  """
  @spec verify_token(String.t()) :: {:ok, user()} | {:error, :not_found}
  def verify_token(token) do
    # Blow up if token fails to verify
    {:ok, _token_base} = Phoenix.Token.verify(LiveChatWeb.Endpoint, @salt, token, max_age: 1_000)
    case Agent.get_and_update(__MODULE__, fn map -> Map.pop(map, token) end) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
