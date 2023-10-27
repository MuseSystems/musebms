# Source File: inet.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/impl/db_types/inet.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.Impl.DbTypes.Inet do
  @moduledoc false

  import MscmpSystNetwork.Guards, only: [is_ipv4: 1, is_ipv6: 1]

  alias MscmpSystDb.DbTypes
  alias MscmpSystNetwork.Types, as: NetTypes

  @spec to_postgrex_inet(DbTypes.Inet.t()) :: Postgrex.INET.t()
  def to_postgrex_inet(%DbTypes.Inet{address: address, netmask: netmask}),
    do: %Postgrex.INET{address: address, netmask: netmask}

  @spec from_postgrex_inet(Postgrex.INET.t()) :: DbTypes.Inet.t()
  def from_postgrex_inet(%Postgrex.INET{address: address, netmask: netmask}),
    do: %DbTypes.Inet{address: address, netmask: netmask}

  @spec to_net_address(DbTypes.Inet.t()) :: MscmpSystNetwork.Types.addr_structs()
  def to_net_address(%DbTypes.Inet{address: {_, _, _, _} = address, netmask: mask})
      when (mask >= 0 and mask <= 32) or is_nil(mask),
      do: %NetTypes.IpV4{address: address, mask: mask || 32}

  def to_net_address(%DbTypes.Inet{address: {_, _, _, _, _, _, _, _} = address, netmask: prefix})
      when (prefix >= 0 and prefix <= 128) or is_nil(prefix),
      do: %NetTypes.IpV6{address: address, mask: prefix || 128}

  @spec from_net_address(MscmpSystNetwork.Types.addr_structs()) :: DbTypes.Inet.t()
  def from_net_address(addr) when is_ipv4(addr) do
    resolved_mask = if addr.mask === 32, do: nil, else: addr.mask
    %DbTypes.Inet{address: addr.address, netmask: resolved_mask}
  end

  def from_net_address(addr) when is_ipv6(addr) do
    resolved_prefix = if addr.mask === 128, do: nil, else: addr.mask
    %DbTypes.Inet{address: addr.address, netmask: resolved_prefix}
  end
end
