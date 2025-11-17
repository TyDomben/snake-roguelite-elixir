defmodule SnakeRogueliteWeb.CoreComponents do
  @moduledoc """
  Provides core UI components for the Snake Roguelite game.
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  Renders a button.
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-blue-600 hover:bg-blue-700",
        "py-2 px-3 text-sm font-semibold leading-6 text-white active:text-white/80",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders a simple form.
  """
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <%= render_slot(@inner_block, f) %>
      <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
        <%= render_slot(action, f) %>
      </div>
    </.form>
    """
  end

  @doc """
  Renders flash notices.
  """
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block)}
      id={"flash-#{@kind}"}
      class={[
        "fixed top-2 right-2 w-80 sm:w-96 z-50 rounded-lg p-3 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500",
        @kind == :error && "bg-rose-50 text-rose-900 ring-rose-500"
      ]}
      {@rest}
    >
      <p class="flex items-center gap-1.5 text-sm font-semibold leading-6">
        <%= msg %>
      </p>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.
  """
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"
  attr :flash, :map, required: true, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} {@rest}>
      <.flash kind={:info} phx-mounted={show("##{@id}")} phx-click={JS.push("lv:clear-flash", value: %{key: :info}) |> hide("#flash-info")} flash={@flash}>
        <%= @flash["info"] %>
      </.flash>
      <.flash kind={:error} phx-mounted={show("##{@id}")} phx-click={JS.push("lv:clear-flash", value: %{key: :error}) |> hide("#flash-error")} flash={@flash}>
        <%= @flash["error"] %>
      </.flash>
    </div>
    """
  end

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end
end
