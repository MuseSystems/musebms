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
  @type addr() :: ip4_addr() | ip6_addr()

  @type ip4_addr() :: :inet.ip4_address()

  @type ip6_addr() :: :inet.ip6_address()

  @type addr_structs() :: MscmpSystNetwork.Types.IpV4.t() | MscmpSystNetwork.Types.IpV6.t()
end
