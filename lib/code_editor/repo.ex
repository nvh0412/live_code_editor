defmodule CodeEditor.Repo do
  use Ecto.Repo,
    otp_app: :code_editor,
    adapter: Ecto.Adapters.SQLite3
end
