# Source File: actions.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/msform/auth_password_reset/actions.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msform.AuthPasswordReset.Actions do
  @moduledoc false

  alias MscmpSystPerms.Types.PermGrantValue

  # This form always assumes that the password reset is for the currently logged
  # in user and a user always has permission to change their own credentials.
  #
  # A more accurate permission here would be `:same_user`, but we're not
  # implementing that just yet.

  @user_perms %{mcpauthnpr_form: %PermGrantValue{view_scope: :all, maint_scope: :all}}

  def preconnect_init(socket, session_name, feature, mode, state, opts) do
    # First test the session and extract the access_acocunt_id

    # Next get the access account name and populate that into the original
    # data

    with {:ok, %{"auth_state" => auth_state}} <- MssubMcp.get_session(session_name),
         :ok <- test_session_authentication(auth_state) do
      original_data = %Msform.AuthPasswordReset{
        access_account_id: auth_state["access_account_id"],
        identifier: auth_state["identifier"]
      }

      current_data = Map.from_struct(original_data)

      opts =
        MscmpSystUtils.resolve_options(opts,
          original_data: original_data,
          current_data: current_data
        )

      socket
      |> MscmpSystForms.init_assigns(
        session_name,
        Msform.AuthPasswordReset,
        feature,
        mode,
        state,
        @user_perms,
        opts
      )
      |> MscmpSystForms.update_button_state(:mcpauthnpr_button_reset, :message)
      |> maybe_put_reset_reason_flash(socket.assigns[:authenticator_reset_reason])
    else
      _ ->
        socket |> Phoenix.LiveView.redirect(to: "/")
    end
  end

  def postconnect_init(socket), do: MscmpSystForms.rebuild_component_assigns(socket)

  def validate_form_data(socket, form_data) do
    # Because the actual form doesn't know anything about the access_account_id
    # we always need to add it back to what the actual form does know about and
    # gives us for a completely correct msrd_current_data value.
    original_data = socket.assigns.msrd_original_data

    resolved_form_data =
      Map.merge(form_data, %{
        "access_account_id" => original_data.access_account_id,
        "identifier" => original_data.identifier
      })

    post_changeset = Msform.AuthPasswordReset.validate_post(original_data, resolved_form_data)

    updated_button_state = if post_changeset.valid?, do: :action, else: :message

    socket
    |> Phoenix.Component.assign(:msrd_current_data, resolved_form_data)
    |> Msform.AuthPasswordReset.update_display_data(post_changeset)
    |> MscmpSystForms.update_button_state(:mcpauthnpr_button_reset, updated_button_state)
  end

  def process_reset_attempt(socket) do
    session_name = socket.assigns.msrd_session_name
    host_addr = socket.assigns.host_addr
    current_data = socket.assigns.msrd_current_data

    %Task{} =
      Task.Supervisor.async_nolink(
        MsappMcp.TaskSupervisor,
        fn ->
          reset_result =
            :reset_in_progress
            |> reconfirm_session_authenticated(session_name)
            |> test_confirmation_credential(current_data, host_addr)
            |> perform_credential_reset(current_data)
            |> drop_existing_session(session_name)
            |> finalize_reset_process()

          send(self(), reset_result)
        end
      )

    MscmpSystForms.start_processing_override(socket, :process_password_reset)
  end

  @dialyzer {:no_match, reconfirm_session_authenticated: 2}
  defp reconfirm_session_authenticated(:reset_in_progress, session_name) do
    with {:ok, %{"auth_state" => auth_state}} <- MssubMcp.get_session(session_name),
         :ok <- test_session_authentication(auth_state) do
      :reset_in_progress
    else
      _ -> {:reset_failed, :session}
    end
  end

  defp reconfirm_session_authenticated(reset_status, _), do: reset_status

  defp test_session_authentication(%{"status" => "authenticated"}), do: :ok

  defp test_session_authentication(%{
         "status" => "pending",
         "pending_operations" => ["require_credential_reset"]
       }),
       do: :ok

  defp test_session_authentication(_), do: :not_authenticated

  defp test_confirmation_credential(:reset_in_progress, current_data, host_addr) do
    confirmation_result = MsappMcp.authenticate(current_data, host_addr, nil, mode: :confirm)

    case confirmation_result do
      :login_authenticated -> :reset_in_progress
      {:login_reset, _} -> :reset_in_progress
      _ -> {:reset_failed, :confirmation}
    end
  end

  defp perform_credential_reset(:reset_in_progress, current_data) do
    reset_result =
      MssubMcp.reset_password_credential(
        current_data["access_account_id"],
        current_data["new_credential"]
      )

    case reset_result do
      :ok -> :reset_in_progress
      {:invalid_credential, _} -> {:reset_failed, :reset}
    end
  end

  defp perform_credential_reset(reset_status, _), do: reset_status

  defp drop_existing_session(:reset_in_progress, session_name) do
    case MsappMcp.delete_session(session_name) do
      :ok ->
        :reset_in_progress

      error ->
        raise MscmpSystError,
          code: :undefined_error,
          message: "Failure dropping existing session during credential reset.",
          cause: error
    end
  end

  defp drop_existing_session(reset_status, _), do: reset_status

  defp finalize_reset_process(:reset_in_progress), do: :reset_successful
  defp finalize_reset_process(reset_status), do: reset_status

  def process_reset_finished(socket) do
    MscmpSystForms.finish_processing_override(socket, :process_password_reset)
  end

  defp maybe_put_reset_reason_flash(socket, "reset_forced") do
    Phoenix.LiveView.put_flash(
      socket,
      :error,
      "The administrator is requiring you to reset your credentials."
    )
  end

  defp maybe_put_reset_reason_flash(socket, "reset_age") do
    Phoenix.LiveView.put_flash(
      socket,
      :error,
      "Your password is older than the effective password rules allow."
    )
  end

  defp maybe_put_reset_reason_flash(socket, "reset_disallowed") do
    Phoenix.LiveView.put_flash(
      socket,
      :error,
      "Your password has been found on the disallowed passwords list."
    )
  end

  defp maybe_put_reset_reason_flash(socket, _), do: socket
end
