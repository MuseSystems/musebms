# Source File: cidr.ex
# Location:    musebms/app_server/components/system/mscmp_syst_network/lib/impl/cidr.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystNetwork.Impl.Cidr do
  @moduledoc false

  alias MscmpSystNetwork.Types
  alias MscmpSystNetwork.Types.{IpV4, IpV6}

  require Logger

  @spec parse!(String.t(), list()) :: Types.addr_structs()
  def parse!(cidr_string, _modifiers), do: parse!(cidr_string)

  @spec parse!(String.t()) :: Types.addr_structs()
  def parse!(cidr_string) do
    [addr_str, mask_str] = cidr_string |> String.split("/") |> parse_split()
    {:ok, address} = addr_str |> to_charlist() |> :inet.parse_address()
    mask = parse_mask_str(address, mask_str)
    to_ip_struct(address, mask)
  end

  @spec parse(String.t()) :: {:ok, Types.addr_structs()} | {:error, MscmpSystError.t()}
  def parse(cidr_string) do
    {:ok, parse!(cidr_string)}
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure parsing IP address or subnet address string.",
         cause: error
       }}
  end

  defp parse_split([addr_str, mask_str]), do: [addr_str, mask_str]
  defp parse_split([addr_str]), do: [addr_str, nil]

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
end
