defmodule TelegramBotWeb.TelegramController do
  @moduledoc """
  Логика обработки входящих сообщений.
  """

  @vsn 0.1

  use TelegramBotWeb, :controller

  @doc """
  Принимает документ от конкретного пользователя и пересылает его на указанный адрес
  электронной почты. Конвертирует .epub в .mobi. Отправляет отчет о проделанной работе,
  а также сведения об ошибках пользователю.
  """
  def update(conn, %{"message" => message = %{"chat" => %{"id" => chat_id}}} = params) do
    document = Map.get(message, "document")

    {owner_chat_id, _} = Integer.parse(System.get_env("OWNER_TELEGRAM_ID"))

    message_text = if chat_id == owner_chat_id do
      message_text = if document != :nil do
        file_name = redirect_document_by_mail(document)
        message_text = file_name <> " был отправлен на Kindle"
      else
        message_text = "Пожалуйста, прикрепите документ к вашему сообщению"
      end

    else
      message_text = "Ошибка авторизации"
    end

    Nadia.send_message(chat_id, message_text)
    send_response(conn)
  end

  @doc """
  Обрабатывает и перенаправляет входящий документ на указанный адрес электронной почты,
  удаляет после отправки
  """
  def redirect_document_by_mail(document) do
    {file_name, old_file_name} = handle_document(document)
    :ok = TelegramBot.Email.send_file(file_name)
    :ok = add_to_trello(document["file_name"])
    delete_documents(file_name, old_file_name)
    file_name
  end

  @doc """
  Обрабатывает входящий документ - приводит название документа к единой форме, сохраняет его и конвертирует
  (в случае с форматом epub).
  """
  def handle_document(document) do
    file_path = get_file_path(document)
    file_name = old_file_name = normalize_filename(document["file_name"])
    :ok = save_document(file_path, file_name)
    file_name = if String.contains? file_name, ".epub" do convert_ebook(file_name) else old_file_name end

    {file_name, old_file_name}
  end

  @doc """
  Получает ссылку на скачивание документа.
  """
  def get_file_path(document) do
    {:ok, file} = Nadia.get_file(document["file_id"])
    file.file_path
  end

  @doc """
  Приводит имя документа к единой форме, удаляет лишние знаки препинания и транслитерирует
  заголовки на русском.
  """
  def normalize_filename(file_name) do
    String.replace(file_name, "_", " ")
    |> Russian.transliterate
  end

  @doc """
  Скачивает документ по ссылке и сохраняет его.
  """
  def save_document(file_path, file_name) do
    url = "https://api.telegram.org/file/bot" <> Nadia.Config.token() <> "/" <> file_path
    %HTTPoison.Response{body: body} = HTTPoison.get!(url)
    File.write!("data/" <> file_name, body)
    :ok
  end

  @doc """
  Конвертирует epub в mobi с помощью calibre
  """
  def convert_ebook(file_name) do
      converted_filename = String.replace(file_name, ".epub", ".mobi")
      System.cmd("ebook-convert", ["data/" <> file_name, "data/" <> converted_filename])
      converted_filename
  end

  @doc """
  Удаляет документы после отправки.
  """
  def delete_documents(file_name, old_file_name) do
    File.rm("data/" <> file_name)
    File.rm("data/" <> old_file_name)
    :ok
  end

  @doc """
  Отправляет ответ, что обработка сообщения прошла успешно.
  """
  def send_response(conn) do
    conn
    |> render(:update)
    |> halt
  end

  @doc """
  Добавляет карточку с названием книги в список Trello
  """
  def add_to_trello(file_name) do
    book_name = String.replace(file_name, ".mobi", "")
    book_name = String.replace(book_name, ".pdf", "")

    params =
      %{"key" => System.get_env("TRELLO_API_KEY"),
        "token" => System.get_env("TRELLO_API_TOKEN"),
        "idList" => System.get_env("TRELLO_LIST_ID"),
        "name" => book_name}
      |> URI.encode_query

    {:ok, _response} =
      HTTPoison.post(
        "https://api.trello.com/1/cards",
        params,
        %{"Content-Type" => "application/x-www-form-urlencoded"}
      )
    :ok
  end

  def to_text(file_name) do
    System.cmd("pdftotext", ["data/" <> file_name])
    :ok
  end

end