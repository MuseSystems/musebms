# Source File: msinfo.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/impl/web_components/msinfo.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.Impl.WebComponents.Msinfo do
  @moduledoc false

  use Phoenix.Component

  import MscmpSystForms.Impl.Gettext

  alias MscmpSystForms.Impl.WebComponents
  alias MscmpSystForms.Impl.WebComponents.Helpers.Js

  attr(:id, :any, required: true)

  slot(:msinfo_help)

  def msinfo(assigns) do
    ~H"""
    <div id={@id} class="flex justify-self-end place-self-center space-x-2">
      <WebComponents.Msmodals.msmodal id={"#{@id}-msinfo"}>
        <:title>Quick Reference</:title>
        <br />
        <%= render_slot(@msinfo_help) %>
      </WebComponents.Msmodals.msmodal>
      <button
        type="button"
        phx-click={Js.show_modal("#{@id}-msinfo")}
        disabled={@msinfo_help == []}
        aria-disabled={
          case @msinfo_help do
            [] -> "true"
            _ -> "false"
          end
        }
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          class={msinfo_button_style(:info, @msinfo_help)}
          aria-hidden="true"
          aria-labelledby="title"
          role="graphics-symbol"
        >
          <title><%= gettext("Quick Reference") %></title>
          <desc><%= gettext("A blue circle encompassing a question mark.") %></desc>
          <path
            fill-rule="evenodd"
            d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12zm11.378-3.917c-.89-.777-2.366-.777-3.255 0a.75.75 0 01-.988-1.129c1.454-1.272 3.776-1.272 5.23 0 1.513 1.324 1.513 3.518 0 4.842a3.75 3.75 0 01-.837.552c-.676.328-1.028.774-1.028 1.152v.75a.75.75 0 01-1.5 0v-.75c0-1.279 1.06-2.107 1.875-2.502.182-.088.351-.199.503-.331.83-.727.83-1.857 0-2.584zM12 18a.75.75 0 100-1.5.75.75 0 000 1.5z"
            clip-rule="evenodd"
          />
        </svg>
      </button>
      <div />
    </div>
    """
  end

  defp msinfo_button_style(_, []), do: "w-8 h-8 fill-gray-300"
  defp msinfo_button_style(:info, [_ | _]), do: "w-8 h-8 fill-blue-600 hover:fill-blue-400"
end
