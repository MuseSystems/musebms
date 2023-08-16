# Source File: msdisplays.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/impl/web_components/msdisplays.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.Impl.WebComponents.Msdisplays do
  alias MscmpSystForms.Impl.WebComponents.Helpers
  alias MscmpSystForms.Types.ComponentConfig

  use Phoenix.Component

  @moduledoc false

  @default_type :text
  @default_layout ~w(flex flex-row)
  @default_alignment ~w(text-start)
  @default_spacing ~w(m-1)

  attr(:id, :string)
  attr(:component_config, ComponentConfig)
  attr(:active_overrides, :list, default: [])
  attr(:type, :atom, default: @default_type, values: ~w(text title subtitle)a)
  attr(:modes, :map, default: %{})
  attr(:layout, :list, default: @default_layout)
  attr(:alignment, :list, default: @default_alignment)
  attr(:sizing, :list)
  attr(:spacing, :list, default: @default_spacing)
  attr(:extra_classes, :list, default: [])

  slot(:inner_block)

  def msdisplay(assigns) do
    default_modes = get_default_modes(assigns.type)

    resolved_id = Helpers.resolve_form_id(assigns)

    resolved_modes =
      Helpers.resolve_modes(
        assigns[:component_config],
        assigns.modes,
        default_modes,
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
        assigns[:sizing] || get_default_sizing(assigns.type),
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

    msdisplay(assigns.type, assigns)
  end

  defp msdisplay(:text, assigns) do
    ~H"""
    <p id={@resolved_id} class={@resolved_classes} hidden={@hidden == true}><%= render_slot(@inner_block) %></p>
    """
  end

  defp msdisplay(:title, assigns) do
    ~H"""
    <h1 id={@resolved_id} class={@resolved_classes} hidden={@hidden == true}><%= render_slot(@inner_block) %></h1>
    """
  end

  defp msdisplay(:subtitle, assigns) do
    ~H"""
    <h3 id={@resolved_id} class={@resolved_classes} hidden={@hidden == true}><%= render_slot(@inner_block) %></h3>
    """
  end

  defp get_default_modes(type) when type in [:title, :subtitle] do
    %{
      component_mode: :visible,
      border_mode: :none,
      text_mode: :emphasis,
      label_mode: :normal
    }
  end

  defp get_default_modes(_) do
    %{
      component_mode: :visible,
      border_mode: :none,
      text_mode: :normal,
      label_mode: :normal
    }
  end

  defp get_component_classes(:removed), do: ~w(hidden)
  defp get_component_classes(mode) when mode in [:hidden, :cleared], do: ~w(invisible)
  defp get_component_classes(_), do: []

  defp get_default_sizing(:title), do: ~w(text-2xl)
  defp get_default_sizing(:subtitle), do: ~w(text-xl)
  defp get_default_sizing(_), do: ~w(text-base)
end
