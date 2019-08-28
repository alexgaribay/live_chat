defmodule LiveChatWeb.ConnectLive do
  use Phoenix.LiveView
  import Ecto.Changeset
  alias LiveChatWeb.ChatView
  alias LiveChat.MagicLinks

  def mount(_, socket) do
    assigns = [
      changeset: join_changeset()
    ]

    {:ok, assign(socket, assigns)}
  end

  def render(%{name: _} = assigns) do
    ~L"""
    Welcome, <%= @name %>
    """
  end

  def render(assigns) do
    ChatView.render("connect.html", assigns)
  end

  def handle_event("join", %{"user" => user}, socket) do
    user
    |> join_changeset()
    |> Map.put(:action, :errors)
    |> case do
      %{valid?: true, changes: user} ->
        token = MagicLinks.generate_token(user)

        {:noreply, redirect(socket, to: "/login/#{token}")}
      %{valid?: false} = changeset ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @types %{
    name: :string,
    email: :string
  }

  defp join_changeset(params \\ %{}) do
    cast(
      {%{}, @types},
      params,
      [:email, :name]
    )
    |> validate_required([:email, :name])
    |> validate_format(:email, ~r/.+@.*/)
  end
end
