defmodule LiveChat.Presence do
  use Phoenix.Presence, otp_app: :live_chat, pubsub_server: LiveChat.PubSub
end
