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

  import MscmpSystNetwork.Guards, only: [is_ipv4: 1, is_ipv4_tuple: 1]

  alias MscmpSystNetwork.Types
  alias MscmpSystNetwork.Types.IpV4

  @spec to_string(IpV4.t()) :: String.t()
  def to_string(addr) when is_ipv4(addr) do
    address = addr.address |> :inet.ntoa() |> List.to_string()
    mask = Integer.to_string(addr.mask)
    address <> "/" <> mask
  end

  @spec get_netmask(IpV4.t()) :: Types.ipv4_addr()
  def get_netmask(addr) when is_ipv4(addr), do: mask(addr.mask)

  @spec get_network(IpV4.t()) :: Types.ipv4_addr() | nil
  def get_network(%IpV4{mask: 32}), do: nil

  def get_network(addr) when is_ipv4(addr) do
    address = to_integer(addr.address)
    mask = addr.mask |> mask() |> to_integer()

    band(address, mask) |> from_integer()
  end

  @spec get_host(IpV4.t()) :: Types.ipv4_addr() | nil
  def get_host(addr) when is_ipv4(addr), do: if(host?(addr), do: addr.address, else: nil)

  @spec host?(IpV4.t()) :: boolean()
  def host?(addr) when is_ipv4(addr) do
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

  def network?(addr) when is_ipv4(addr) do
    address = to_integer(addr.address)
    inverse_mask = addr.mask |> mask() |> to_integer() |> bnot()

    (address &&& inverse_mask) == 0
  end

  @spec in_network?(IpV4.t(), IpV4.t()) :: boolean()
  def in_network?(target_addr, network_addr)
      when is_ipv4(target_addr) and is_ipv4(network_addr) do
    cond do
      not network?(network_addr) ->
        raise MscmpSystError,
          code: :undefined_error,
          message: "No identifiable network was provided.",
          cause: %{parameters: %{target_addr: target_addr, network_addr: network_addr}}

      target_addr.mask < network_addr.mask ->
        # a larger target_addr network cannot be contained by a smaller
        # network_addr network.
        false

      true ->
        extracted_target =
          %IpV4{address: target_addr.address, mask: network_addr.mask} |> get_network()

        extracted_network = get_network(network_addr)

        extracted_target === extracted_network
    end
  end

  @spec in_range?(IpV4.t(), IpV4.t(), IpV4.t()) :: boolean()
  def in_range?(target_addr, low_addr, high_addr)
      when is_ipv4(target_addr) and is_ipv4(low_addr) and is_ipv4(high_addr) do
    target_is_host = host?(target_addr)
    high_is_network = network?(high_addr)

    target_hi =
      if target_is_host do
        target_addr.address |> to_integer()
      else
        get_highest_address(target_addr)
      end

    target_low =
      if target_is_host do
        target_addr.address |> to_integer()
      else
        get_network(target_addr) |> to_integer()
      end

    low_resolved = low_addr.address |> to_integer()

    high_resolved =
      if high_is_network do
        get_highest_address(high_addr)
      else
        high_addr.address |> to_integer()
      end

    target_low >= low_resolved and target_hi <= high_resolved
  end

  @spec to_struct(Types.ipv4_addr(), Types.ipv4_mask() | nil) :: IpV4.t()
  def to_struct(erlang_addr, mask) when is_ipv4_tuple(erlang_addr),
    do: %IpV4{address: erlang_addr, mask: mask || 32}

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
