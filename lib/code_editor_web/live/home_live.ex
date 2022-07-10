defmodule CodeEditorWeb.HomeLive do
  use CodeEditorWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(initialized: false)
      |> assign_new(:language, fn -> "javascript" end)

    {:ok, socket}
  end

  @impl true
  def handle_event("change_language", %{"language" => language}, socket) do
    {:noreply, assign(socket, :language, language)}
  end

  @impl true
  def render(assigns) do
    language = assigns.language

    editor_view = %{
      id: 1,
      type: :code,
    }

    ~H"""
    <div class="flex">
      <.live_component module={CodeEditorWeb.EditorLive.EditorComponent}
        id={"1-primary"}
        language={language}
        read_only={false}
        editor_view={editor_view}/>
    </div>
    """
  end
end
