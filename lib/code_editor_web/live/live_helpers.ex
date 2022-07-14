defmodule CodeEditorWeb.LiveHelpers do
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  def menu(assigns) do
    assigns =
      assigns
      |> assign_new(:disabled, fn -> false end)
      |> assign_new(:position, fn -> "bottom-right" end)
      |> assign_new(:secondary_click, fn -> false end)

    ~H"""
      <div class="menu" id={@id}>
        <div
          phx-click={JS.add_class("menu--open", to: "[id^='#{@id}']")}
          phx-window-keydown={JS.remove_class("menu--open", to: "[id^='#{@id}']")}
          phx-key="escape">
          <%= render_slot(@toggle) %>
        </div>
        <menu
          class="menu__content mt-0.5"
          role="menu"
          phx-click-away={JS.remove_class("menu--open", to: "[id^='#{@id}']")}}
        >
          <%= render_slot(@content) %>
        </menu>
      </div>
    """
  end

  def remix_icon(assigns) do
    assigns = assigns
              |> assign_new(:class, fn -> "" end)
              |> assign(:attrs, assigns_to_attributes(assigns, [:icon, :class]))

    ~H"""
    <i class={"ri-#{@icon} #{@class}"} aria-hidden="true" {@attrs}></i>
    """
  end
end

