# Source File: types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_network/lib/api/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystNetwork.Types do
  @moduledoc """
  Basic types in support of the MscmpSystNetwork Component.
  """

  #
  # Note that the ordering of typespecs here is alphabetical.
  #

  @typedoc """
  The union of Erlang IPv4 and IPv6 address tuple types.
  """
  @type addr() :: ipv4_addr() | ipv6_addr()

  @typedoc """
  The union of MscmpSystNetwork IP address struct types.
  """
  @type addr_structs() :: MscmpSystNetwork.Types.IpV4.t() | MscmpSystNetwork.Types.IpV6.t()

  @typedoc """
  An IPv4 address type in Erlang `t::inet.ip4_address/0` format.
  """
  @type ipv4_addr() :: :inet.ip4_address()

  @typedoc """
  Defines the acceptable subnet mask bit length for IPv4 addresses.
  """
  @type ipv4_mask() :: 0..32

  @typedoc """
  An IPv6 address type in Erlang `t::inet.ip6_address/0` format.
  """
  @type ipv6_addr() :: :inet.ip6_address()

  @typedoc """
  Defines the acceptable prefix bit length for IPv6 addresses.
  """
  @type ipv6_mask() :: 0..128

  @typedoc """
  The union of IPv4 and IPv6 bit length definitions.
  """
  @type mask() :: ipv4_mask() | ipv6_mask()
end
