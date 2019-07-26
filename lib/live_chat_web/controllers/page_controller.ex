defmodule LiveChatWeb.PageController do
  use LiveChatWeb, :controller
  alias LiveChat.MagicLinks

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def login(conn, %{"token" => token}) do
    case MagicLinks.verify_token(token) do
      {:ok, user} ->
        put_session(conn, :user, user)

      {:error, :not_found} ->
        conn
    end
    |> redirect(to: "/")
  end

  def logout(conn, _) do
    conn
    |> delete_session(:user)
    |> redirect(to: "/")
  end
end
