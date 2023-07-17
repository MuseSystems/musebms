defmodule MsappMcp do
  @moduledoc """
  MsappMcp API
  """
  alias MsappMcp.Impl
  alias MsappMcp.Types

  @spec launch_bootstrap?() :: boolean()
  defdelegate launch_bootstrap?, to: Impl.Settings

  @spec get_platform_state() :: Types.platform_states()
  defdelegate get_platform_state, to: Impl.Settings

  @spec load_disallowed_passwords() :: :ok | {:error, MscmpSystError.t()}
  defdelegate load_disallowed_passwords(), to: Impl.McpBootstrap

  @spec process_bootstrap_data(Types.bootstrap_params()) ::
          {:ok, MssubMcp.Types.tenant_bootstrap_result()} | {:error, MscmpSystError.t()}
  defdelegate process_bootstrap_data(data), to: Impl.McpBootstrap

  @spec authenticate(map(), IP.addr(), MscmpSystSession.Types.session_name()) :: any()
  defdelegate authenticate(params, host_addr, session_name), to: Impl.Login

  @spec get_auth_state_session_data(MscmpSystAuthn.Types.authentication_state()) :: map()
  defdelegate get_auth_state_session_data(auth_state), to: Impl.Login

  @spec delete_session(MscmpSystSession.Types.session_name()) ::
          :ok | {:ok, :not_found} | {:error, MscmpSystError.t()}
  defdelegate delete_session(session_name), to: MssubMcp
end
