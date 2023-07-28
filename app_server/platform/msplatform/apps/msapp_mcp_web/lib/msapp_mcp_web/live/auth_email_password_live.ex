# Source File: auth_email_password_live.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp_web/lib/msapp_mcp_web/live/auth_email_password_live.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsappMcpWeb.AuthEmailPasswordLive do
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
        page_title: "Platform Login",
        original_request_path: session["original_request_path"]
      )
      |> Msform.AuthEmailPassword.preconnect_init(
        session["session_name"],
        :default,
        :entry,
        :login
      )

    {:ok, socket}
  end

  def handle_event("form_login_validate", %{"auth_email_password" => form_data}, socket) do
    socket = Msform.AuthEmailPassword.validate_form_data(socket, form_data)
    {:noreply, socket}
  end

  def handle_event("form_login_submit", %{"auth_email_password" => form_data}, socket) do
    socket = Msform.AuthEmailPassword.process_login_attempt(socket, form_data)
    {:noreply, socket}
  end

  def handle_info({ref, :login_authenticated}, socket) do
    Process.demonitor(ref, [:flush])

    redirect_path = socket.assigns[:original_request_path] || ~p"/"

    socket = redirect(socket, to: redirect_path)

    {:noreply, socket}
  end

  def handle_info({ref, {:login_denied, reason}}, socket) do
    Process.demonitor(ref, [:flush])

    flash_message =
      case reason do
        :rejected_rate_limited -> "Too many invalid login attempts.  Please try again later."
        :rejected_validation -> "This identity must be validated prior to use."
        :rejected_identity_expired -> "This identity has expired and cannot be use to login."
        :rejected_host_check -> "You are not permitted to access this system from your location."
        :rejected_deadline_expired -> "This login attempt has expired.  Please start again."
        _ -> "The supplied credentials are not valid for login."
      end

    socket =
      socket
      |> put_flash(:error, flash_message)
      |> Msform.AuthEmailPassword.process_login_denied()

    {:noreply, socket}
  end

  def handle_info({:DOWN, _, _, _, _}, socket), do: {:noreply, socket}
end
