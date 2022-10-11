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

  @moduledoc false

  @spec to_postgrex_inet(DbTypes.Inet.t()) :: Postgrex.INET.t()
  def to_postgrex_inet(%DbTypes.Inet{address: address, netmask: netmask}),
    do: %Postgrex.INET{address: address, netmask: netmask}

  @spec from_postgrex_inet(Postgrex.INET.t()) :: DbTypes.Inet.t()
  def from_postgrex_inet(%Postgrex.INET{address: address, netmask: netmask}),
    do: %DbTypes.Inet{address: address, netmask: netmask}
end
