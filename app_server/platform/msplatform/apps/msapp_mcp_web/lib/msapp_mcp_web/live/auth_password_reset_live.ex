# Source File: auth_password_reset_live.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp_web/lib/msapp_mcp_web/live/auth_password_reset_live.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsappMcpWeb.AuthPasswordResetLive do
  use MsappMcpWeb, :login_live_view

  @moduledoc false

  def mount(_params, session, socket) do
    host_addr =
      socket
      |> get_connect_info(:peer_data)
      |> then(& &1.address)

    socket =
      socket
      |> assign(
        host_addr: host_addr,
        original_request_path: session["original_request_path"],
        authenticator_reset_reason: session["authenticator_reset_reason"],
        page_title: "Password Reset"
      )
      |> Msform.AuthPasswordReset.preconnect_init(
        session["session_name"],
        :default,
        :entry,
        :reset
      )

    {:ok, socket}
  end

  def handle_event("form_validate", params, socket) do
    %{"auth_password_reset" => form_data} = params
    socket = Msform.AuthPasswordReset.validate_form_data(socket, form_data)
    {:noreply, socket}
  end

  def handle_event("form_submit", _params, socket) do
    socket = Msform.AuthPasswordReset.process_reset_attempt(socket)
    {:noreply, socket}
  end

  def handle_info({ref, :reset_successful}, socket) do
    Process.demonitor(ref, [:flush])

    redirect_path =
      case socket.assigns[:original_request_path] do
        "/password-reset" -> ~p"/"
        request_path when not is_nil(request_path) -> request_path
        _ -> ~p"/"
      end

    socket =
      socket
      |> Msform.AuthPasswordReset.process_reset_finished()
      |> redirect(to: redirect_path)

    {:noreply, socket}
  end

  def handle_info({ref, {:reset_failed, reason}}, socket) do
    Process.demonitor(ref, [:flush])

    flash_message =
      case reason do
        :session ->
          """
          Reset failed.  
          Your current session is no longer logged in. 
          Please refresh your browser to clear the session and log in again.
          """

        :confirmation ->
          "Reset failed, existing credential not confirmed.  Please verify your entries and try again."

        :reset ->
          "The reset process failed.  Please try again or contact your support staff."
      end

    socket =
      socket
      |> put_flash(:error, flash_message)

    {:noreply, socket}
  end

  def handle_info({:DOWN, _, _, _, _}, socket), do: {:noreply, socket}
end
