defmodule LiveChat.Repo do
  use Ecto.Repo,
    otp_app: :live_chat,
    adapter: Ecto.Adapters.Postgres
end
