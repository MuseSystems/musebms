# Source File: msfield_errors.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/impl/web_components/msfield_errors.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.Impl.WebComponents.MsfieldErrors do
  use Phoenix.Component

  import MscmpSystForms.Impl.Gettext

  alias MscmpSystForms.Impl.WebComponents
  alias MscmpSystForms.Impl.WebComponents.Helpers.Js

  attr(:id, :any, required: true)

  slot(:msfield_error_item)

  def msfield_errors(assigns) do
    ~H"""
    <%= if display_field_errors(@msfield_error_item) do %>
      <button type="button" phx-click={Js.show_modal("#{@id}-msfielderror")}>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 20 20"
          fill="currentColor"
          class="w-5 h-5 fill-red-600 hover:fill-red-400"
          aria-hidden="true"
          aria-labelledby="title"
          role="graphics-symbol"
        >
          <title><%= gettext("Validation Errors") %></title>
          <desc><%= gettext("A red circle encompassing an exclamation point.") %></desc>
          <path
            fill-rule="evenodd"
            d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-5a.75.75 0 01.75.75v4.5a.75.75 0 01-1.5 0v-4.5A.75.75 0 0110 5zm0 10a1 1 0 100-2 1 1 0 000 2z"
            clip-rule="evenodd"
          />
        </svg>
      </button>
      <WebComponents.Msmodals.msmodal id={"#{@id}-msfielderror"}>
        <:title>Field Invalid</:title>
        <div class="flex flex-col space-y-2">
          <%= render_slot(@msfield_error_item) %>
        </div>
      </WebComponents.Msmodals.msmodal>
    <% end %>
    """
  end

  defp display_field_errors([_ | _]), do: true
  defp display_field_errors(_), do: false
end
