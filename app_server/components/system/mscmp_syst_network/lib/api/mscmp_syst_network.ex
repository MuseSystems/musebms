# Source File: mscmp_syst_network.ex
# Location:    musebms/app_server/components/system/mscmp_syst_network/lib/api/mscmp_syst_network.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystNetwork do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias MscmpSystNetwork.Impl
  alias MscmpSystNetwork.Types

  ##############################################################################
  #
  # parse
  #
  #

  @doc section: :parse_api
  @doc """
  Parses common IP address and subnet text expressions from a string.

  For simple IP addresses, the expected format of the string parameter is the
  common format for such addresses.  For IPv4 addresses, this would be
  "dotted-decimal" form.  For IPv6 addresses, the expected
  string uses a textual representation of the address that complies with
  [RFC 5952](https://www.rfc-editor.org/rfc/rfc5952.html).

  For subnet addresses the expected format in the CIDR addressing style
  appropriate for either IPv4 or IPv6 .

  Individual host addresses may also be expressed in CIDR notation.  IPv4 host
  addresses should use the standard "/32" designation for mask bits and IPv6
  hosts in CIDR notation should use a prefix of "/128".  These are the
  traditional or standard expressions for hosts when CIDR notation is used in
  this way.  Note that even when the simple addressing format is used structs
  will have a `:mask` value of 32 for IPv4 or 128 for IPv6.

  On a successful parse, an `:ok` tuple is returning including either an
  `t:MscmpSystNetwork.Types.IpV4.t/0` or `t:MscmpSystNetwork.Types.IpV6.t/0`
  value.  If the parse fails,

  ## Parameters

    * `addr_string` - Either a simple IP host address or an IP address or IP
    subnet in CIDR notation.  Passed as a string.

  ## Examples

    IPv4 addresses

      iex> MscmpSystNetwork.parse("192.168.10.10")
      {:ok, %MscmpSystNetwork.Types.IpV4{address: {192, 168, 10, 10}, mask: 32}}

      iex> MscmpSystNetwork.parse("10.1.1.10/32")
      {:ok, %MscmpSystNetwork.Types.IpV4{address: {10, 1, 1, 10}, mask: 32}}

      iex> MscmpSystNetwork.parse("10.1.1.11/8")
      {:ok, %MscmpSystNetwork.Types.IpV4{address: {10, 1, 1, 11}, mask: 8}}

      iex> MscmpSystNetwork.parse("172.16.0.0/16")
      {:ok, %MscmpSystNetwork.Types.IpV4{address: {172, 16, 0, 0}, mask: 16}}

    IPv4 Error Example

      iex> MscmpSystNetwork.parse("192.618.10.14/32")
      {:error,
        %Mserror.NetworkError{
          kind: :parse_error,
          message: "Error parsing IP address or network",
          cause: %Mserror.NetworkError{
            kind: :parse_error,
            message: "Error returned by :inet.parse_address/1",
            cause: {:error, :einval},
            context: %MscmpSystError.Types.Context{
              parameters: %{cidr_string: "192.618.10.14/32"},
              origin: {MscmpSystNetwork.Impl.Ip, :parse, 1}
            }
          },
          context: %MscmpSystError.Types.Context{
            parameters: %{addr_string: "192.618.10.14/32"}
          }
        }
      }

    IPv6 addresses

      iex> MscmpSystNetwork.parse("fd9b:77f8:714d:cabb::1")
      {
        :ok,
        %MscmpSystNetwork.Types.IpV6{
          address: {64923, 30712, 29005, 51899, 0, 0, 0, 1},
          mask: 128
        }
      }

      iex> MscmpSystNetwork.parse("fd9b:77f8:714d:cabb::20/128")
      {
        :ok,
        %MscmpSystNetwork.Types.IpV6{
          address: {64923, 30712, 29005, 51899, 0, 0, 0, 32},
          mask: 128
        }
      }

      iex> MscmpSystNetwork.parse("fd9b:77f8:714d:cabb:0000:0000:ab67:12/64")
      {
        :ok,
        %MscmpSystNetwork.Types.IpV6{
          address: {64923, 30712, 29005, 51899, 0, 0, 43879, 18},
          mask: 64
        }
      }

      iex> MscmpSystNetwork.parse("fd9b:77f8:714d:cabb::/64")
      {
        :ok,
        %MscmpSystNetwork.Types.IpV6{
          address: {64923, 30712, 29005, 51899, 0, 0, 0, 0},
          mask: 64
        }
      }

    IPv6 Error Example

      iex> MscmpSystNetwork.parse("fd9b:77f8:714d:qqqq::z")
      {:error,
        %Mserror.NetworkError{
          kind: :parse_error,
          message: "Error parsing IP address or network",
          cause: %Mserror.NetworkError{
            kind: :parse_error,
            message: "Error returned by :inet.parse_address/1",
            cause: {:error, :einval},
            context: %MscmpSystError.Types.Context{
              parameters: %{cidr_string: "fd9b:77f8:714d:qqqq::z"},
              origin: {MscmpSystNetwork.Impl.Ip, :parse, 1}
            }
          },
          context: %MscmpSystError.Types.Context{
            parameters: %{addr_string: "fd9b:77f8:714d:qqqq::z"}
          }
        }
      }
  """
  @spec parse(String.t()) :: {:ok, Types.addr_structs()} | {:error, Mserror.NetworkError.t()}
  def parse(addr_string) do
    {:ok, parse!(addr_string)}
  rescue
    error in Mserror.NetworkError ->
      {:error,
       Mserror.NetworkError.new(:parse_error, "Error parsing IP address or network",
         cause: error,
         context: %MscmpSystError.Types.Context{parameters: %{addr_string: addr_string}}
       )}
  end

  @doc section: :parse_api
  @doc """
  Parses common IP address and subnet text expressions from a string, raising
  an exception when there are errors.

  Outside of the possibility of raising an exception, this function works the
  same as `parse/1` in all other ways.

  ## Parameters

    * `addr_string` - Either a simple IP host address or an IP address or IP
    subnet in CIDR notation.  Passed as a string.

  ## Examples

    IPv4 addresses

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.parse!("192.168.10.10")
      %MscmpSystNetwork.Types.IpV4{address: {192, 168, 10, 10}, mask: 32}
      iex> MscmpSystNetwork.parse!("10.1.1.11/8")
      %MscmpSystNetwork.Types.IpV4{address: {10, 1, 1, 11}, mask: 8}

    IPv4 Error Example

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.parse!("192.618.10.14/32")
      ** (Mserror.NetworkError) Error returned by :inet.parse_address/1

    IPv6 addresses

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.parse!("fd9b:77f8:714d:cabb::1")
      %MscmpSystNetwork.Types.IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 1}, mask: 128}
      iex> MscmpSystNetwork.parse!("fd9b:77f8:714d:cabb:0000:0000:ab67:12/64")
      %MscmpSystNetwork.Types.IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 43879, 18}, mask: 64}

    IPv6 Error Example

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.parse!("fd9b:77f8:714d:qqqq::z")
      ** (Mserror.NetworkError) Error returned by :inet.parse_address/1
  """
  @spec parse!(String.t()) :: Types.addr_structs()
  defdelegate parse!(addr_string), to: Impl.Ip, as: :parse

  ##############################################################################
  #
  # sigil_i
  #
  #

  @doc section: :parse_api
  @doc """
  Handles the ~i sigil for IP addresses.

  Currently there are no modifiers accepted by this sigil.  The sigil is simply
  a convenience which calls `parse!/1`.

  Returns either a `t:MscmpSystNetwork.Types.IpV4.t/0` or
  `t:MscmpSystNetwork.Types.IpV6.t/0` struct.

  ## Parameters

    * `addr_string` - Either a simple IP host address or an IP address or IP
    subnet in CIDR notation.  Passed as a string.

    * `modifiers` - Currently there are no modifiers which are to be used with
    the sigil.  This parameter is currently ignored.

  ## Examples

    IPv4 Addresses

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> ~i"192.168.10.10"
      %MscmpSystNetwork.Types.IpV4{address: {192, 168, 10, 10}, mask: 32}
      iex> ~i"10.1.1.11/8"
      %MscmpSystNetwork.Types.IpV4{address: {10, 1, 1, 11}, mask: 8}

    IPv4 Error Example

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> ~i"192.618.10.14/32"
      ** (Mserror.NetworkError) Error returned by :inet.parse_address/1

    IPv6 Addresses

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> ~i"fd9b:77f8:714d:cabb::1"
      %MscmpSystNetwork.Types.IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 1}, mask: 128}
      iex> ~i"fd9b:77f8:714d:cabb:0000:0000:ab67:12/64"
      %MscmpSystNetwork.Types.IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 43879, 18}, mask: 64}

    IPv6 Error Example

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> ~i"fd9b:77f8:714d:qqqq::z"
      ** (Mserror.NetworkError) Error returned by :inet.parse_address/1
  """
  @spec sigil_i(String.t(), list()) :: Types.addr_structs()
  defdelegate sigil_i(addr_string, modifiers), to: Impl.Ip, as: :parse

  ##############################################################################
  #
  # to_struct
  #
  #

  @doc section: :parse_api
  @doc """
  Turns an Erlang `t::inet.ip_address/0` tuple into either a
  `t:MscmpSystNetwork.Types.IpV4.t/0` or `t:MscmpSystNetwork.Types.IpV6.t/0`
  struct.

  Raises on error.

  ## Parameters

    * `addr` - a tuple representing either the IPv4 or IPv6 address to be used
    in constructing the new struct.

    * `mask` - represents either the bit length of the IPv4 subnet mask or the
    IPv6 prefix.  This parameter is optional and if not provided or is nil will
    default to the single host value as appropriate for the `addr` type.

  ## Examples

    IPv4 Examples

      iex> MscmpSystNetwork.to_struct({10, 1, 1, 15})
      %MscmpSystNetwork.Types.IpV4{address: {10, 1, 1, 15}, mask: 32}
      iex> MscmpSystNetwork.to_struct({10, 1, 0, 0}, 16)
      %MscmpSystNetwork.Types.IpV4{address: {10, 1, 0, 0}, mask: 16}

    IPv6 Examples

      iex> MscmpSystNetwork.to_struct({64923, 30712, 29005, 51899, 0, 0, 0, 1})
      %MscmpSystNetwork.Types.IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 1}, mask: 128}
      iex> MscmpSystNetwork.to_struct({64923, 30712, 29005, 51899, 0, 0, 0, 0}, 64)
      %MscmpSystNetwork.Types.IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64}


  """
  @spec to_struct(Types.ipv4_addr(), Types.ipv4_mask() | nil) :: Types.IpV4.t()
  @spec to_struct(Types.ipv6_addr(), Types.ipv6_mask() | nil) :: Types.IpV6.t()
  defdelegate to_struct(addr, mask \\ nil), to: Impl.Ip

  # ==============================================================================================
  #
  # Network Address Protocol API
  #
  # ==============================================================================================

  ##############################################################################
  #
  # to_string
  #
  #

  @doc section: :protocol_api
  @doc """
  Converts an IP address struct implementing the `MscmpSystNetwork.Protocol` to
  its common string representation using CIDR notation.

  ## Parameters

    * `addr_struct` - Either a valid `t:MscmpSystNetwork.Types.IpV4.t/0` or
    `t:MscmpSystNetwork.Types.IpV6.t/0` struct which is to be converted to a
    string.

  ## Examples

    IPv4 Addresses

      iex> my_host = %MscmpSystNetwork.Types.IpV4{address: {192, 168, 10, 10}, mask: 32}
      iex> MscmpSystNetwork.to_string(my_host)
      "192.168.10.10/32"
      iex> my_subnet = %MscmpSystNetwork.Types.IpV4{address: {172, 16, 0, 0}, mask: 16}
      iex> MscmpSystNetwork.to_string(my_subnet)
      "172.16.0.0/16"

    IPv6 Addresses

      iex> my_host =
      ...>   %MscmpSystNetwork.Types.IpV6{
      ...>     address: {64923, 30712, 29005, 51899, 0, 0, 0, 1},
      ...>     mask: 128
      ...>   }
      iex> MscmpSystNetwork.to_string(my_host)
      "fd9b:77f8:714d:cabb::1/128"
      iex> my_subnet =
      ...>   %MscmpSystNetwork.Types.IpV6{
      ...>     address: {64923, 30712, 29005, 51899, 0, 0, 43879, 18},
      ...>     mask: 64
      ...>   }
      iex> MscmpSystNetwork.to_string(my_subnet)
      "fd9b:77f8:714d:cabb::ab67:12/64"
  """
  @spec to_string(Types.addr_structs()) :: String.t()
  defdelegate to_string(addr_struct), to: MscmpSystNetwork.Protocol

  ##############################################################################
  #
  # get_netmask
  #
  #

  @doc section: :protocol_api
  @doc """
  Retrieves the network masking bits (IPv4 subnet mask or IPv6 prefix).

  Results are returned in the form of an Erlang `t::inet.ip_address/0` tuple.

  ## Parameters

    * `addr_struct` - Either a valid `t:MscmpSystNetwork.Types.IpV4.t/0` or
    `t:MscmpSystNetwork.Types.IpV6.t/0` struct from which a network mask
    should be extracted.

  ## Examples

    IPv4 Examples

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.get_netmask(~i"192.168.20.125/24")
      {255, 255, 255, 0}
      iex> MscmpSystNetwork.get_netmask(~i"10.1.1.12/32")
      {255, 255, 255, 255}

    IPv4 Examples

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.get_netmask(~i"fd9b:77f8:714d:cabb:0000:0000:ab67:12/64")
      {65535, 65535, 65535, 65535, 0, 0, 0, 0}
      iex> MscmpSystNetwork.get_netmask(~i"fd9b:77f8:714d:cabb::20/128")
      {65535, 65535, 65535, 65535, 65535, 65535, 65535, 65535}
  """
  @spec get_netmask(Types.IpV4.t()) :: Types.ipv4_addr()
  @spec get_netmask(Types.IpV6.t()) :: Types.ipv6_addr()
  defdelegate get_netmask(addr_struct), to: MscmpSystNetwork.Protocol

  ##############################################################################
  #
  # get_network
  #
  #

  @doc section: :protocol_api
  @doc """
  Retrieves the network identifying portion of an IP address.

  Results are returned in the form of an Erlang `t::inet.ip_address/0` tuple or
  `nil` when the address passed to the function represents a single host.

  ## Parameters

    * `addr_struct` - Either a valid `t:MscmpSystNetwork.Types.IpV4.t/0` or
    `t:MscmpSystNetwork.Types.IpV6.t/0` struct from which a network address
    should extracted.

  ## Examples

    IPv4 Examples

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.get_network(~i"192.168.20.125/24")
      {192, 168, 20, 0}
      iex> MscmpSystNetwork.get_network(~i"10.1.1.12/32")
      nil

    IPv4 Examples

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.get_network(~i"fd9b:77f8:714d:cabb:0000:0000:ab67:12/64")
      {64923, 30712, 29005, 51899, 0, 0, 0, 0}
      iex> MscmpSystNetwork.get_network(~i"fd9b:77f8:714d:cabb::20/128")
      nil
  """
  @spec get_network(Types.IpV4.t()) :: Types.ipv4_addr() | nil
  @spec get_network(Types.IpV6.t()) :: Types.ipv6_addr() | nil
  defdelegate get_network(addr_struct), to: MscmpSystNetwork.Protocol

  ##############################################################################
  #
  # get_host
  #
  #

  @doc section: :protocol_api
  @doc """
  Retrieves IP address from IP address structs or `nil` if the struct only
  represents a subnet/prefix.

  Results are returned in the form of an Erlang `t::inet.ip_address/0` tuple or
  `nil` when the address passed to the function doesn't represent a host
  address.

  ## Parameters

    * `addr_struct` - Either a valid `t:MscmpSystNetwork.Types.IpV4.t/0` or
    `t:MscmpSystNetwork.Types.IpV6.t/0` struct from which a host IP address is
    to be extracted.

  ## Examples

    IPv4 Examples

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.get_host(~i"192.168.20.125/24")
      {192, 168, 20, 125}
      iex> MscmpSystNetwork.get_host(~i"10.0.0.0/8")
      nil

    IPv4 Examples

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.get_host(~i"fd9b:77f8:714d:cabb:0000:0000:ab67:12/64")
      {64923, 30712, 29005, 51899, 0, 0, 43879, 18}
      iex> MscmpSystNetwork.get_host(~i"fd9b:77f8:714d:cabb::/64")
      nil
  """
  @spec get_host(Types.IpV4.t()) :: Types.ipv4_addr() | nil
  @spec get_host(Types.IpV6.t()) :: Types.ipv6_addr() | nil
  defdelegate get_host(addr_struct), to: MscmpSystNetwork.Protocol

  ##############################################################################
  #
  # host?
  #
  #

  @doc section: :protocol_api
  @doc """
  Evaluates an IP address struct to see if it represents a specific host or not.

  If the function finds that an identifiable host is represented by the struct,
  the function returns true.  Otherwise false.

  IPv4 broadcast addresses will also return false.

  > #### Other Non-address IPs {: .warning}
  >
  > Multicast addresses are currently not detected as will be treated as regular
  > IP addresses.  Therefore this function will return true for multicast
  > addresses where it should return false.
  >
  > Other examples of this sort of issue may exist for other, similar special
  > cases.  You should not assume that the IP address business logic in this
  > Component is authoritative or complete.  Test any special cases specifically
  > for compliance with the area in which you are working.

  ## Parameters

    * `addr_struct` - Either a valid `t:MscmpSystNetwork.Types.IpV4.t/0` or
    `t:MscmpSystNetwork.Types.IpV6.t/0` struct to test for representing a
    specific host.

  ## Examples

    IPv4 Examples

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.host?(~i"192.168.20.125/24")
      true
      iex> MscmpSystNetwork.host?(~i"10.0.0.0/8")
      false

    IPv4 Examples

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.host?(~i"fd9b:77f8:714d:cabb:0000:0000:ab67:12/64")
      true
      iex> MscmpSystNetwork.host?(~i"fd9b:77f8:714d:cabb::/64")
      false
  """
  @spec host?(Types.addr_structs()) :: boolean()
  defdelegate host?(addr_struct), to: MscmpSystNetwork.Protocol

  ##############################################################################
  #
  # network?
  #
  #

  @doc section: :protocol_api
  @doc """
  Evaluates an IP address struct to see if it represents an entire network or
  subnet rather than a host.

  This function only returns true when the supplied IP address represents only a
  network or subnet.  False is returned when the provided IP address struct
  also contains an identifiable host or is only a host.  False is even returned
  in cases where the CIDR notation would allow a network to be extracted from
  the provided IP address struct.

  > #### Other Non-address IPs {: .warning}
  >
  > Multicast addresses are currently not detected as will be treated as regular
  > IP addresses.  Therefore this function will return true for multicast
  > addresses where it should return false.
  >
  > You should not assume that the IP address business logic in this Component
  > is authoritative or complete.  Test any special cases specifically for
  > compliance with the area in which you are working.

  ## Parameters

    * `addr_struct` - Either a valid `t:MscmpSystNetwork.Types.IpV4.t/0` or
    `t:MscmpSystNetwork.Types.IpV6.t/0` struct which to test as identifying a
    network exclusively.

  ## Examples

    IPv4 Examples

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.network?(~i"192.168.20.125/24")
      false
      iex> MscmpSystNetwork.network?(~i"10.0.0.0/8")
      true

    IPv4 Examples

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.network?(~i"fd9b:77f8:714d:cabb:0000:0000:ab67:12/64")
      false
      iex> MscmpSystNetwork.network?(~i"fd9b:77f8:714d:cabb::/64")
      true
  """
  @spec network?(Types.addr_structs()) :: boolean()
  defdelegate network?(addr_struct), to: MscmpSystNetwork.Protocol

  ##############################################################################
  #
  # in_network?
  #
  #

  @doc section: :protocol_api
  @doc """
  Tests to see if an IP host or subnet is contained by a specific subnet.

  True is returned when the test address is contained by the given network,
  otherwise false is returned.  Any error raises an exception.

  ## Parameters

    * `test_addr` - any valid IP address struct.  This struct can represent an
    individual host or a subnet.

    * `network_addr` - a valid IP address struct which only represents a
    network.  Host addresses from which a network can be extracted such as
    `10.1.1.113/24` will still cause an exception to be raised; only network
    only addresses such as `10.1.1.0/24` are accepted.  See
    `MscmpSystNetwork.get_network/1` for extracting a network address from a
    host address with an identifiable network.

  ## Examples

    IPv4 Examples

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.in_network?(~i"10.1.1.10", ~i"10.1.0.0/16")
      true
      iex> MscmpSystNetwork.in_network?(~i"10.1.1.0/24", ~i"10.1.0.0/16")
      true
      iex> MscmpSystNetwork.in_network?(~i"10.1.1.0/24", ~i"10.1.1.0/24")
      true
      iex> MscmpSystNetwork.in_network?(~i"10.2.1.1/32", ~i"10.1.0.0/16")
      false

    IPv6 Examples

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.in_network?(
      ...>   ~i"fd9b:77f8:714d:cabb::20/128", ~i"fd9b:77f8:714d:cabb::/64")
      true
      iex> MscmpSystNetwork.in_network?(
      ...>   ~i"fd9b:77f8:714d:cabb:ab67::/68", ~i"fd9b:77f8:714d:cabb::/64")
      true
      iex> MscmpSystNetwork.in_network?(
      ...>   ~i"fd9b:77f8:714d:cabb::/64", ~i"fd9b:77f8:714d:cabb::/64")
      true
      iex> MscmpSystNetwork.in_network?(
      ...>   ~i"fd9b:77f8:714d:caab::20/128", ~i"fd9b:77f8:714d:cabb::/64")
      false

  """
  @spec in_network?(Types.IpV4.t(), Types.IpV4.t()) :: boolean()
  @spec in_network?(Types.IpV6.t(), Types.IpV6.t()) :: boolean()
  defdelegate in_network?(test_addr, network_addr), to: MscmpSystNetwork.Protocol

  ##############################################################################
  #
  # in_range?
  #
  #

  @doc section: :protocol_api
  @doc """
  Tests if an IP address host or subnet is contained by the given range.

  True is returned when the IP address is contained, otherwise false.  Errors
  raise exceptions.

  ## Parameters

    * `test_addr` - a valid IP address struct which must be fully contained by
    the low and high IP addresses to obtain  a true result.

    * `low_addr` - The low address of the range.  If the `low_addr` value is a
    struct identifying a host, but from which a network could be extracted, it
    is treated as a host only.  If the struct represents only a network or
    subnet, the network IP address itself is treated as the lowest IP address
    in the range; for example `10.1.0.0/16` will treat `10.1.0.0` as the lowest
    IP address in the range.

    * `high_addr` - the high address of the range.  If the `high_addr` value is
    a struct identifying a host, but from which a network could be extracted, it
    is treated as a host only.  If the struct represents only a network or
    subnet, the network's largest possible IP address is considered the high
    address of the range; for example `10.1.0.0/16` would consider
    `10.1.255.255` as the highest address in the range.

  The range boundaries are considered inclusive at both extremes.

  ## Examples

    IPv4 Examples

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.in_range?(~i"10.1.1.10", ~i"10.1.1.1", ~i"10.1.1.15")
      true
      iex> MscmpSystNetwork.in_range?(~i"10.1.1.0/24", ~i"10.1.0.0/16", ~i"10.1.2.254")
      true
      iex> MscmpSystNetwork.in_range?(~i"10.1.1.0/24", ~i"10.1.1.0/24", ~i"10.1.1.0/24")
      true
      iex> MscmpSystNetwork.in_range?(~i"10.3.1.1/32", ~i"10.1.0.0/16", ~i"10.2.0.0/16")
      false

    IPv6 Examples

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.in_range?(
      ...>   ~i"fd9b:77f8:714d:cabb::20",
      ...>   ~i"fd9b:77f8:714d:cabb::10",
      ...>   ~i"fd9b:77f8:714d:cabb::30")
      true
      iex> MscmpSystNetwork.in_range?(
      ...>   ~i"fd9b:77f8:714d:cabb:ab67::/68",
      ...>   ~i"fd9b:77f8:714d:cabb::/64",
      ...>   ~i"fd9b:77f8:714d:cabd::")
      true
      iex> MscmpSystNetwork.in_range?(
      ...>   ~i"fd9b:77f8:714d:cabb::/64",
      ...>   ~i"fd9b:77f8:714d:cabb::/64",
      ...>   ~i"fd9b:77f8:714d:cabb::/64")
      true
      iex> MscmpSystNetwork.in_range?(
      ...>   ~i"fd9b:77f8:714e:caab::20/128",
      ...>   ~i"fd9b:77f8:714d:caba::/64",
      ...>   ~i"fd9b:77f8:714d:cabc::/64")
      false

  """
  @spec in_range?(Types.IpV4.t(), Types.IpV4.t(), Types.IpV4.t()) :: boolean()
  @spec in_range?(Types.IpV6.t(), Types.IpV6.t(), Types.IpV6.t()) :: boolean()
  defdelegate in_range?(test_addr, low_addr, high_addr), to: MscmpSystNetwork.Protocol
end
