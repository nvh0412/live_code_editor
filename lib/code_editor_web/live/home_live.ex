defmodule CodeEditorWeb.HomeLive do
  use CodeEditorWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, initialized: false)}
  end

  @impl true
  def render(assigns) do
    editor_view = %{
      id: 1,
      type: :code
    }

    ~H"""
    <div class="flex">
      <.live_component module={CodeEditorWeb.EditorLive.EditorComponent}
        id={"1-primary"}
        language={"ruby"}
        read_only={false}
        editor_view={editor_view}/>
    </div>
    """
  end
end
