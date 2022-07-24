defmodule CodeEditor.CodeView do
  defstruct [:views]

  def new(opts \\ []) do
    case opts[:editor_view] do
      %{id: id} when id != nil ->
        %__MODULE__{
          views: [%{ id: opts[:editor_view].id, editors: [] }]
        }
      _ ->
        %__MODULE__{
          views: [%{ id: nil, editors: [] }]
        }
    end
  end

  def all_views(codeview) do
    codeview.views
  end
end
