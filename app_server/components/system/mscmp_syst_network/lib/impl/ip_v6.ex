# Source File: ip_v6.ex
# Location:    musebms/app_server/components/system/mscmp_syst_network/lib/impl/ip_v6.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystNetwork.Impl.IpV6 do
  @moduledoc false

  import Bitwise

  import MscmpSystNetwork.Guards, only: [is_ipv6: 1, is_ipv6_tuple: 1, is_ipv6_mask: 1]

  alias MscmpSystNetwork.Types
  alias MscmpSystNetwork.Types.IpV6

  ##############################################################################
  #
  # to_string
  #
  #

  @spec to_string(IpV6.t()) :: String.t()
  def to_string(addr) when is_ipv6(addr) do
    address = addr.address |> :inet.ntoa() |> List.to_string()
    mask = Integer.to_string(addr.mask)
    address <> "/" <> mask
  end

  ##############################################################################
  #
  # get_netmask
  #
  #

  @spec get_netmask(IpV6.t()) :: Types.ipv6_addr()
  def get_netmask(addr) when is_ipv6(addr), do: mask(addr.mask)

  ##############################################################################
  #
  # get_network
  #
  #

  @spec get_network(IpV6.t()) :: Types.ipv6_addr() | nil
  def get_network(%IpV6{mask: 128}), do: nil

  def get_network(addr) when is_ipv6(addr) do
    address = to_integer(addr.address)
    mask = addr.mask |> mask() |> to_integer()

    band(address, mask) |> from_integer()
  end

  ##############################################################################
  #
  # get_host
  #
  #

  @spec get_host(IpV6.t()) :: Types.ipv6_addr() | nil
  def get_host(addr) when is_ipv6(addr), do: if(host?(addr), do: addr.address, else: nil)

  ##############################################################################
  #
  # host?
  #
  #

  @spec host?(IpV6.t()) :: boolean()
  def host?(addr) when is_ipv6(addr), do: if(network?(addr), do: false, else: true)

  ##############################################################################
  #
  # network?
  #
  #

  @spec network?(IpV6.t()) :: boolean()
  def network?(%IpV6{mask: 128}), do: false

  def network?(addr) when is_ipv6(addr) do
    address = to_integer(addr.address)
    inverse_mask = addr.mask |> mask() |> to_integer() |> bnot()

    (address &&& inverse_mask) == 0
  end

  ##############################################################################
  #
  # in_network?
  #
  #

  @spec in_network?(IpV6.t(), IpV6.t()) :: boolean()
  def in_network?(target_addr, network_addr)
      when is_ipv6(target_addr) and is_ipv6(network_addr) do
    cond do
      not network?(network_addr) ->
        raise Mserror.NetworkError,
          kind: :invalid_network,
          message: "The network value provided does not represent a valid network.",
          context: %MscmpSystError.Types.Context{
            parameters: %{target_addr: target_addr, network_addr: network_addr},
            origin: {__MODULE__, :in_network?, 2}
          }

      target_addr.mask < network_addr.mask ->
        # a larger target_addr network cannot be contained by a smaller
        # network_addr network.
        false

      true ->
        extracted_target =
          %IpV6{address: target_addr.address, mask: network_addr.mask} |> get_network()

        extracted_network = get_network(network_addr)

        extracted_target === extracted_network
    end
  end

  ##############################################################################
  #
  # in_range?
  #
  #

  @spec in_range?(IpV6.t(), IpV6.t(), IpV6.t()) :: boolean()
  def in_range?(target_addr, low_addr, high_addr)
      when is_ipv6(target_addr) and is_ipv6(low_addr) and is_ipv6(high_addr) do
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

  ##############################################################################
  #
  # to_struct
  #
  #

  @spec to_struct(Types.ipv6_addr(), Types.ipv6_mask() | nil) ::
          {:ok, IpV6.t()} | {:error, :invalid_ipv6_address_or_mask}
  def to_struct(erlang_addr, mask)
      when is_ipv6_tuple(erlang_addr) and (is_ipv6_mask(mask) or is_nil(mask)),
      do: {:ok, %IpV6{address: erlang_addr, mask: mask || 128}}

  def to_struct(_, _), do: {:error, :invalid_ipv6_address_or_mask}

  ##############################################################################
  #
  # General support functions
  #
  #

  defp to_integer({a, b, c, d, e, f, g, h} = ip) when is_ipv6_tuple(ip) do
    <<i::unsigned-integer-size(128)>> =
      <<a::unsigned-integer-size(16), b::unsigned-integer-size(16), c::unsigned-integer-size(16),
        d::unsigned-integer-size(16), e::unsigned-integer-size(16), f::unsigned-integer-size(16),
        g::unsigned-integer-size(16), h::unsigned-integer-size(16)>>

    i
  end

  defp from_integer(i)
       when is_integer(i) and i >= 0 and i <= 0xFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF do
    <<a::unsigned-integer-size(16), b::unsigned-integer-size(16), c::unsigned-integer-size(16),
      d::unsigned-integer-size(16), e::unsigned-integer-size(16), f::unsigned-integer-size(16),
      g::unsigned-integer-size(16), h::unsigned-integer-size(16)>> = <<i::128>>

    {a, b, c, d, e, f, g, h}
  end

  defp mask(bit_length) do
    <<a::unsigned-integer-size(16), b::unsigned-integer-size(16), c::unsigned-integer-size(16),
      d::unsigned-integer-size(16), e::unsigned-integer-size(16), f::unsigned-integer-size(16),
      g::unsigned-integer-size(16),
      h::unsigned-integer-size(16)>> = <<-1 <<< (128 - bit_length)::128>>

    {a, b, c, d, e, f, g, h}
  end

  defp get_highest_address(addr) do
    address = addr.address |> to_integer()

    inverse_mask =
      get_netmask(addr)
      |> to_integer()
      |> bnot()
      |> band(0xFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF)

    address ||| inverse_mask
  end
end
