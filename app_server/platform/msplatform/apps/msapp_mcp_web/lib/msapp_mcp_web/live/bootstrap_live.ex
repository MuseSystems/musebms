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
  @moduledoc false

  use MsappMcpWeb, :bootstrap_live_view

  def mount(_params, session, socket) do
    updated_socket =
      socket
      |> assign(:page_title, "Platform Bootstrap Process")
      |> Msform.McpBootstrap.preconnect_init(
        session["session_name"],
        :default,
        :entry,
        :welcome
      )

    {:ok, updated_socket}
  end

  def handle_event("button_welcome_next", _params, socket) do
    socket = Msform.McpBootstrap.enter_disallowed_state(socket)
    {:noreply, socket}
  end

  def handle_event("button_disallowed_back", _params, socket) do
    socket = Msform.McpBootstrap.enter_welcome_state(socket)
    {:noreply, socket}
  end

  def handle_event("button_disallowed_next", _params, socket) do
    socket = Msform.McpBootstrap.enter_records_state(socket)
    {:noreply, socket}
  end

  def handle_event("button_disallowed_load", _params, socket) do
    socket = Msform.McpBootstrap.process_disallowed_load(socket)
    {:noreply, socket}
  end

  def handle_event("button_disallowed_populate", _params, socket) do
    socket = Msform.McpBootstrap.enter_records_state(socket)
    {:noreply, socket}
  end

  def handle_event("button_records_back", _params, socket) do
    socket = Msform.McpBootstrap.enter_disallowed_state(socket)
    {:noreply, socket}
  end

  def handle_event("records_validate", params, socket) do
    %{"mcp_bootstrap" => form_data} = params
    socket = Msform.McpBootstrap.validate_form_data(socket, form_data)
    {:noreply, socket}
  end

  def handle_event("form_records_submit", _params, socket) do
    socket = Msform.McpBootstrap.process_records_save(socket)
    {:noreply, socket}
  end

  def handle_event("button_finish", _params, socket) do
    {:noreply, redirect(socket, to: ~p"/login")}
  end

  def handle_info({ref, :disallowed_list_loaded}, socket) do
    Process.demonitor(ref, [:flush])

    socket = Msform.McpBootstrap.process_disallowed_finished(socket)

    {:noreply, socket}
  end

  def handle_info({ref, :records_saved}, socket) do
    Process.demonitor(ref, [:flush])

    socket = Msform.McpBootstrap.process_records_save_finished(socket)

    {:noreply, socket}
  end

  def handle_info({:DOWN, _, _, _, _}, socket), do: {:noreply, socket}
end
