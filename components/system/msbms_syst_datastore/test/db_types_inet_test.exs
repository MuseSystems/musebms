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

  alias MsbmsSystDatastore.DbTypes

  test "Can convert DbTypes.Inet to Postgrex.INET" do
    assert %Postgrex.INET{address: {10, 1, 1, 10}} =
             DbTypes.Inet.to_postgrex_inet(%DbTypes.Inet{address: {10, 1, 1, 10}, netmask: nil})

    assert %Postgrex.INET{address: {10, 1, 1, 0}, netmask: {255, 255, 255, 0}} =
             DbTypes.Inet.to_postgrex_inet(%DbTypes.Inet{
               address: {10, 1, 1, 0},
               netmask: {255, 255, 255, 0}
             })
  end

  test "Can convert Postgrex.INET to DbTypes.Inet" do
    assert %DbTypes.Inet{address: {10, 1, 1, 10}} =
             DbTypes.Inet.from_postgrex_inet(%Postgrex.INET{address: {10, 1, 1, 10}, netmask: nil})

    assert %DbTypes.Inet{address: {10, 1, 1, 0}, netmask: {255, 255, 255, 0}} =
             DbTypes.Inet.from_postgrex_inet(%Postgrex.INET{
               address: {10, 1, 1, 0},
               netmask: {255, 255, 255, 0}
             })
  end
end
