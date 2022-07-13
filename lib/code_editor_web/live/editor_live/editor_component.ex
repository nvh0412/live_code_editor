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
        |> push_event(
          "editor_update:#{socket.assigns.editor_view.id}",
          %{
            editorId: socket.assigns.editor_view.id,
            language: socket.assigns.language
          }
        )
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
    <div class="relative w-full"
      data-el-cell
      id={"container-#{@editor_view.id}"}
    >
      <%= render_editor(assigns) %>
    </div>
    """
  end

  defp render_editor(%{editor_view: %{type: :code}} = assigns) do
    ~H"""
    <div class="flex justify-end">
      <.menu id={"menu-#{@editor_view.id}"}>
        <:toggle>
          <button class="button-base w-28"><%= String.capitalize(assigns.language) %></button>
        </:toggle>
        <:content>
          <button
            class="menu-item" role="menuitem"
            phx-click="change_language"
            phx-value-language="ruby"
          ><i class="devicon-ruby-plain mr-1 text-red-600"/>Ruby</button>
          <button
            class="menu-item" role="menuitem"
            phx-click="change_language"
            phx-value-language="javascript"
          ><i class="devicon-javascript-plain mr-1 text-yellow-600"/>Javascript</button>
          <button
            class="menu-item" role="menuitem"
            phx-click="change_language"
            phx-value-language="sql"
          ><i class="ri-database-2-line mr-1 text-gray-600"/>SQL</button>
        </:content>
      </.menu>
    </div>
    <.cell_body>
      <div class="relative"
        id="editor-container"
        phx-update="ignore"
        data-editor-id={@editor_view.id}
        data-focusable-id={@editor_view.id}
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
    <div class="flex relative w-full" data-el-cell-body tabindex="0">
      <div class="w-full">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
