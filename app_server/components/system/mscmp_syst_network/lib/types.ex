# Source File: types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_network/lib/types.ex
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
  #
  # Note that the ordering of typespecs here is alphabetical.
  #

  @type addr() :: ipv4_addr() | ipv6_addr()

  @type addr_structs() :: MscmpSystNetwork.Types.IpV4.t() | MscmpSystNetwork.Types.IpV6.t()

  @type ipv4_addr() :: :inet.ipv4_address()

  @type ipv4_mask() :: 0..32

  @type ipv6_addr() :: :inet.ipv6_address()

  @type ipv6_mask() :: 0..128

  @type mask() :: ipv4_mask() | ipv6_mask()
end
