defmodule CodeEditorWeb.PageController do
  use CodeEditorWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
