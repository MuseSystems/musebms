# Source File: actions.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/msform/auth_email_password/actions.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msform.AuthEmailPassword.Actions do
  @moduledoc false

  alias MscmpSystPerms.Types.PermGrantValue

  # For AuthEmailPassword user permissions are assumed since this we don't even
  # have a authenticated user at this point.
  @user_perms %{mcpauthnep_form: %PermGrantValue{view_scope: :all, maint_scope: :all}}

  def preconnect_init(socket, session_name, feature, mode, state, opts) do
    socket
    |> MscmpSystForms.init_assigns(
      session_name,
      Msform.AuthEmailPassword,
      feature,
      mode,
      state,
      @user_perms,
      opts
    )
    |> MscmpSystForms.update_button_state(:mcpauthnep_button_login, :message)
  end

  def postconnect_init(socket), do: MscmpSystForms.rebuild_component_assigns(socket)

  def validate_form_data(socket, form_data) do
    post_changeset =
      Msform.AuthEmailPassword.validate_post(socket.assigns.msrd_original_data, form_data)

    updated_button_state = if post_changeset.valid?, do: :action, else: :message

    socket
    |> Phoenix.Component.assign(:msrd_current_data, form_data)
    |> Msform.AuthEmailPassword.update_display_data(post_changeset)
    |> MscmpSystForms.update_button_state(:mcpauthnep_button_login, updated_button_state)
  end

  def process_login_attempt(socket, form_data) do
    # TODO: I don't think requiring or using form data here is correct.  We have
    #       msrd_current_data which should be validated at the point of a login
    #       attempt.  This is a nit-picky point; there shouldn't be a functional
    #       difference, but in other forms and circumstances we wouldn't expect
    #       form_data to be complete, but something that is merged in some way
    #       with msrd_current_data to create a complete data picture; part of
    #       this has to do with the fact that form_data is filtered by what the
    #       user can work with whereas msrd_current_data would include data that
    #       the user may not have permission to manipulate or even see.

    session_name = socket.assigns.msrd_session_name
    host_addr = socket.assigns.host_addr

    %Task{} =
      Task.Supervisor.async_nolink(
        MsappMcp.TaskSupervisor,
        fn ->
          auth_result = MsappMcp.authenticate(form_data, host_addr, session_name)
          send(self(), auth_result)
        end
      )

    MscmpSystForms.start_processing_override(socket, :process_login_attempt)
  end

  def process_login_authenticated(socket) do
    MscmpSystForms.finish_processing_override(socket, :process_login_attempt)
  end

  def process_login_denied(socket) do
    MscmpSystForms.finish_processing_override(socket, :process_login_attempt)
  end

  def process_login_pending(socket) do
    MscmpSystForms.finish_processing_override(socket, :process_login_attempt)
  end

  def process_login_reset(socket, _auth_state) do
    MscmpSystForms.finish_processing_override(socket, :process_login_attempt)
  end

  def process_platform_error(socket, _auth_state) do
    MscmpSystForms.finish_processing_override(socket, :process_login_attempt)
  end
end
