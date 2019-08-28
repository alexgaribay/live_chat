defmodule LiveChatWeb.ChatView do
  use LiveChatWeb, :view

  alias LiveChatWeb.ComponentView, as: Components

  def sidebar_class(false, _), do: "hidden"
  def sidebar_class(true, :user_list), do: "sidebar-content-users"
  def sidebar_class(true, :user_profile), do: "sidebar-content-profile"

  def format_typing([first]) do
    "#{first.name} is typing"
  end

  def format_typing([first, second]) do
    "#{first.name} and #{second.name} are typing"
  end

  def format_typing([first, second, third]) do
    "#{first.name}, #{second.name}, and #{third.name} are typing"
  end

  def format_typing([_, _, _ | _]) do
    "Several people are typing"
  end

  def format_typing(_) do
    ""
  end

  def gravatar_url(email) do
    hash =
      :crypto.hash(:md5, email)
      |> Base.encode16()
      |> String.downcase()

    "https://gravatar.com/avatar/#{hash}?s=300"
  end
end
