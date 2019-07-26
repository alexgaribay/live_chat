defmodule LiveChatWeb.PageController do
  use LiveChatWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
