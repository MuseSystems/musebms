# Source File: msforms.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/impl/web_components/msforms.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.Impl.WebComponents.Msforms do
  use Phoenix.Component

  alias MscmpSystForms.Impl.WebComponents

  @default_modes %{
    component_mode: :entry,
    border_mode: :none,
    text_mode: [],
    label_mode: []
  }

  @default_layout ~w(flex flex-col)
  @default_alignment ~w(items-stretch justify-items-stretch)
  @default_sizing ~w(h-full w-full)
  @default_spacing ~w(m-1)

  attr(:id, :string, required: true)
  attr(:modes, :map, default: @default_modes)
  attr(:active_overrides, :list, default: [])
  attr(:layout, :list, default: @default_layout)
  attr(:alignment, :list, default: @default_alignment)
  attr(:sizing, :list, default: @default_sizing)
  attr(:spacing, :list, default: @default_spacing)
  attr(:extra_classes, :list, default: [])
  attr(:form, Phoenix.HTML.Form, required: true)
  attr(:validation_action, :string)
  attr(:submit_action, :string, required: true)

  def msform(assigns) do
    ~H"""
    <.form for={@form} phx-change={@validation_action} phx-submit={@submit_action}>
      <WebComponents.Mscontainers.mscontainer
        id={@id}
        modes={@modes}
        type={:fieldset}
        active_overrides={@active_overrides}
        layout={@layout}
        alignment={@alignment}
        sizing={@sizing}
        spacing={@spacing}
        extra_classes={@extra_classes}>
          <%= render_slot(@inner_block) %>
      </WebComponents.Mscontainers.mscontainer>
    </.form>
    """
  end
end
