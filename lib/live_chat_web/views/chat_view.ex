defmodule LiveChatWeb.ChatView do
  use LiveChatWeb, :view

  alias LiveChatWeb.ComponentView, as: Components

  def sidebar_class(false), do: "hidden"
  def sidebar_class(true), do: "sidebar-content-users"

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
end
