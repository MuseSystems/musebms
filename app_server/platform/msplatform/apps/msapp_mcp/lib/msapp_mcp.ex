defmodule MsappMcp do
  @moduledoc """
  MsappMcp API
  """
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

  @spec authenticate(
          map(),
          NetTypes.addr_structs(),
          MssubMcp.Types.session_name() | nil,
          Keyword.t()
        ) ::
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
