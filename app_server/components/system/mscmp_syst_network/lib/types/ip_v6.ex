# Source File: ip_v6.ex
# Location:    musebms/app_server/components/system/mscmp_syst_network/lib/types/ip_v6.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystNetwork.Types.IpV6 do
  alias MscmpSystNetwork.Impl
  alias MscmpSystNetwork.Types

  @enforce_keys [:address]
  defstruct address: nil, mask: 128

  @type t() :: %__MODULE__{address: Types.ip6_addr(), mask: 0..128}

  defimpl MscmpSystNetwork.Protocol do
    @spec to_string(Types.IpV6.t()) :: String.t()
    def to_string(addr_struct), do: Impl.IpV6.to_string(addr_struct)

    @spec get_netmask(Types.IpV6.t()) :: Types.ip6_addr()
    def get_netmask(addr_struct), do: Impl.IpV6.get_netmask(addr_struct)

    @spec get_network(Types.IpV6.t()) :: Types.ip6_addr()
    def get_network(addr_struct), do: Impl.IpV6.get_network(addr_struct)

    @spec get_host(Types.IpV6.t()) :: Types.ip6_addr() | nil
    def get_host(addr_struct), do: Impl.IpV6.get_host(addr_struct)

    @spec host?(Types.IpV6.t()) :: boolean()
    def host?(addr_struct), do: Impl.IpV6.host?(addr_struct)

    @spec network?(Types.IpV6.t()) :: boolean()
    def network?(addr_struct), do: Impl.IpV6.network?(addr_struct)

    @spec in_network?(Types.IpV6.t(), Types.IpV6.t()) :: boolean()
    def in_network?(test_addr, network_addr), do: Impl.IpV6.in_network?(test_addr, network_addr)

    @spec in_range?(Types.IpV6.t(), Types.IpV6.t(), Types.IpV6.t()) :: boolean()
    def in_range?(test_addr, low_addr, high_addr),
      do: Impl.IpV6.in_range?(test_addr, low_addr, high_addr)
  end
end
