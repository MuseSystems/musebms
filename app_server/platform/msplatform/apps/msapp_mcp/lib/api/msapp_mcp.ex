# Source File: msapp_mcp.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/api/msapp_mcp.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsappMcp do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias MsappMcp.Impl
  alias MsappMcp.Types
  alias MscmpSystNetwork.Types, as: NetTypes

  @spec launch_bootstrap?() :: boolean()
  defdelegate launch_bootstrap?, to: Impl.Settings

  @spec get_mssub_mcp_state() :: Types.mssub_mcp_states()
  defdelegate get_mssub_mcp_state, to: Impl.Settings

  @spec load_disallowed_passwords() :: :ok | {:error, MscmpSystError.t()}
  defdelegate load_disallowed_passwords(), to: Impl.McpBootstrap

  @spec process_bootstrap_data(MssubMcp.Types.tenant_bootstrap_params()) ::
          {:ok, MssubMcp.Types.tenant_bootstrap_result()} | {:error, MscmpSystError.t()}
  defdelegate process_bootstrap_data(data), to: Impl.McpBootstrap

  @spec authenticate(map(), NetTypes.addr(), MssubMcp.Types.session_name() | nil, Keyword.t()) ::
          Types.login_result()
  defdelegate authenticate(params, host_addr, session_name, opts \\ []), to: Impl.Authentication

  @spec test_session_authentication(MssubMcp.Types.session_name()) ::
          :session_valid | :session_invalid | {:session_reset, String.t()}
  defdelegate test_session_authentication(session_name), to: Impl.Authentication

  @spec delete_session(MssubMcp.Types.session_name()) ::
          :ok | {:ok, :not_found} | {:error, MscmpSystError.t()}
  defdelegate delete_session(session_name), to: MssubMcp

  defdelegate generate_session_name(), to: MssubMcp
end
