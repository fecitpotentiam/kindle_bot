defmodule TelegramBotWeb.PageController do
  use TelegramBotWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
