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
  @moduledoc """
  Represents an IPv4 host or sub-net CIDR address.

  Implements the `MscmpSystNetwork.Protocol`.

  The representation of a host may also written to include an identifiable
  sub-net as well.  So for example, `10.1.1.15/24` represents
  both a specific host (`10.1.1.15`) and a specific sub-net
  `10.1.1.0/24`.
  """

  alias MscmpSystNetwork.Impl
  alias MscmpSystNetwork.Types

  @enforce_keys [:address]
  defstruct address: nil, mask: 32

  @typedoc """
  Defines an IPv4 address.

  ## Attributes

    * `address` - The IP address of the host or sub-net in
    `t:MscmpSystNetwork.Types.ipv4_addr/0` form.

    * `mask` - the sub-net mask bit length of the IP address.  Valid values are
    integers between 0 and 32, inclusive.  When defining a new struct and the
    `mask` is not provided, the resulting struct is assumed to represent a host
    and the `mask` attribute is defaulted to 32.

  See `MscmpSystNetwork.Types.IpV4` for more.
  """
  @type t() :: %__MODULE__{address: Types.ipv4_addr(), mask: Types.ipv4_mask()}

  defimpl MscmpSystNetwork.Protocol do
    @spec to_string(Types.IpV4.t()) :: String.t()
    def to_string(addr_struct), do: Impl.IpV4.to_string(addr_struct)

    @spec get_netmask(Types.IpV4.t()) :: Types.ipv4_addr()
    def get_netmask(addr_struct), do: Impl.IpV4.get_netmask(addr_struct)

    @spec get_network(Types.IpV4.t()) :: Types.ipv4_addr()
    def get_network(addr_struct), do: Impl.IpV4.get_network(addr_struct)

    @spec get_host(Types.IpV4.t()) :: Types.ipv4_addr() | nil
    def get_host(addr_struct), do: Impl.IpV4.get_host(addr_struct)

    @spec host?(Types.IpV4.t()) :: boolean()
    def host?(addr_struct), do: Impl.IpV4.host?(addr_struct)

    @spec network?(Types.IpV4.t()) :: boolean()
    def network?(addr_struct), do: Impl.IpV4.network?(addr_struct)

    @spec in_network?(Types.IpV4.t(), Types.IpV4.t()) :: boolean()
    def in_network?(test_addr, network_addr), do: Impl.IpV4.in_network?(test_addr, network_addr)

    @spec in_range?(Types.IpV4.t(), Types.IpV4.t(), Types.IpV4.t()) :: boolean()
    def in_range?(test_addr, low_addr, high_addr),
      do: Impl.IpV4.in_range?(test_addr, low_addr, high_addr)
  end

  defimpl Jason.Encoder do
    def encode(addr, opts), do: Impl.JasonSupport.encode(addr, opts)
  end
end
