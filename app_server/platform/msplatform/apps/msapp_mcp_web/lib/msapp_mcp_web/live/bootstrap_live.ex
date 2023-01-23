# Source File: bootstrap_live.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp_web/lib/msapp_mcp_web/live/bootstrap_live.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsappMcpWeb.BootstrapLive do
  use MsappMcpWeb, :live_view

  @moduledoc false

  def mount(_, _, socket) do
    starting_params = %{
      current_step: :welcome,
      page_title: "New System Startup",
      form_data: MsformData.McpBootstrap.get_data_definition(),
      changeset:
        MsformData.McpBootstrap.changeset(%MsformData.McpBootstrap{})
        |> Map.put(:action, :show_validation)
    }

    {:ok, assign(socket, starting_params)}
  end

  def handle_event("validate", %{"mcp_bootstrap" => form_data}, socket) do
    changeset =
      MsformData.McpBootstrap.changeset(%MsformData.McpBootstrap{}, form_data)
      |> Map.put(:action, :show_validation)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("display_errors", _params, socket) do
    socket |> IO.inspect()
    {:noreply, socket}
  end

  def handle_event("change_step", %{"step" => step}, socket) do
    {:noreply, assign(socket, current_step: String.to_existing_atom(step))}
  end
end
