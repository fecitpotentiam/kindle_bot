# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :telegram_bot,
  ecto_repos: [TelegramBot.Repo]

config :telegram_bot, TelegramBot.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.yandex.ru",
  port: 465,
  username: {:system, "SMTP_USERNAME"},
  password: {:system, "SMTP_PASSWORD"},
  tls: :if_available, # can be `:always` or `:never`
  ssl: true, # can be `true`
  retries: 1,
  allowed_tls_versions: [:"tlsv1", :"tlsv1.1", :"tlsv1.2"],
  auth: :always

# Configures the endpoint
config :telegram_bot, TelegramBotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YpWFI7oqURnjDaiSXAclZl3cIBrqr5bw7wrDUlJEI+LUXUuZS+7sLdsJH2hf5duV",
  render_errors: [view: TelegramBotWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TelegramBot.PubSub,
  live_view: [signing_salt: "kOKvb26h"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :nadia,
  token: {:system, "TELEGRAM_BOT_KEY"}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
