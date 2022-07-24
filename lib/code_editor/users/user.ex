defmodule CodeEditor.Users.User do
  defstruct [:id, :name, :hex_color]

  alias CodeEditor.Utils

  def new() do
    %__MODULE__{
      id: Utils.random_id(),
      name: nil
    }
  end
end
