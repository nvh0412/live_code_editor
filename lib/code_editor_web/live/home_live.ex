defmodule CodeEditorWeb.HomeLive do
  use CodeEditorWeb, :live_view

  alias CodeEditor.{Sessions, Data, Session, CodeView}

  @impl true
  def mount(_params, _session, socket) do
    editor_view = %{
      id: :first_view,
      type: :code,
    }

    socket =
      socket
      |> assign(initialized: false)
      |> assign(editor_view: editor_view)
      |> assign_new(:language, fn -> "javascript" end)

    # Being duplicated session after refreshing the page
    # NOTE: Create a new session route
    Sessions.subscribe()
    {:ok, session } = Sessions.create_session([editor_view: editor_view])

    Session.subscribe(session.id)

    socket = socket
             |> assign(session: session)
             |> assign_private(data: Data.new(CodeView.new([editor_view: editor_view])))

    {:ok, socket}
  end

  @impl true
  def handle_event("change_language", %{"language" => language}, socket) do
    {:noreply, assign(socket, :language, language)}
  end

  @impl true
  def handle_event("queue_code_evaluation", %{"editor_id" => editor_id}, socket) do
    ## Init a session process
    Session.queue_code_evaluation(socket.assigns.session.pid, editor_id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("apply_view_delta", %{"editor_id" => editor_id, "delta" => delta}, socket) do
    Session.apply_view_delta(socket.assigns.session.pid, editor_id, delta)
    {:noreply, socket}
  end

  def handle_info({:operation, operation}, socket) do
    {:noreply, handle_operation(socket, operation)}
  end

  defp handle_operation(socket, operation) do
    case Data.apply_operation(socket.private.data, operation) do
      {:ok, data, actions} ->
        socket
        |> assign_private(data: data)
        |> after_operation(socket, operation)
        |> handle_actions(actions)
      :error ->
        socket
    end
  end

  defp after_operation(socket, _prev_socket, _operation), do: socket

  defp handle_actions(socket, actions) do
    Enum.reduce(actions, socket, &handle_action(&2, &1))
  end

  defp handle_action(socket, {:broadcast_delta, client_pid, editor_id, delta}) do
    if client_pid == self() do
      push_event(socket, "editor_acknowledgement:#{editor_id}", %{})
    else
      push_event(socket, "editor_delta:#{editor_id}", %{delta: delta})
    end
  end

  def handle_info(_message, socket), do: {:noreply, socket}

  defp handle_operation(socket, operation) do
    socket
  end

  defp assign_private(socket, assigns) do
    Enum.reduce(assigns, socket, fn {key, value}, socket ->
      put_in(socket.private[key], value)
    end)
  end

  @impl true
  def render(assigns) do
    language = assigns.language

    ~H"""
    <div class="flex"
      id={"session-1"}
      data-el-session
      phx-hook="Session"
    >
      <.live_component module={CodeEditorWeb.EditorLive.EditorComponent}
        id={"1"}
        language={language}
        source_view={%{"source" => ""}},
        read_only={false}
        editor_view={assigns.editor_view}/>
    </div>
    """
  end
end
