# Source File: mslists.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/impl/web_components/mslists.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.Impl.WebComponents.Mslists do
  use Phoenix.Component

  alias MscmpSystForms.Impl.WebComponents.Helpers
  alias MscmpSystForms.Types.ComponentConfig

  @moduledoc false

  @default_modes %{
    component_mode: :visible,
    border_mode: :none,
    text_mode: [],
    label_mode: []
  }

  @default_type :disc
  @default_layout ~w(flex flex-col)
  @default_alignment ~w(items-start justify-evenly)
  @default_list_sizing ~w(h-full w-full)
  @default_listitem_sizing ~w(h-full w-full)
  @default_spacing ~w(m-1)

  @ordered_list_types [
    :none_ordered,
    :disc_ordered,
    :circle_ordered,
    :decimal,
    :upper_roman,
    :lower_roman,
    :lower_alpha,
    :upper_alpha
  ]

  @unordered_list_types [
    :none,
    :disc,
    :circle,
    :decimal_unordered,
    :upper_roman_unordered,
    :lower_roman_unordered,
    :lower_alpha_unordered,
    :upper_alpha_unordered
  ]

  @allowed_list_types @ordered_list_types ++ @unordered_list_types

  attr(:id, :string)
  attr(:component_config, ComponentConfig)
  attr(:active_overrides, :list, default: [])
  attr(:type, :atom, default: @default_type, values: @allowed_list_types)
  attr(:modes, :map, default: @default_modes)
  attr(:layout, :list, default: @default_layout)
  attr(:alignment, :list, default: @default_alignment)
  attr(:sizing, :list, default: @default_list_sizing)
  attr(:spacing, :list, default: @default_spacing)
  attr(:extra_classes, :list, default: [])

  slot(:inner_block)

  def mslist(assigns) do
    resolved_id = Helpers.resolve_form_id(assigns)

    resolved_modes =
      Helpers.resolve_modes(
        assigns[:component_config],
        assigns.modes,
        @default_modes,
        assigns.active_overrides
      )

    resolved_classes =
      [
        assigns.extra_classes,
        get_component_classes(resolved_modes.component_mode),
        Helpers.get_border_classes(resolved_modes.border_mode),
        assigns.alignment,
        assigns.spacing,
        assigns.sizing,
        get_list_style_classes(assigns.type),
        assigns.layout
      ]
      |> List.flatten()
      |> Enum.filter(&is_binary/1)

    hidden = resolved_modes.component_mode == :removed

    assigns =
      assigns
      |> assign(:resolved_id, resolved_id)
      |> assign(:resolved_classes, resolved_classes)
      |> assign(:hidden, hidden)

    mslist(assigns.type, assigns)
  end

  def mslist(type, assigns) when type in @unordered_list_types do
    ~H"""
    <ul id={@resolved_id} class={@resolved_classes} hidden={@hidden == true}>
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  def mslist(type, assigns) when type in @ordered_list_types do
    ~H"""
    <ol id={@resolved_id} class={@resolved_classes} hidden={@hidden == true}>
      <%= render_slot(@inner_block) %>
    </ol>
    """
  end

  attr(:id, :string)
  attr(:modes, :map, default: @default_modes)
  attr(:component_config, ComponentConfig)
  attr(:active_overrides, :list, default: [])
  attr(:layout, :list, default: [])
  attr(:alignment, :list, default: @default_alignment)
  attr(:sizing, :list, default: @default_listitem_sizing)
  attr(:spacing, :list, default: @default_spacing)
  attr(:extra_classes, :list, default: [])

  slot(:inner_block)

  def mslistitem(assigns) do
    resolved_id = Helpers.resolve_form_id(assigns)

    resolved_modes =
      Helpers.resolve_modes(
        assigns[:component_config],
        assigns.modes,
        @default_modes,
        assigns.active_overrides
      )

    resolved_classes =
      [
        assigns.extra_classes,
        get_component_classes(resolved_modes.component_mode),
        Helpers.get_border_classes(resolved_modes.border_mode),
        Helpers.get_text_classes(resolved_modes.text_mode),
        assigns.alignment,
        assigns.spacing,
        assigns.sizing,
        assigns.layout
      ]
      |> List.flatten()
      |> Enum.filter(&is_binary/1)

    hidden = resolved_modes.component_mode == :removed

    assigns =
      assigns
      |> assign(:resolved_id, resolved_id)
      |> assign(:resolved_classes, resolved_classes)
      |> assign(:hidden, hidden)

    ~H"""
    <li id={@resolved_id} class={@resolved_classes} hidden={@hidden == true}>
      <%= render_slot(@inner_block) %>
    </li>
    """
  end

  defp get_component_classes(:removed), do: ~w(hidden)
  defp get_component_classes(mode) when mode in [:hidden, :cleared], do: ~w(invisible)
  defp get_component_classes(_), do: []

  defp get_list_style_classes(type) when type in [:none, :none_ordered], do: []

  defp get_list_style_classes(type) when type in [:disc, :disc_ordered],
    do: ~w(list-outside list-disc)

  defp get_list_style_classes(type) when type in [:circle, :circle_ordered],
    do: ~w(list-outside list-[cirle])

  defp get_list_style_classes(type) when type in [:decimal, :decimal_unordered],
    do: ~w(list-outside list-decimal)

  defp get_list_style_classes(type) when type in [:upper_roman, :upper_roman_unordered],
    do: ~w(list-outside list-[upper-roman])

  defp get_list_style_classes(type) when type in [:lower_roman, :lower_roman_unordered],
    do: ~w(list-outside list-[lower-roman])

  defp get_list_style_classes(type) when type in [:lower_alpha, :lower_alpha_unordered],
    do: ~w(list-outside list-[lower-alpha])

  defp get_list_style_classes(type) when type in [:upper_alpha, :upper_alpha_unordered],
    do: ~w(list-outside list-[upper-alpha])
end
