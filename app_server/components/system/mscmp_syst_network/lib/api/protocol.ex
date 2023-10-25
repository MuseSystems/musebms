# Source File: protocol.ex
# Location:    musebms/app_server/components/system/mscmp_syst_network/lib/protocol.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defprotocol MscmpSystNetwork.Protocol do
  @moduledoc """
  Defines the MscmpSystNetwork Protocol which all network protocols must
  implement.

  Many functions in `MscmpSystNetwork` require that this protocol be implemented
  to be useful.
  """
  alias MscmpSystNetwork.Types

  @spec to_string(Types.addr_structs()) :: String.t()
  def to_string(addr_struct)

  @spec get_netmask(Types.IpV4.t()) :: Types.ipv4_addr()
  @spec get_netmask(Types.IpV6.t()) :: Types.ipv6_addr()
  def get_netmask(addr_struct)

  @spec get_network(Types.IpV4.t()) :: Types.ipv4_addr() | nil
  @spec get_network(Types.IpV6.t()) :: Types.ipv6_addr() | nil
  def get_network(addr_struct)

  @spec get_host(Types.IpV4.t()) :: Types.ipv4_addr() | nil
  @spec get_host(Types.IpV6.t()) :: Types.ipv6_addr() | nil
  def get_host(addr_struct)

  @spec host?(Types.addr_structs()) :: boolean()
  def host?(addr_struct)

  @spec network?(Types.addr_structs()) :: boolean()
  def network?(addr_struct)

  @spec in_network?(Types.IpV4.t(), Types.IpV4.t()) :: boolean()
  @spec in_network?(Types.IpV6.t(), Types.IpV6.t()) :: boolean()
  def in_network?(test_addr, network_addr)

  @spec in_range?(Types.IpV4.t(), Types.IpV4.t(), Types.IpV4.t()) :: boolean()
  @spec in_range?(Types.IpV6.t(), Types.IpV6.t(), Types.IpV6.t()) :: boolean()
  def in_range?(test_addr, low_addr, high_addr)
end
