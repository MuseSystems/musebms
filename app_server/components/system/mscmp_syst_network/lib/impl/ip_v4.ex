# Source File: ip_v4.ex
# Location:    musebms/app_server/components/system/mscmp_syst_network/lib/impl/ip_v4.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystNetwork.Impl.IpV4 do
  @moduledoc false

  import Bitwise
  import MscmpSystNetwork.Guards, only: [is_ipv4_tuple: 1]

  alias MscmpSystNetwork.Types.IpV4

  @spec to_string(IpV4.t()) :: String.t()
  def to_string(addr) do
    address = addr.address |> :inet.ntoa() |> List.to_string()
    mask = Integer.to_string(addr.mask)
    address <> "/" <> mask
  end

  @spec get_netmask(IpV4.t()) :: Types.ip4_addr()
  def get_netmask(addr), do: mask(addr.mask)

  @spec get_network(IpV4.t()) :: Types.ip4_addr() | nil
  def get_network(%IpV4{mask: 32}), do: nil

  def get_network(addr) do
    address = to_integer(addr.address)
    mask = addr.mask |> mask() |> to_integer()

    band(address, mask) |> from_integer()
  end

  @spec get_host(IpV4.t()) :: Types.ip4_addr() | nil
  def get_host(addr), do: if(host?(addr), do: addr.address, else: nil)

  @spec host?(IpV4.t()) :: boolean()
  def host?(addr) do
    cond do
      addr.mask == 32 ->
        true

      network?(addr) ->
        false

      true ->
        address = addr.address |> to_integer()
        broadcast_address = get_highest_address(addr)
        address != broadcast_address
    end
  end

  @spec network?(IpV4.t()) :: boolean()
  def network?(%IpV4{mask: 32}), do: false

  def network?(addr) do
    address = to_integer(addr.address)
    inverse_mask = addr.mask |> mask() |> to_integer() |> bnot()

    (address &&& inverse_mask) == 0
  end

  @spec to_struct(Types.ip4_addr(), 1..32 | nil) :: IpV4.t()
  def to_struct(erlang_addr, mask) when is_ipv4_tuple(erlang_addr),
    do: %IpV4{address: erlang_addr, mask: mask}

  defp to_integer({a, b, c, d} = ip) when is_ipv4_tuple(ip) do
    <<i::unsigned-integer-size(32)>> = <<a, b, c, d>>
    i
  end

  defp from_integer(i) when is_integer(i) and i >= 0 and i <= 0xFFFF_FFFF do
    <<a, b, c, d>> = <<i::unsigned-integer-size(32)>>
    {a, b, c, d}
  end

  defp mask(bit_length) do
    <<a, b, c, d>> = <<-1 <<< (32 - bit_length)::32>>
    {a, b, c, d}
  end

  defp get_highest_address(addr) do
    address = addr.address |> to_integer()
    inverse_mask = get_netmask(addr) |> to_integer() |> bnot() |> band(0xFFFF_FFFF)
    address ||| inverse_mask
  end
end
