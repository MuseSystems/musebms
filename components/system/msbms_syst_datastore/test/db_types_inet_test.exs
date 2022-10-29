# Source File: db_types_inet_test.exs
# Location:    musebms/components/system/msbms_syst_datastore/test/db_types_inet_test.exs
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

  import IP, only: [sigil_i: 2]

  alias MsbmsSystDatastore.DbTypes

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

  test "Can convert DbTypes.Inet to IP.addr & IP.Subnet" do
    assert ~i"10.231.231.111" =
             DbTypes.Inet.to_net_address(%DbTypes.Inet{address: {10, 231, 231, 111}})

    assert ~i"10.231.231.0/24" =
             DbTypes.Inet.to_net_address(%DbTypes.Inet{address: {10, 231, 231, 0}, netmask: 24})
  end

  test "Can convert IP.addr & IP.Subnet to DbTypes.Inet" do
    assert %DbTypes.Inet{address: {10, 231, 231, 111}} =
             DbTypes.Inet.from_net_address(~i"10.231.231.111")

    assert %DbTypes.Inet{address: {10, 231, 231, 0}, netmask: 24} =
             DbTypes.Inet.from_net_address(~i"10.231.231.0/24")

    assert %DbTypes.Inet{address: {10, 1, 1, 0}, netmask: 24} =
             DbTypes.Inet.from_net_address(~i"10.1.1.0/24")
  end
end
