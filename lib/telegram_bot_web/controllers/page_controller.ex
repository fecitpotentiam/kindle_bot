defmodule TelegramBotWeb.PageController do
  use TelegramBotWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def post(conn, params) do
    IO.inspect conn
    IO.inspect params
  end
end
