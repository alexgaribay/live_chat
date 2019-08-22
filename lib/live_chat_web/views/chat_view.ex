defmodule LiveChatWeb.ChatView do
  use LiveChatWeb, :view
  alias LiveChatWeb.ComponentView, as: Components

  def format_typing([first]) do
    "#{first} is typing"
  end

  def format_typing([first, second]) do
    "#{first} and #{second} are typing"
  end

  def format_typing([first, second, third]) do
    "#{first}, #{second}, and #{third} are typing"
  end

  def format_typing([_, _, _ | _]) do
    "Several people are typing"
  end

  def format_typing(_) do
    ""
  end

  def sidebar_class(false), do: "hidden"
  def sidebar_class(true), do: "sidebar-content-users"
end
