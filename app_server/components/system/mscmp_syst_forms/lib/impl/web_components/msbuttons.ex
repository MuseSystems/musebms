# Source File: msbuttons.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/impl/web_components/msbuttons.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.Impl.WebComponents.Msbuttons do
  use Phoenix.Component

  alias MscmpSystForms.Impl.WebComponents
  alias MscmpSystForms.Impl.WebComponents.Helpers
  alias MscmpSystForms.Types.ComponentConfig
  alias MscmpSystForms.Impl.WebComponents.Helpers.Js

  @default_modes %{
    component_mode: :visible,
    border_mode: :none,
    text_mode: :normal,
    label_mode: :normal
  }

  @default_type :standard
  @default_layout ~w(flex flex-row)
  @default_alignment ~w(text-start place-self-center)
  @default_spacing ~w(m-1 py-2 px-8)
  @default_sizing ~w(h-min w-min)

  attr(:id, :string)
  attr(:component_config, ComponentConfig)
  attr(:active_overrides, :list, default: [])
  attr(:title, :string, required: true)
  attr(:type, :atom, default: @default_type, values: ~w(standard form_submit)a)
  attr(:modes, :map, default: %{})
  attr(:click_action, :string, default: nil)
  attr(:layout, :list, default: @default_layout)
  attr(:alignment, :list, default: @default_alignment)
  attr(:sizing, :list, default: @default_sizing)
  attr(:spacing, :list, default: @default_spacing)
  attr(:extra_classes, :list, default: [])

  def msbutton(assigns) do
    resolved_id = Helpers.resolve_form_id(assigns)

    resolved_modes =
      Helpers.resolve_modes(
        assigns[:component_config],
        assigns.modes,
        @default_modes,
        assigns.active_overrides
      )

    resolved_classes = [
      assigns.layout,
      assigns.alignment,
      assigns.sizing,
      assigns.spacing,
      ~w(
        phx-submit-loading:opacity-75 
        bg-zinc-500 
        hover:bg-zinc-400 
        py-2 px-3 
        disabled:bg-zinc-200
        disabled:ring-zinc-500
        focus:ring-4
        focus:ring-zinc-800),
      get_border_classes(resolved_modes.border_mode),
      get_labeltext_classes(resolved_modes.label_mode),
      get_component_classes(resolved_modes.component_mode),
      assigns.extra_classes
    ]

    assigns =
      assigns
      |> assign(:resolved_id, resolved_id)
      |> assign(:resolved_classes, resolved_classes)
      |> assign(:html_type, if(assigns.type == :form_submit, do: "submit", else: "button"))
      |> maybe_assign_disabled(resolved_modes.component_mode)
      |> maybe_assign_hidden(resolved_modes.component_mode)

    ~H"""
    <button
      id={@resolved_id}
      type={@html_type}
      class={@resolved_classes}
      phx-click={@click_action}
      disabled={@disabled == true}
      hidden={@hidden == true}>
      <%= @title %>
    </button>
    """
  end

  defp maybe_assign_disabled(assigns, :visible), do: assign(assigns, :disabled, true)
  defp maybe_assign_disabled(assigns, _), do: assign(assigns, :disabled, false)

  defp maybe_assign_hidden(assigns, :removed), do: assign(assigns, :hidden, true)
  defp maybe_assign_hidden(assigns, _), do: assign(assigns, :hidden, false)

  attr(:id, :string)
  attr(:component_config, ComponentConfig)
  attr(:form_module, :atom, required: true)
  attr(:active_overrides, :list, default: [])
  attr(:type, :atom, default: @default_type, values: ~w(standard form_submit)a)
  attr(:modes, :map, default: %{})
  attr(:button_state, :atom, values: ~w(action processing message)a)
  attr(:click_action, :string, default: nil)
  attr(:layout, :list, default: @default_layout)
  attr(:alignment, :list, default: @default_alignment)
  attr(:sizing, :list, default: @default_sizing)
  attr(:spacing, :list, default: @default_spacing)
  attr(:extra_classes, :list, default: [])

  slot :action do
    attr(:title, :string)
    attr(:show_icon, :boolean)
  end

  slot :processing do
    attr(:title, :string)
    attr(:show_icon, :boolean)
  end

  slot :message do
    attr(:title, :string)
    attr(:show_icon, :boolean)
    attr(:message_title, :string)
    attr(:message_items, :list)
    attr(:message_text, :string)
    attr(:line_title_label, :string)
    attr(:line_item_label, :string)
    attr(:form_data_def, :map)
  end

  def msvalidated_button(assigns) do
    resolved_id = Helpers.resolve_form_id(assigns)

    # We'll handle the active_overrides directly in this component since v
    # validated buttons have a button state which already has a processing
    # appropriate class set and since we need to set the button state 
    # appropriately.  This means the button state should normally not be set
    # to `:processing`, but should remain either `:action` or `message` and 
    # allow the `:active_overrides` evaluation to cause the button state to 
    # end up in `:processing`.

    resolved_modes =
      Helpers.resolve_modes(assigns[:component_config], assigns.modes, @default_modes, [])

    button_state = resolve_button_state(assigns, assigns.active_overrides)

    component_classes = [
      assigns.layout,
      assigns.alignment,
      assigns.sizing,
      assigns.spacing
    ]

    resolved_classes = [
      ~w(
        phx-submit-loading:opacity-75 
        bg-zinc-500 
        hover:bg-zinc-400 
        py-2 px-3 
        disabled:bg-zinc-200
        disabled:ring-zinc-500
        focus:ring-4
        focus:ring-zinc-800),
      get_border_classes(resolved_modes.border_mode),
      get_labeltext_classes(resolved_modes.label_mode),
      get_component_classes(resolved_modes.component_mode),
      assigns.extra_classes
    ]

    first_action = List.first(assigns.action)
    first_processing = List.first(assigns.processing)
    first_message = List.first(assigns.message)

    assigns =
      assigns
      |> assign(first_action: first_action)
      |> assign_new(
        :resolved_click_action,
        fn ->
          resolve_click_action(button_state, resolved_id, assigns.click_action)
        end
      )
      |> assign_new(:show_action_icon, fn -> Map.get(first_action, :show_icon, false) end)
      |> assign_new(:button_state, fn -> button_state end)
      |> assign(:html_type, resolve_button_type(assigns.type, button_state))
      |> assign(first_processing: first_processing)
      |> assign_new(:show_processing_icon, fn -> Map.get(first_processing, :show_icon, false) end)
      |> assign(first_message: first_message)
      |> assign_new(:show_message_icon, fn -> Map.get(first_message, :show_icon, false) end)
      |> assign_new(:message_title, fn -> Map.get(first_message, :message_title, "Error") end)
      |> assign_new(:condensed_messages, fn ->
        Map.get(first_message, :message_items, nil)
        |> condense_message_items(assigns.form_module)
      end)
      |> assign_new(:message_text, fn -> Map.get(first_message, :message_text, nil) end)
      |> assign_new(:line_title_label, fn -> Map.get(first_message, :line_title_label, nil) end)
      |> assign_new(:line_item_label, fn -> Map.get(first_message, :line_item_label, nil) end)
      |> assign_new(:form_data_def, fn -> Map.get(first_message, :form_data_def, nil) end)
      |> maybe_assign_validated_disabled(resolved_modes.component_mode, button_state)
      |> assign(:component_classes, component_classes)
      |> assign(:resolved_classes, resolved_classes)
      |> assign(:resolved_id, resolved_id)

    ~H"""
    <div id={@resolved_id} class={@component_classes}>
      <button
        id={"#{@resolved_id}-button"}
        type={@html_type}
        class={@resolved_classes}
        phx-click={@resolved_click_action}
        disabled={@button_disabled == true}
        >
        <div class="flex space-x-2">
          <%= case @button_state do %>
            <% :action -> %>
              <p><%= @first_action.title %></p>
              <svg
                :if={@show_action_icon}
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 20 20"
                class="w-5 h-5 fill-green-600 stroke-white"
              >
                <path
                  fill-rule="evenodd"
                  d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 001.137-.089l4-5.5z"
                  clip-rule="evenodd"
                />
              </svg>
            <% :processing -> %>
              <p><%= @first_processing.title %></p>
              <svg
                :if={@show_processing_icon}
                class="animate-spin -ml-1 mr-3 h-5 w-5 text-white "
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
              >
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
                </circle>
                <path
                  class="opacity-75"
                  fill="currentColor"
                  d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                >
                </path>
              </svg>
            <% :message -> %>
              <p><%= @first_message.title %></p>
              <svg
                :if={@show_message_icon}
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 20 20"
                class="w-5 h-5 fill-red-600 stroke-white"
              >
                <path
                  fill-rule="evenodd"
                  d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-5a.75.75 0 01.75.75v4.5a.75.75 0 01-1.5 0v-4.5A.75.75 0 0110 5zm0 10a1 1 0 100-2 1 1 0 000 2z"
                  clip-rule="evenodd"
                />
              </svg>
          <% end %>
        </div>
      </button>
      <WebComponents.Msmodals.msmodal id={"#{@resolved_id}-validation-modal"}>
        <:title><%= @message_title %></:title>
        <p :if={@message_text} class="mt-4"><%= @message_text %></p>
        <div :if={@condensed_messages} class="m-4 mt-14 ">
          <dl class="-my-4 divide-y divide-zinc-100">
            <div class="flex gap-4 py-4 sm:gap-8">
              <dt class="w-1/4 flex-none font-black text-[0.8125rem] leading-6 text-zinc-800">
                <%= @line_title_label %>
              </dt>
              <dd class="font-black text-sm leading-6 text-zinc-800"><%= @line_item_label %></dd>
            </div>
            <div
              :for={item <- @condensed_messages}
              class="flex gap-4 py-4 sm:gap-8">
              <dt class="w-1/4 flex-none text-[0.8125rem] leading-6 text-zinc-500">
                <%= item.label %>
              </dt>
              <dd class="text-sm leading-6 text-zinc-700"><%= item.message_text %></dd>
            </div>
          </dl>
        </div>
      </WebComponents.Msmodals.msmodal>
    </div>
    """
  end

  defp resolve_button_state(
         %{component_config: %ComponentConfig{overrides: overrides}} = assigns,
         [_ | _] = active_overrides
       ) do
    if Enum.any?(active_overrides, &Enum.member?(overrides, &1)) do
      :processing
    else
      resolve_button_state(assigns)
    end
  end

  defp resolve_button_state(assigns, _), do: resolve_button_state(assigns)

  defp resolve_button_state(%{component_config: %ComponentConfig{button_state: button_state}})
       when button_state in [:action, :processing, :message],
       do: button_state

  defp resolve_button_state(%{button_state: button_state})
       when button_state in [:action, :processing, :message],
       do: button_state

  defp resolve_button_state(assigns) do
    raise MscmpSystError,
      code: :undefined_error,
      message:
        "Validated button state not found.  Validated button components require a button state to be passed as part of the render config attribute or as the 'button_state' attribute.",
      cause: %{params: %{assigns: assigns}}
  end

  defp resolve_button_type(:form_submit, :action), do: "submit"
  defp resolve_button_type(_, _), do: "button"

  defp resolve_click_action(:action, _resolved_id, action), do: action

  defp resolve_click_action(:message, resolved_id, _),
    do: Js.show_modal("#{resolved_id}-validation-modal")

  defp resolve_click_action(:processing, _, _), do: false

  defp condense_message_items([{_, _} | _] = message_items, form_module) do
    message_items
    |> Keyword.keys()
    |> Enum.uniq()
    |> Enum.reduce([], fn binding_id, acc ->
      message_item_text =
        Keyword.get_values(message_items, binding_id)
        |> Enum.map(&Helpers.translate_error(&1))
        |> Enum.join("<br/>")

      message_item_label =
        MscmpSystForms.get_component_info(form_module, %{binding_id: binding_id})
        |> then(&(&1[:label] || ""))

      [%{label: message_item_label, message_text: message_item_text} | acc]
    end)
  end

  defp condense_message_items(message_items, _), do: message_items

  defp maybe_assign_validated_disabled(assigns, :entry, :action),
    do: assign(assigns, :button_disabled, false)

  defp maybe_assign_validated_disabled(assigns, :entry, :message),
    do: assign(assigns, :button_disabled, false)

  defp maybe_assign_validated_disabled(assigns, _, _),
    do: assign(assigns, :button_disabled, true)

  defp get_component_classes(:removed), do: ~w(hidden)
  defp get_component_classes(:hidden), do: ~w(invisible)

  defp get_component_classes(mode) when mode in [:cleared, :processing, :visible],
    do: ~w()

  defp get_component_classes(_), do: []

  defp get_border_classes(_) do
    ~w(rounded-lg border-2 border-zinc-900)
  end

  defp get_labeltext_classes(_) do
    ~w(text-sm font-semibold leading-6 text-white active:text-white/80 disabled:text-zinc-400)
  end
end
