# Source File: mscontainers.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/impl/web_components/mscontainers.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.Impl.WebComponents.Mscontainers do
  use Phoenix.Component

  alias MscmpSystForms.Impl.WebComponents.Helpers
  alias MscmpSystForms.Types
  alias MscmpSystForms.Types.ComponentConfig

  @default_modes %{
    component_mode: :entry,
    border_mode: :none,
    text_mode: [],
    label_mode: []
  }

  @default_layout ~w(flex flex-row)
  @default_alignment ~w(items-start justify-items-start)
  @default_sizing ~w(h-full w-full)
  @default_spacing ~w(m-1 p-2)
  @default_type :standard

  attr(:id, :string)
  attr(:component_config, ComponentConfig)
  attr(:active_overrides, :list, default: [])
  attr(:modes, :map, default: @default_modes)
  attr(:type, :atom, default: @default_type, values: ~w(standard fieldset)a)
  attr(:layout, :list, default: @default_layout)
  attr(:alignment, :list, default: @default_alignment)
  attr(:sizing, :list, default: @default_sizing)
  attr(:spacing, :list, default: @default_spacing)
  attr(:extra_classes, :list, default: [])

  slot(:inner_block)

  def mscontainer(assigns) do
    resolved_id = Helpers.resolve_form_id(assigns)

    resolved_modes =
      Helpers.resolve_modes(
        assigns[:component_config],
        assigns.modes,
        @default_modes,
        assigns.active_overrides
      )

    resolved_class =
      [
        assigns.extra_classes,
        get_component_classes(resolved_modes.component_mode),
        Helpers.get_border_classes(resolved_modes.border_mode),
        assigns.alignment,
        assigns.spacing,
        assigns.sizing,
        assigns.layout
      ]
      |> List.flatten()
      |> Enum.filter(&is_binary/1)

    disabled = resolved_modes.component_mode == :visible
    hidden = resolved_modes.component_mode == :removed

    assigns
    |> assign(:resolved_id, resolved_id)
    |> assign(:resolved_class, resolved_class)
    |> assign(:disabled, disabled)
    |> assign(:hidden, hidden)
    |> mscontainer(assigns.type)
  end

  defp mscontainer(assigns, :standard) do
    ~H"""
    <div id={@resolved_id} class={@resolved_class} hidden={@hidden == true}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp mscontainer(assigns, :fieldset) do
    ~H"""
    <fieldset id={@resolved_id} class={@resolved_class} disabled={@disabled == true} hidden={@hidden == true}>
      <%= render_slot(@inner_block) %>
    </fieldset>
    """
  end

  defp get_component_classes(:removed), do: ~w(hidden)
  defp get_component_classes(mode) when mode in [:hidden, :cleared], do: ~w(invisible)
  defp get_component_classes(_), do: []
end
