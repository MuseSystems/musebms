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
  defdelegate load_disallowed_passwords(), to: Impl.Bootstrap
end
