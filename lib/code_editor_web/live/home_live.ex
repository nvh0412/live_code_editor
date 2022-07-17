defmodule CodeEditorWeb.HomeLive do
  use CodeEditorWeb, :live_view

  alias CodeEditor.{Sessions, Session}

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(initialized: false)
      |> assign_new(:language, fn -> "javascript" end)

    # Being duplicated session after refreshing the page
    # NOTE: Create a new session route
    Sessions.subscribe()
    {:ok, session } = Sessions.create_session()

    socket = assign(socket, session: session)

    {:ok, socket}
  end

  @impl true
  def handle_event("change_language", %{"language" => language}, socket) do
    {:noreply, assign(socket, :language, language)}
  end

  @impl true
  def handle_event("queue_code_evaluation", %{"editor_id" => editor_id}, socket) do
    ## Init a session process
    IO.inspect socket.assigns.session
    Session.queue_code_evaluation(socket.assigns.session.pid, editor_id)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    language = assigns.language

    editor_view = %{
      id: 1,
      type: :code,
    }

    source_init = """
    // the hello world program
    alert("Hello, World!");
    """

    source = 0..30
             |> Enum.to_list
             |> Enum.reduce(source_init, fn _x, acc -> "#{acc}\n" end)

    ~H"""
    <div class="flex"
      id={"session-1"}
      data-el-session
      phx-hook="Session"
    >
      <.live_component module={CodeEditorWeb.EditorLive.EditorComponent}
        id={"1"}
        language={language}
        source_view={%{"source" => source}},
        read_only={false}
        editor_view={editor_view}/>
    </div>
    """
  end
end
