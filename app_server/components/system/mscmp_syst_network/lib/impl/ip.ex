# Source File: ip.ex
# Location:    musebms/app_server/components/system/mscmp_syst_network/lib/impl/ip.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystNetwork.Impl.Ip do
  @moduledoc false

  import MscmpSystNetwork.Guards,
    only: [is_ipv4_tuple: 1, is_ipv6_tuple: 1, is_ipv4_mask: 1, is_ipv6_mask: 1]

  alias MscmpSystNetwork.Impl
  alias MscmpSystNetwork.Types
  alias MscmpSystNetwork.Types.{IpV4, IpV6}

  require Logger

  ##############################################################################
  #
  # to_struct
  #
  #

  @spec to_struct(Types.ipv4_addr(), Types.ipv4_mask() | nil) :: Types.IpV4.t()
  @spec to_struct(Types.ipv6_addr(), Types.ipv6_mask() | nil) :: Types.IpV6.t()
  def to_struct(addr, mask) when is_ipv4_tuple(addr) and (is_ipv4_mask(mask) or is_nil(mask)),
    do: Impl.IpV4.to_struct(addr, mask)

  def to_struct(addr, mask) when is_ipv6_tuple(addr) and (is_ipv6_mask(mask) or is_nil(mask)),
    do: Impl.IpV6.to_struct(addr, mask)

  ##############################################################################
  #
  # parse
  #
  #

  @spec parse(String.t(), list()) :: Types.addr_structs()
  def parse(cidr_string, _modifiers), do: parse(cidr_string)

  @spec parse(String.t()) :: Types.addr_structs()
  def parse(cidr_string) do
    [addr_str, mask_str] = cidr_string |> String.split("/") |> parse_split()

    case addr_str |> to_charlist() |> :inet.parse_address() do
      {:ok, address} ->
        mask = parse_mask_str(address, mask_str)
        to_ip_struct(address, mask)

      {:error, _} = error ->
        raise Mserror.NetworkError,
          kind: :parse,
          message: "Error returned by :inet.parse_address/1",
          cause: error,
          context: %MscmpSystError.Types.Context{
            parameters: %{cidr_string: cidr_string},
            origin: {__MODULE__, :parse, 1}
          }
    end
  end

  defp parse_split([addr_str, mask_str]), do: [addr_str, mask_str]
  defp parse_split([addr_str]), do: [addr_str, nil]

  defp parse_split(parse_chars) do
    raise Mserror.NetworkError,
      kind: :parse,
      message: "Failure parsing IP address or subnet address string.",
      context: %MscmpSystError.Types.Context{
        parameters: %{parse_chars: parse_chars},
        origin: {__MODULE__, :parse_split, 1}
      }
  end

  defp parse_mask_str({_, _, _, _}, nil), do: 32

  defp parse_mask_str({_, _, _, _}, mask_str) do
    {return_value, _} = Integer.parse(mask_str)
    return_value
  end

  defp parse_mask_str({_, _, _, _, _, _, _, _}, nil), do: 128

  defp parse_mask_str({_, _, _, _, _, _, _, _}, mask_str) do
    {return_value, _} = Integer.parse(mask_str)
    return_value
  end

  defp to_ip_struct({_, _, _, _} = address, mask) when mask >= 0 and mask <= 32,
    do: %IpV4{address: address, mask: mask}

  defp to_ip_struct({_, _, _, _, _, _, _, _} = address, mask) when mask >= 0 and mask <= 128,
    do: %IpV6{address: address, mask: mask}

  defp to_ip_struct(address, mask) do
    raise Mserror.NetworkError,
      kind: :parse,
      message: "Invalid IP address or subnet mask.",
      context: %MscmpSystError.Types.Context{
        parameters: %{address: address, mask: mask},
        origin: {__MODULE__, :to_ip_struct, 2}
      }
  end
end
