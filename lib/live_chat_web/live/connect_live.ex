defmodule LiveChatWeb.ConnectLive do
  use Phoenix.LiveView
  import Ecto.Changeset
  alias LiveChatWeb.ChatView
  alias LiveChat.MagicLinks

  def mount(_params, socket) do
    assigns = [
      changeset: join_changeset()
    ]
    {:ok, assign(socket, assigns)}
  end

  def render(%{name: _name} = assigns) do
    ~L"""
    <div class="fullscreen">
      Welcome, <%= @name %>!
    </div>
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
      %{valid?: true, changes: %{name: _name, email: _email} = user} ->
        token = MagicLinks.get_token(user)

        {:noreply, redirect(socket, to: "/session/#{token}")}
      %{valid?: false} = changeset ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @schema {%{name: nil, email: nil}, %{name: :string, email: :string}}
  defp join_changeset(attrs \\ %{}) do
    cast(
      @schema,
      attrs,
      [:name, :email]
    )
    |> validate_required([:email, :name])
    |> validate_format(:email, ~r/.+@.+/)
  end
end
