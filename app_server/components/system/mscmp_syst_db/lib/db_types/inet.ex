# Source File: inet.ex
# Location:    musebms/components/system/mscmp_syst_db/lib/db_types/inet.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.DbTypes.Inet do
  use Ecto.Type

  alias MscmpSystDb.DbTypes.Impl

  @moduledoc """
  An Elixir representation of the PostgreSQL `inet` and `cidr` data types.

  Derived from the Postgrex.INET data type.  For more information about this
  data type, see: [The PostgreSQL Documentation: Network Address Types](https://www.postgresql.org/docs/current/datatype-net-types.html)
  """

  @type t :: %__MODULE__{address: :inet.ip_address(), netmask: nil | 0..128}

  defstruct address: nil, netmask: nil

  @spec type :: :inet
  @impl true
  @doc false
  def type, do: :inet

  @spec cast(any()) :: {:ok, t()} | :error
  @impl true
  @doc false
  def cast(%__MODULE__{} = value), do: {:ok, value}
  def cast(_), do: :error

  @spec load(any()) :: {:ok, t()} | :error
  @impl true
  @doc false
  def load(%Postgrex.INET{
        address: address,
        netmask: netmask
      }) do
    {:ok,
     %__MODULE__{
       address: address,
       netmask: netmask
     }}
  end

  def load(_), do: :error

  @spec dump(t()) :: {:ok, Postgrex.INET.t()} | :error
  @impl true
  @doc false
  def dump(%__MODULE__{
        address: address,
        netmask: netmask
      }) do
    {:ok, %Postgrex.INET{address: address, netmask: netmask}}
  end

  def dump(_), do: :error

  @doc """
  Converts a network address represented as a `t:MscmpSystDb.DbTypes.Inet.t/0`
  value into one represented as a `t:Postgrex.INET.t/0` value.
  """
  @spec to_postgrex_inet(t()) :: Postgrex.INET.t()
  defdelegate to_postgrex_inet(address), to: Impl.Inet

  @doc """
  Converts a network address represented as a `t:Postgrex.INET.t/0`
  value into one represented as a `t:MscmpSystDb.DbTypes.Inet.t/0` value.
  """
  @spec from_postgrex_inet(Postgrex.INET.t()) :: t()
  defdelegate from_postgrex_inet(address), to: Impl.Inet

  @doc """
  Converts a network address represented as a `t:MscmpSystDb.DbTypes.Inet.t/0`
  value into one represented as either a `t:IP.addr/0` or `t:IP.Subnet.t/0`
  value.
  """
  @spec to_net_address(t()) :: IP.addr() | IP.Subnet.t()
  defdelegate to_net_address(address_or_network), to: Impl.Inet

  @doc """
  Converts a network address represented either as a `t:IP.addr/0` or
  `t:IP.Subnet.t/0` value into one represented as a
  `t:MscmpSystDb.DbTypes.Inet.t/0` value.
  """
  @spec from_net_address(IP.addr() | IP.Subnet.t()) :: t()
  defdelegate from_net_address(address_or_network), to: Impl.Inet
end
