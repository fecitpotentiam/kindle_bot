defmodule TelegramBot.Repo do
  use Ecto.Repo,
    otp_app: :telegram_bot,
    adapter: Ecto.Adapters.Postgres
end
