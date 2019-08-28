defmodule LiveChatWeb.ChatView do
  use LiveChatWeb, :view

  alias LiveChatWeb.ComponentView, as: Components

  def sidebar_class(false), do: "hidden"
  def sidebar_class(true), do: "sidebar-content-users"
end
