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

  require Logger

  ##############################################################################
  #
  # to_struct
  #
  #

  @spec to_struct(Types.ipv4_addr(), Types.ipv4_mask() | nil) ::
          {:ok, Types.IpV4.t()} | {:error, reason :: term()}
  @spec to_struct(Types.ipv6_addr(), Types.ipv6_mask() | nil) ::
          {:ok, Types.IpV6.t()} | {:error, reason :: term()}
  def to_struct(addr, mask) when is_ipv4_tuple(addr) and (is_ipv4_mask(mask) or is_nil(mask)),
    do: Impl.IpV4.to_struct(addr, mask)

  def to_struct(addr, mask) when is_ipv6_tuple(addr) and (is_ipv6_mask(mask) or is_nil(mask)),
    do: Impl.IpV6.to_struct(addr, mask)

  def to_struct(_, _), do: {:error, :invalid_address_or_mask}

  ##############################################################################
  #
  # parse
  #
  #

  @spec parse(String.t(), list()) ::
          {:ok, Types.addr_structs()} | {:error, reason :: term()}
  def parse(cidr_string, _modifiers), do: parse(cidr_string)

  @spec parse(String.t()) :: {:ok, Types.addr_structs()} | {:error, reason :: term()}
  def parse(cidr_string) do
    with {:ok, [addr_str, mask_str]} <- cidr_string |> String.split("/") |> parse_split(),
         {:ok, address} <- addr_str |> to_charlist() |> :inet.parse_address(),
         {:ok, mask} <- parse_mask_str(address, mask_str) do
      to_struct(address, mask)
    end
  end

  defp parse_split([addr_str, mask_str]), do: {:ok, [addr_str, mask_str]}
  defp parse_split([addr_str]), do: {:ok, [addr_str, nil]}

  defp parse_split(_) do
    {:error, :invalid_cidr_format}
  end

  defp parse_mask_str({_, _, _, _}, nil), do: {:ok, 32}

  defp parse_mask_str({_, _, _, _}, mask_str) do
    {return_value, _} = Integer.parse(mask_str)
    {:ok, return_value}
  end

  defp parse_mask_str({_, _, _, _, _, _, _, _}, nil), do: {:ok, 128}

  defp parse_mask_str({_, _, _, _, _, _, _, _}, mask_str) do
    {return_value, _} = Integer.parse(mask_str)
    {:ok, return_value}
  end
end
