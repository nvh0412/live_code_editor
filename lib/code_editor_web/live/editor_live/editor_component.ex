defmodule CodeEditorWeb.EditorLive.EditorComponent do
  use CodeEditorWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, assign(socket, initialized: false)}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:read_only, fn -> false end)

    socket =
      if not connected?(socket) or socket.assigns.initialized do
        socket
      else
        socket
        |> push_event(
          "editor_init:#{socket.assigns.editor_view.id}",
          %{
            language: socket.assigns.language,
            read_only: socket.assigns.read_only
          }
        )
        |> assign(initialized: true)
      end

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col relative"
      data-el-cell
      id={"editor-#{@editor_view.id}"}
      data-editor-id={@editor_view.id}
      data-focusable-id={@editor_view.id}
    >
      <%= render_cell(assigns) %>
    </div>
    """
  end

  defp render_cell(%{editor_view: %{type: :code}} = assigns) do
    ~H"""
    <.cell_body>
      <div class="relative"
        id="editor-1"
        phx-update="ignore"
        phx-hook="CodeEditor">
        <div class="mt-4 py-3 rounded-lg bg-editor h-full" data-el-editor-container />
      </div>
    </.cell_body>
    """
  end

  defp cell_body(assigns) do
    ~H"""
    <!-- By setting tabindex we can programmatically focus this element,
         also we actually want to make this element tab-focusable -->
    <div class="flex relative" data-el-cell-body tabindex="0">
      <div class="w-1 h-full rounded-lg absolute top-0 -left-3" data-el-cell-focus-indicator>
      </div>
      <div class="w-full">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
