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
  @moduledoc """
  Represents an IPv6 host or sub-net CIDR address.

  Implements the `MscmpSystNetwork.Protocol`.

  The representation of a host may also written to include an identifiable
  sub-net as well.  So for example, `fd9b:77f8:714d:cabb::ab67:12/64` represents
  both a specific host (`fd9b:77f8:714d:cabb::ab67:12`) and a specific sub-net
  `fd9b:77f8:714d:cabb::ab67:0000/64`.
  """

  alias MscmpSystNetwork.Impl
  alias MscmpSystNetwork.Types

  @enforce_keys [:address]
  defstruct address: nil, mask: 128

  @typedoc """
  Defines an IPv6 address.

  ## Attributes

    * `address` - The IP address of the host or sub-net in
    `t:MscmpSystNetwork.Types.ip6_addr/0` form.

    * `mask` - the prefix bit length of the IP address.  Valid values are
    integers between 0 and 128, inclusive.  When defining a new struct and the
    `mask` is not provided, the resulting struct is assumed to represent a host
    and the `mask` attribute is defaulted to 128.

  See `MscmpSystNetwork.Types.IpV6` for more.
  """
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
