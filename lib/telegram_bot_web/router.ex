defmodule TelegramBotWeb.Router do
  use TelegramBotWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :telegram do
    plug :accepts, ["json"]
    plug TelegramBot.BotToken
    plug Plug.Parsers,
         parsers: [:urlencoded, :json],
         json_decoder: {Jason, :decode!, [[keys: :atoms]]},
         pass: ["*/*"]
  end

  scope "/webhook/:bot_token", TelegramBotWeb do
    pipe_through :telegram

    post "/", TelegramController, :update
  end

  scope "/", TelegramBotWeb do
    pipe_through :telegram

    get "/", PageController, :index
    post "/", TelegramController, :update
  end

  # Other scopes may use custom stacks.
  # scope "/api", TelegramBotWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: TelegramBotWeb.Telemetry
    end
  end
end
