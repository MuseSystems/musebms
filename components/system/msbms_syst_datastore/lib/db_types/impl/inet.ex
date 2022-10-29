# Source File: inet.ex
# Location:    musebms/components/system/msbms_syst_datastore/lib/db_types/impl/inet.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystDatastore.DbTypes.Impl.Inet do
  alias MsbmsSystDatastore.DbTypes

  require IP
  require IP.Subnet

  @moduledoc false

  @spec to_postgrex_inet(DbTypes.Inet.t()) :: Postgrex.INET.t()
  def to_postgrex_inet(%DbTypes.Inet{address: address, netmask: netmask}),
    do: %Postgrex.INET{address: address, netmask: netmask}

  @spec from_postgrex_inet(Postgrex.INET.t()) :: DbTypes.Inet.t()
  def from_postgrex_inet(%Postgrex.INET{address: address, netmask: netmask}),
    do: %DbTypes.Inet{address: address, netmask: netmask}

  @spec to_net_address(DbTypes.Inet.t()) :: IP.addr() | IP.Subnet.t()
  def to_net_address(%DbTypes.Inet{address: address, netmask: nil}), do: address

  def to_net_address(%DbTypes.Inet{address: address, netmask: mask}) when is_integer(mask),
    do: IP.Subnet.of(address, mask)

  @spec from_net_address(IP.addr() | IP.Subnet.t()) :: DbTypes.Inet.t()
  def from_net_address(address) when IP.is_ip(address), do: %DbTypes.Inet{address: address}

  def from_net_address(subnet) when IP.Subnet.is_subnet(subnet),
    do: %DbTypes.Inet{address: subnet.routing_prefix, netmask: subnet.bit_length}
end
