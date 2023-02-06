# Source File: tenant.ex
# Location:    musebms/app_server/subsystems/mssub_mcp/lib/impl/tenant.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcp.Impl.Tenant do
  @moduledoc false

  alias Ecto.Multi
  alias MssubMcp.Types
  alias MscmpSystMcpPerms.Types, as: McpPermTypes

  @spec bootstrap(Types.tenant_bootstrap_params()) ::
          {:ok, Types.tenant_bootstrap_result()} | {:error, MscmpSystError.t()}
  def bootstrap(params) do
    starting_contexts = MssubMcp.start_mcp_service_context()

    result =
      params
      |> construct_bootstrap_transaction()
      |> MscmpSystDb.transaction()
      |> parse_bootstrap_result()

    MssubMcp.stop_mcp_service_context(starting_contexts)

    {:ok, result}
  end

  defp construct_bootstrap_transaction(params) do
    Multi.new()
    |> maybe_verify_no_owners(params)
    |> maybe_verify_no_access_accounts(params)
    |> create_owner(params)
    |> create_access_account(params)
    |> create_authenticator(params)
    |> maybe_create_instance(params)
    |> maybe_add_account_to_instance(params)
    |> maybe_add_mcp_perm_roles(params)
  end

  defp maybe_verify_no_owners(multi, %{application: :mcp}) do
    Multi.run(multi, :verify_no_owners, fn _, _ ->
      case MscmpSystInstance.owner_exists?() do
        false -> {:ok, false}
        true -> {:error, "Owners exist"}
        error -> error
      end
    end)
  end

  defp maybe_verify_no_owners(multi, _), do: multi

  defp maybe_verify_no_access_accounts(multi, %{application: :mcp}) do
    Multi.run(multi, :verify_no_access_accounts, fn _, _ ->
      case MscmpSystAuthn.access_account_exists?() do
        false -> {:ok, false}
        true -> {:error, "Access Accounts exist"}
        error -> error
      end
    end)
  end

  defp maybe_verify_no_access_accounts(multi, _), do: multi

  defp create_owner(multi, params) do
    Multi.run(multi, :create_owner, fn _, _ ->
      params.owner
      |> resolve_internal_name()
      |> resolve_owner_state_id()
      |> MscmpSystInstance.create_owner()
    end)
  end

  defp create_access_account(multi, params) do
    Multi.run(
      multi,
      :create_access_account,
      fn _, _ ->
        params.access_account
        |> resolve_internal_name()
        |> resolve_access_account_state_id()
        |> MscmpSystAuthn.create_access_account()
      end
    )
  end

  defp create_authenticator(multi, %{authenticator_type: :email_password} = params) do
    Multi.run(multi, :create_authenticator, fn _, prior_results ->
      %{create_access_account: access_account} = prior_results

      MscmpSystAuthn.create_authenticator_email_password(
        access_account.id,
        params.account_identifier,
        params.credential,
        get_email_password_authenticator_opts(params)
      )
    end)
  end

  defp get_email_password_authenticator_opts(%{application: :mcp}), do: [create_validated: true]
  defp get_email_password_authenticator_opts(_), do: []

  defp maybe_create_instance(multi, _), do: multi

  defp maybe_add_account_to_instance(multi, _), do: multi

  defp maybe_add_mcp_perm_roles(multi, %{application: :mcp}) do
    Multi.run(multi, :add_mcp_perm_roles, fn _, prior_results ->
      %{create_access_account: access_account} = prior_results

      perm_role_id = MscmpSystPerms.get_perm_role_id_by_name("mcp_access_accounts", "mcp_login")

      grant_result =
        MscmpSystPerms.grant_perm_role(
          %McpPermTypes.AccessAccountPermsSelector{access_account_id: access_account.id},
          perm_role_id
        )

      case grant_result do
        :ok -> {:ok, nil}
        error -> {:error, error}
      end
    end)
  end

  defp resolve_owner_state_id(%{owner_state_id: state_id} = owner_params)
       when is_binary(state_id),
       do: owner_params

  defp resolve_owner_state_id(owner_params) do
    owner_state = MssubMcp.get_owner_state_default(:owner_states_active)
    Map.put(owner_params, :owner_state_id, owner_state.id)
  end

  defp resolve_access_account_state_id(
         %{access_account_state_id: state_id} = access_account_params
       )
       when is_binary(state_id),
       do: access_account_params

  defp resolve_access_account_state_id(access_account_params) do
    acces_account = MssubMcp.get_access_account_state_default(:access_account_states_active)
    Map.put(access_account_params, :access_account_state_id, acces_account.id)
  end

  defp resolve_internal_name(%{internal_name: name} = record_params) when is_binary(name),
    do: record_params

  defp resolve_internal_name(record_params),
    do: Map.put(record_params, :internal_name, MscmpSystUtils.get_random_string(9, :b32c))

  defp parse_bootstrap_result({:ok, result}) do
    %{
      owner_id: result.create_owner.id,
      access_account_id: result.create_access_account.id,
      instance_id: if(result[:create_instance], do: result.create_instance.id)
    }
  end
end
