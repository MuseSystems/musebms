# Source File: mssections.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/impl/web_components/mssections.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.Impl.WebComponents.Mssections do
  use Phoenix.Component

  alias MscmpSystForms.Impl.WebComponents.Helpers
  alias MscmpSystForms.Types.ComponentConfig

  @moduledoc false

  @default_modes %{
    component_mode: :entry,
    border_mode: :normal,
    text_mode: :normal
  }

  @default_component_layout ~w()
  @default_component_alignment ~w()
  @default_component_sizing ~w(h-full w-full)
  @default_component_spacing ~w()

  @default_labeltext_layout ~w(grow-0)
  @default_labeltext_alignment ~w()
  @default_labeltext_sizing ~w()
  @default_labeltext_spacing ~w(py-1 px-4)

  @default_container_layout ~w(flex flex-col)
  @default_container_alignment ~w()
  @default_container_sizing ~w()
  @default_container_spacing ~w(gap-2)

  attr(:id, :string)
  attr(:component_config, ComponentConfig)
  attr(:active_overrides, :list, default: [])
  attr(:modes, :map, default: @default_modes)

  attr(:type, :atom,
    default: :normal,
    values: ~w(deemphasis reference normal emphasis warning alert approve deny info)a
  )

  attr(:layout, :list, default: @default_component_layout)
  attr(:alignment, :list, default: @default_component_alignment)
  attr(:sizing, :list, default: @default_component_sizing)
  attr(:spacing, :list, default: @default_component_spacing)
  attr(:extra_classes, :list, default: [])

  attr(:title, :string, required: true)

  slot(:inner_block)

  def mssection(assigns) do
    resolved_id = Helpers.resolve_form_id(assigns)

    resolved_modes =
      Helpers.resolve_modes(
        assigns[:component_config],
        assigns.modes,
        @default_modes,
        assigns.active_overrides
      )

    assigns.type

    component_classes = [
      assigns.layout,
      assigns.alignment,
      assigns.sizing,
      assigns.spacing,
      "border-2",
      "rounded-md",
      get_border_classes(assigns.type),
      get_component_mode_classes(resolved_modes.component_mode)
    ]

    labeltext_classes = [
      @default_labeltext_layout,
      @default_labeltext_alignment,
      @default_labeltext_sizing,
      @default_labeltext_spacing,
      "border-1",
      "rounded-br-md",
      get_label_classes(assigns.type)
    ]

    container_classes = [
      @default_container_layout,
      @default_container_alignment,
      @default_container_sizing,
      @default_container_spacing,
      Helpers.get_text_classes(resolved_modes.text_mode),
      assigns.extra_classes
    ]

    hidden = resolved_modes.component_mode == :removed

    assigns =
      assigns
      |> assign(:resolved_id, resolved_id)
      |> assign(:component_classes, component_classes)
      |> assign(:container_classes, container_classes)
      |> assign(:labeltext_classes, labeltext_classes)
      |> assign(:hidden, hidden)

    ~H"""
    <section id={@resolved_id} class={@component_classes} hidden={@hidden == true}>
      <div id={"#{@resolved_id}-label"} class="flex">
        <div id={"#{@resolved_id}-labeltext"} class={@labeltext_classes}>
          <%= @title %>
        </div>
        <div class="grow" />
      </div>
      <div id={"#{@resolved_id}-container"} class={@container_classes}>
        <%= render_slot(@inner_block) %>
      </div>
    </section>
    """
  end

  defp get_component_mode_classes(mode) when mode in [:hidden, :cleared], do: ~w(invisible)
  defp get_component_mode_classes(_), do: []

  # TODO: get_border_classes/1 here is a bit of a hack.  The double border in
  #       the helper border class definition doesn't work well for our section
  #       component.  While the local exceptions below get us around that
  #       formatting issue, it defeats our "single place of definition" goal.

  defp get_border_classes([_ | _] = classes), do: Helpers.get_border_classes(classes)
  defp get_border_classes(:deemphasis), do: ~w(border-2 border-color-deemphasis)
  defp get_border_classes(:reference), do: ~w(border-2 border-color-reference)
  defp get_border_classes(:normal), do: ~w(border-2 border-color-reference)
  defp get_border_classes(:emphasis), do: ~w(border-2 border-color-emphasis)
  defp get_border_classes(:warning), do: ~w(border-2 border-color-warning)
  defp get_border_classes(:alert), do: ~w(border-2 border-color-alert)
  defp get_border_classes(:approve), do: ~w(border-2 border-color-approve)
  defp get_border_classes(:deny), do: ~w(border-2 border-color-deny)
  defp get_border_classes(:info), do: ~w(border-2 border-color-info)
  defp get_border_classes(mode), do: Helpers.get_border_classes(mode)

  defp get_label_classes(:deemphasis) do
    [
      Helpers.get_border_classes(:deemphasis),
      Helpers.get_background_classes(:deemphasis),
      Helpers.get_label_classes(:normal)
    ]
  end

  defp get_label_classes(:reference) do
    [
      Helpers.get_border_classes(:reference),
      Helpers.get_background_classes(:reference),
      Helpers.get_label_classes(:normal)
    ]
  end

  defp get_label_classes(:normal) do
    [
      Helpers.get_border_classes(:normal),
      Helpers.get_background_classes(:normal),
      Helpers.get_label_classes(:normal)
    ]
  end

  defp get_label_classes(:emphasis) do
    [
      Helpers.get_border_classes(:emphasis),
      Helpers.get_background_classes(:emphasis),
      Helpers.get_label_classes(:normal, :inverted)
    ]
  end

  defp get_label_classes(:warning) do
    [
      Helpers.get_border_classes(:warning),
      Helpers.get_background_classes(:warning),
      Helpers.get_label_classes(:normal, :inverted)
    ]
  end

  defp get_label_classes(:alert) do
    [
      Helpers.get_border_classes(:alert),
      Helpers.get_background_classes(:alert),
      Helpers.get_label_classes(:normal, :inverted)
    ]
  end

  defp get_label_classes(:approve) do
    [
      Helpers.get_border_classes(:approve),
      Helpers.get_background_classes(:approve),
      Helpers.get_label_classes(:normal, :inverted)
    ]
  end

  defp get_label_classes(:deny) do
    [
      Helpers.get_border_classes(:deny),
      Helpers.get_background_classes(:deny),
      Helpers.get_label_classes(:normal, :inverted)
    ]
  end

  defp get_label_classes(:info) do
    [
      Helpers.get_border_classes(:info),
      Helpers.get_background_classes(:info),
      Helpers.get_label_classes(:normal, :inverted)
    ]
  end
end
