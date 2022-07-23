defmodule CodeEditor.CodeView do
  defstruct [:views]

  def new(opts \\ []) do
    %__MODULE__{
      views: [%{ id: opts[:editor_view].id, editors: [] }]
    }
  end

  def all_views(codeview) do
    codeview.views
  end
end
