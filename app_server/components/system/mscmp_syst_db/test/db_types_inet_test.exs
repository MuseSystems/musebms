# Source File: db_types_inet_test.exs
# Location:    musebms/components/system/mscmp_syst_db/test/db_types_inet_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule DbTypesInetTest do
  use ExUnit.Case, async: true

  import MscmpSystNetwork, only: [sigil_i: 2]

  alias MscmpSystDb.DbTypes

  test "Can convert DbTypes.Inet to Postgrex.INET" do
    assert %Postgrex.INET{address: {10, 1, 1, 10}} =
             DbTypes.Inet.to_postgrex_inet(%DbTypes.Inet{address: {10, 1, 1, 10}, netmask: nil})

    assert %Postgrex.INET{address: {10, 1, 1, 0}, netmask: 24} =
             DbTypes.Inet.to_postgrex_inet(%DbTypes.Inet{address: {10, 1, 1, 0}, netmask: 24})
  end

  test "Can convert Postgrex.INET to DbTypes.Inet" do
    assert %DbTypes.Inet{address: {10, 1, 1, 10}} =
             DbTypes.Inet.from_postgrex_inet(%Postgrex.INET{address: {10, 1, 1, 10}, netmask: nil})

    assert %DbTypes.Inet{address: {10, 1, 1, 0}, netmask: 24} =
             DbTypes.Inet.from_postgrex_inet(%Postgrex.INET{address: {10, 1, 1, 0}, netmask: 24})
  end

  test "Can convert DbTypes.Inet to MscmpSystNetwork.Types.IpV4" do
    assert ~i"10.231.231.111" ===
             DbTypes.Inet.to_net_address(%DbTypes.Inet{address: {10, 231, 231, 111}})

    assert ~i"10.231.231.0/24" ===
             DbTypes.Inet.to_net_address(%DbTypes.Inet{address: {10, 231, 231, 0}, netmask: 24})
  end

  test "Can convert DbTypes.Inet to MscmpSystNetwork.Types.IpV6" do
    assert ~i"fd9b:77f8:714d:cabb::20" ===
             DbTypes.Inet.to_net_address(%DbTypes.Inet{
               address: {64923, 30712, 29005, 51899, 0, 0, 0, 32}
             })

    assert ~i"fd9b:77f8:714d:cabb::/64" ===
             DbTypes.Inet.to_net_address(%DbTypes.Inet{
               address: {64923, 30712, 29005, 51899, 0, 0, 0, 0},
               netmask: 64
             })
  end

  test "Can convert MscmpSystNetwork.Types.IpV4 to DbTypes.Inet" do
    assert %DbTypes.Inet{address: {10, 231, 231, 111}} ===
             DbTypes.Inet.from_net_address(~i"10.231.231.111")

    assert %DbTypes.Inet{address: {10, 231, 231, 0}, netmask: 24} ===
             DbTypes.Inet.from_net_address(~i"10.231.231.0/24")
  end

  test "Can convert MscmpSystNetwork.Types.IpV6 to DbTypes.Inet" do
    assert %DbTypes.Inet{address: {64923, 30712, 29005, 51899, 0, 0, 0, 32}} ===
             DbTypes.Inet.from_net_address(~i"fd9b:77f8:714d:cabb::20")

    assert %DbTypes.Inet{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, netmask: 64} ===
             DbTypes.Inet.from_net_address(~i"fd9b:77f8:714d:cabb::/64")
  end
end
