# Source File: authentication.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/impl/authentication.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsappMcp.Impl.Authentication do
  @moduledoc false

  alias MscmpSystNetwork.Types, as: NetTypes

  @no_session_auth_statuses [
    :rejected,
    :rejected_rate_limited,
    :rejected_validation,
    :rejected_identity_expired,
    :rejected_host_check,
    :rejected_deadline_expired
  ]

  @spec authenticate(
          map(),
          NetTypes.addr_structs(),
          MscmpSystSession.Types.session_name() | nil,
          Keyword.t()
        ) ::
          MsappMcp.Types.login_result()
  def authenticate(%{} = params, host_addr, session_name, opts) do
    opts = MscmpSystUtils.resolve_options(opts, mode: :session)

    attempt_authentication(params["identifier"], params["credential"], host_addr)
    |> process_auth_result()
    |> maybe_create_db_session(session_name, opts[:mode])
    |> get_auth_action()
  end

  defp attempt_authentication(identifier, credential, host_addr) do
    owner_id = MssubMcp.get_setting_value("mcp_owner", :setting_uuid)

    MssubMcp.authenticate_email_password(identifier, credential, host_addr,
      owning_owner_id: owner_id,
      instance_id: :bypass
    )
  end

  defp process_auth_result({:ok, auth_state}), do: auth_state
  defp process_auth_result({:error, error}), do: %{status: :auth_error, auth_error: error}

  defp maybe_create_db_session(auth_state, _, :confirm), do: auth_state

  defp maybe_create_db_session(%{status: status} = auth_state, _, _)
       when status in @no_session_auth_statuses,
       do: auth_state

  defp maybe_create_db_session(auth_state, session_name, :session) do
    session_data = %{auth_state: encode_auth_state_for_json(auth_state)}

    session_result = MssubMcp.create_session(session_data, session_name: session_name)

    case session_result do
      {:ok, _} ->
        auth_state

      {:error, _} ->
        Map.put(auth_state, :status, :db_session_error)
    end
  end

  defp get_auth_action(%{status: :rejected}), do: {:login_denied, nil}

  defp get_auth_action(%{status: status}) when status in @no_session_auth_statuses,
    do: {:login_denied, status}

  defp get_auth_action(%{
         status: :pending,
         reset_reason: reset_reason,
         pending_operations: [:require_credential_reset]
       })
       when is_atom(reset_reason),
       do: :login_authenticated

  defp get_auth_action(%{status: :pending} = auth_state), do: {:login_pending, auth_state}

  defp get_auth_action(%{status: :authenticated, reset_reason: reset_reason} = auth_state)
       when is_atom(reset_reason),
       do: {:login_reset, auth_state}

  defp get_auth_action(%{status: :authenticated}), do: :login_authenticated

  defp get_auth_action(auth_state),
    do: {:platform_error, auth_state}

  defp encode_auth_state_for_json(%{host_address: host_addr} = auth_state)
       when is_tuple(host_addr),
       do: Map.replace(auth_state, :host_address, MscmpSystNetwork.to_string(host_addr))

  defp encode_auth_state_for_json(auth_state), do: auth_state

  # The session drawn from the DB will be some form of authentication_state()
  # except it will be defined with strings instead of atoms where atoms would
  # otherwise be used, such as for keys and some values.
  # test_session_authentication/1 is about this DB retrieved session so will
  # need to expect these usually atoms as strings; should be OK here.
  #
  # TODO: Think about if its worth it to convert the map to be atom based for
  #       better consistency of internal logic.

  def test_session_authentication(session_name) do
    session_name
    |> maybe_get_db_session()
    |> maybe_get_auth_state()
    |> get_session_auth_result()
  end

  defp maybe_get_db_session(nil), do: {:ok, :not_found}

  defp maybe_get_db_session(session_name) do
    MssubMcp.get_session(session_name)
  end

  defp maybe_get_auth_state({:ok, %{"auth_state" => auth_state}}), do: auth_state
  defp maybe_get_auth_state({:ok, :not_found}), do: %{"status" => "rejected"}

  defp maybe_get_auth_state({:error, error}) do
    raise MscmpSystError,
      code: :undefined_error,
      message: "Error retrieving database session.",
      cause: error
  end

  defp get_session_auth_result(%{"status" => "authenticated", "reset_reason" => reset_reason})
       when is_binary(reset_reason),
       do: {:session_reset, reset_reason}

  defp get_session_auth_result(%{
         "status" => "pending",
         "reset_reason" => reset_reason,
         "pending_operations" => ["require_credential_reset"]
       })
       when is_binary(reset_reason),
       do: {:session_reset, reset_reason}

  defp get_session_auth_result(%{"status" => "authenticated"}), do: :session_valid
  defp get_session_auth_result(_), do: :session_invalid
end
