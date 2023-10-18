# Source File: ip_v4.ex
# Location:    musebms/app_server/components/system/mscmp_syst_network/lib/types/ip_v4.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystNetwork.Types.IpV4 do
  alias MscmpSystNetwork.Impl
  alias MscmpSystNetwork.Types

  @enforce_keys [:address]
  defstruct address: nil, mask: 32

  @type t() :: %__MODULE__{address: Types.ip4_addr(), mask: 0..32}

  defimpl MscmpSystNetwork.Protocol do
    @spec to_string(Types.IpV4.t()) :: String.t()
    def to_string(addr_struct), do: Impl.IpV4.to_string(addr_struct)

    @spec get_netmask(Types.IpV4.t()) :: Types.ip4_addr()
    def get_netmask(addr_struct), do: Impl.IpV4.get_netmask(addr_struct)

    @spec get_network(Types.IpV4.t()) :: Types.ip4_addr()
    def get_network(addr_struct), do: Impl.IpV4.get_network(addr_struct)

    @spec get_host(Types.IpV4.t()) :: Types.ip4_addr() | nil
    def get_host(addr_struct), do: Impl.IpV4.get_host(addr_struct)

    @spec host?(Types.IpV4.t()) :: boolean()
    def host?(addr_struct), do: Impl.IpV4.host?(addr_struct)

    @spec network?(Types.IpV4.t()) :: boolean()
    def network?(addr_struct), do: Impl.IpV4.network?(addr_struct)
  end
end
