# Source File: events.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/msform/mcp_bootstrap/events.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msform.McpBootstrap.Actions do
  # For McpBootstrap user permissions are assumed since no user will exist at
  # bootstrap time
  @user_perms %{mcpbs_bootstrap_form: %{view_scope: :all, maint_scope: :all}}

  def preconnect_init(socket, session_name, feature, mode, state, opts) do
    socket
    |> MscmpSystForms.init_assigns(
      session_name,
      Msform.McpBootstrap,
      feature,
      mode,
      state,
      @user_perms,
      opts
    )
    |> MscmpSystForms.update_button_state(:mcpbs_step_disallowed_button_load, :message)
    |> MscmpSystForms.update_button_state(:mcpbs_step_records_button_save, :message)
  end

  def postconnect_init(socket), do: MscmpSystForms.rebuild_component_assigns(socket)

  def enter_disallowed_state(socket) do
    load_button_action =
      case MssubMcp.disallowed_passwords_populated?() do
        true -> :message
        false -> :action
      end

    socket
    |> MscmpSystForms.set_form_state(:disallowed)
    |> MscmpSystForms.rebuild_component_assigns()
    |> MscmpSystForms.update_button_state(:mcpbs_step_disallowed_button_load, load_button_action)
  end

  def enter_welcome_state(socket) do
    socket
    |> MscmpSystForms.set_form_state(:welcome)
    |> MscmpSystForms.rebuild_component_assigns()
  end

  def enter_records_state(socket) do
    socket
    |> MscmpSystForms.set_form_state(:records)
    |> MscmpSystForms.rebuild_component_assigns()
  end

  def enter_finished_state(socket) do
    socket
    |> MscmpSystForms.set_form_state(:finished)
    |> MscmpSystForms.rebuild_component_assigns()
  end

  def validate_form_data(socket, form_data) do
    save_changeset =
      Msform.McpBootstrap.validate_save(socket.assigns.msrd_original_data, form_data)

    updated_button_state = if save_changeset.valid?, do: :action, else: :message

    socket
    |> Phoenix.Component.assign(:msrd_current_data, form_data)
    |> Msform.McpBootstrap.update_display_data(save_changeset)
    |> MscmpSystForms.update_button_state(:mcpbs_step_records_button_save, updated_button_state)
  end

  def process_disallowed_load(socket) do
    Task.Supervisor.async_nolink(
      MsappMcp.TaskSupervisor,
      fn ->
        case MsappMcp.load_disallowed_passwords() do
          :ok ->
            send(self(), :disallowed_list_loaded)

          error ->
            raise MscmpSystError,
              code: :undefined_error,
              message: "Unexpected failure loading Disallowed Passwords starter list.",
              cause: error
        end
      end,
      shutdown: 300_000
    )

    MscmpSystForms.start_processing_override(socket, :process_disallowed_load)
  end

  def process_disallowed_finished(socket) do
    socket = MscmpSystForms.finish_processing_override(socket, :process_disallowed_load)

    case MssubMcp.disallowed_passwords_populated?() do
      true -> enter_records_state(socket)
      false -> enter_disallowed_state(socket)
    end
  end

  def process_records_save(socket) do
    Task.Supervisor.async_nolink(
      MsappMcp.TaskSupervisor,
      fn ->
        socket.assigns.msrd_current_data
        |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
        |> MsappMcp.process_bootstrap_data()
        |> case do
          {:ok, _} = result ->
            result

          error ->
            raise MscmpSystError,
              code: :undefined_error,
              message: "The bootstrapping record creation failed.",
              cause: error
        end

        send(self(), :records_saved)
      end
    )

    MscmpSystForms.start_processing_override(socket, :process_records_save)
  end

  def process_records_save_finished(socket) do
    socket = MscmpSystForms.finish_processing_override(socket, :process_records_save)
    enter_finished_state(socket)
  end
end
