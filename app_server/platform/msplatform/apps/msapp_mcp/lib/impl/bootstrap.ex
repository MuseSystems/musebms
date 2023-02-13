# Source File: bootstrap.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/impl/bootstrap.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsappMcp.Impl.Bootstrap do
  @moduledoc false

  alias MsappMcp.Types

  require Logger

  @spec load_disallowed_passwords() :: :ok | {:error, MscmpSystError.t()}
  def load_disallowed_passwords() do
    Path.join([
      :code.priv_dir(:msapp_mcp),
      "database",
      "mcp_disallowed_passwords_starter_list.txt"
    ])
    |> File.stream!()
    |> MssubMcp.load_disallowed_passwords(pg_format: true)
  end

  @spec process_bootstrap_data(Types.mcp_bootstrap_params()) ::
          {:ok, MssubMcp.Types.tenant_bootstrap_result()} | {:error, MscmpSystError.t()}
  def process_bootstrap_data(data) do
    starting_contexts = MssubMcp.start_mcp_service_context()

    active_state =
      MscmpSystEnums.get_enum_item_by_name("platform_states", "platform_states_sysdef_active")

    {:ok, result} =
      MscmpSystDb.transaction(fn ->
        MscmpSystSettings.set_setting_value("platform_state", :setting_uuid, active_state.id)

        case validate_bootstrap_data(data) do
          :ok ->
            data
            |> parse_bootstrap_params()
            |> MssubMcp.bootstrap_tenant()
            |> maybe_set_platform_owner()

          errors ->
            {:error,
             %MscmpSystError{
               code: :undefined_error,
               message: "Failed bootstrapping MCP Platform",
               cause: errors
             }}
        end
      end)

    MssubMcp.stop_mcp_service_context(starting_contexts)

    result
  end

  defp validate_bootstrap_data(%Ecto.Changeset{valid?: true}), do: :ok
  defp validate_bootstrap_data(%Ecto.Changeset{} = changeset), do: changeset.errors

  defp validate_bootstrap_data(%{} = data) do
    changeset = Msform.McpBootstrap.changeset(%Msform.McpBootstrap{}, data)
    validate_bootstrap_data(changeset)
  end

  # MssubMcp will default both the owner and access account states to the
  # default active status.
  defp parse_bootstrap_params(data) do
    %{
      owner: %{
        internal_name: data.owner_name,
        display_name: data.owner_display_name
      },
      access_account: %{
        external_name: data.admin_display_name,
        owning_owner_name: data.owner_name,
        allow_global_logins: false
      },
      authenticator_type: :email_password,
      account_identifier: data.admin_identifier,
      credential: data.admin_credential,
      mfa_credential: nil,
      application: :mcp
    }
  end

  defp maybe_set_platform_owner({:ok, values} = result) do
    MscmpSystSettings.set_setting_value("platform_owner", :setting_uuid, values.owner_id)
    result
  end

  defp maybe_set_platform_owner(result), do: result
end
