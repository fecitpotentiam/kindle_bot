defmodule TelegramBot.Email do
  @moduledoc """
  Модуль работы с электронной почтой
  """

  @vsn 0.1

  use Bamboo.Phoenix, view: TelegramBot.EmailView

  @doc """
  Отправляет документ по указанному адресу электронной почты
  """
  def send_file(file_name) do
    attachment = Bamboo.Attachment.new("data/" <> file_name)
    new_email()
    |> to(System.get_env("EMAIL_TO"))
    |> from(System.get_env("EMAIL_FROM"))
    |> subject("convert")
    |> text_body("Book")
    |> put_attachment(attachment)
    |> TelegramBot.Mailer.deliver_now()
    :ok
  end

end