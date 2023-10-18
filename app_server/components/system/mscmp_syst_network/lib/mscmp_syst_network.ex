defmodule MscmpSystNetwork do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias MscmpSystNetwork.Impl
  alias MscmpSystNetwork.Types

  @doc section: :parse_api
  @doc """
  Parses common IP address and sub-net text expressions from a string.

  For simple IP addresses, the expected format of the string parameter is the
  common format for such addresses.  For IPv4 addresses, this would be
  "dotted-decimal" form.  For IPv6 addresses, the expected
  string uses a textual representation of the address that complies with
  [RFC 5952](https://www.rfc-editor.org/rfc/rfc5952.html).

  For sub-net addresses the expected format in the CIDR addressing style
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
    sub-net in CIDR notation.  Passed as a string.

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
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure parsing IP address or subnet address string.",
         cause: %MatchError{term: {:error, :einval}}
       }}

    IPv6 addresses

      iex> MscmpSystNetwork.parse("fd9b:77f8:714d:cabb::1")
      {:ok, %MscmpSystNetwork.Types.IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 1}, mask: 128}}

      iex> MscmpSystNetwork.parse("fd9b:77f8:714d:cabb::20/128")
      {:ok, %MscmpSystNetwork.Types.IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 32}, mask: 128}}

      iex> MscmpSystNetwork.parse("fd9b:77f8:714d:cabb:0000:0000:ab67:12/64")
      {:ok, %MscmpSystNetwork.Types.IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 43879, 18}, mask: 64}}

      iex> MscmpSystNetwork.parse("fd9b:77f8:714d:cabb::/64")
      {:ok, %MscmpSystNetwork.Types.IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0}, mask: 64}}

      IPv6 Error Example

      iex> MscmpSystNetwork.parse("fd9b:77f8:714d:qqqq::z")
      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure parsing IP address or subnet address string.",
         cause: %MatchError{term: {:error, :einval}}
       }}
  """
  @spec parse(String.t()) :: {:ok, Types.addr_structs()} | {:error, MscmpSystError.t()}
  defdelegate parse(addr_string), to: Impl.Cidr

  @doc section: :parse_api
  @doc """
  Parses common IP address and sub-net text expressions from a string, raising
  an exception when there are errors.

  Outside of the possibility of raising an exception, this function works the
  same as `parse/1` in all other ways.

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
      ** (MatchError) no match of right hand side value: {:error, :einval}

    IPv6 addresses

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.parse!("fd9b:77f8:714d:cabb::1")
      %MscmpSystNetwork.Types.IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 1}, mask: 128}
      iex> MscmpSystNetwork.parse!("fd9b:77f8:714d:cabb:0000:0000:ab67:12/64")
      %MscmpSystNetwork.Types.IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 43879, 18}, mask: 64}

    IPv6 Error Example

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> MscmpSystNetwork.parse!("fd9b:77f8:714d:qqqq::z")
      ** (MatchError) no match of right hand side value: {:error, :einval}
  """
  @spec parse!(String.t()) :: Types.addr_structs()
  defdelegate parse!(addr_string), to: Impl.Cidr

  @doc section: :parse_api
  @doc """
  Handles the ~i sigil for IP addresses.

  Currently there are no modifiers accepted by this sigil.  The sigil is simply
  a convenience which calls `parse!/1`.

  Returns either a `t:MscmpSystNetwork.Types.IpV4.t/0` or
  `t:MscmpSystNetwork.Types.IpV6.t/0` struct.

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
      ** (MatchError) no match of right hand side value: {:error, :einval}

    IPv6 Addresses

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> ~i"fd9b:77f8:714d:cabb::1"
      %MscmpSystNetwork.Types.IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 1}, mask: 128}
      iex> ~i"fd9b:77f8:714d:cabb:0000:0000:ab67:12/64"
      %MscmpSystNetwork.Types.IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 43879, 18}, mask: 64}

    IPv6 Error Example

      iex> import MscmpSystNetwork, only: [sigil_i: 2]
      iex> ~i"fd9b:77f8:714d:qqqq::z"
      ** (MatchError) no match of right hand side value: {:error, :einval}
  """
  @spec sigil_i(String.t(), list()) :: Types.addr_structs()
  defdelegate sigil_i(addr_string, modifiers), to: Impl.Cidr, as: :parse!

  # ==============================================================================================
  #
  # Permissions Protocol API
  #
  # ==============================================================================================

  @doc section: :protocol_api
  @doc """
  Converts an IP address struct implementing the `MscmpSystNetwork.Protocol` to
  its common string representation using CIDR notation.

  ## Examples

    IPv4 Addresses

      iex> my_host = %MscmpSystNetwork.Types.IpV4{address: {192, 168, 10, 10}, mask: 32}
      iex> MscmpSystNetwork.to_string(my_host)
      "192.168.10.10/32"
      iex> my_subnet = %MscmpSystNetwork.Types.IpV4{address: {172, 16, 0, 0}, mask: 16}
      iex> MscmpSystNetwork.to_string(my_subnet)
      "172.16.0.0/16"

    IPv6 Addresses

      iex> my_host = %MscmpSystNetwork.Types.IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 1}, mask: 128}
      iex> MscmpSystNetwork.to_string(my_host)
      "fd9b:77f8:714d:cabb::1/128"
      iex> my_subnet = %MscmpSystNetwork.Types.IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 43879, 18}, mask: 64}
      iex> MscmpSystNetwork.to_string(my_subnet)
      "fd9b:77f8:714d:cabb::ab67:12/64"
  """
  @spec to_string(Types.addr_structs()) :: String.t()
  defdelegate to_string(addr_struct), to: MscmpSystNetwork.Protocol

  @doc section: :protocol_api
  @doc """
  Retrieves the network masking bits (IPv4 subnet mask or IPv6 prefix).

  Results are returned in the form of an
  [Erlang `ip_address()`](https://www.erlang.org/doc/man/inet#type-ip_address)
  tuple.

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
  @spec get_netmask(Types.addr_structs()) :: Types.addr()
  defdelegate get_netmask(addr_struct), to: MscmpSystNetwork.Protocol

  @doc section: :protocol_api
  @doc """
  Retrieves the network identifying portion of an IP address.

  Results are returned in the form of an
  [Erlang `ip_address()`](https://www.erlang.org/doc/man/inet#type-ip_address)
  tuple or `nil` when the address passed to the function represents a single
  host.

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
  @spec get_network(Types.addr_structs()) :: Types.addr() | nil
  defdelegate get_network(addr_struct), to: MscmpSystNetwork.Protocol

  @doc section: :protocol_api
  @doc """
  Retrieves IP address from IP address structs or `nil` if the struct only
  represents a subnet/prefix.

  Results are returned in the form of an
  [Erlang `ip_address()`](https://www.erlang.org/doc/man/inet#type-ip_address)
  tuple or `nil` when the address passed to the function doesn't represent
  a host address.

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
  @spec get_host(Types.addr_structs()) :: Types.addr() | nil
  defdelegate get_host(addr_struct), to: MscmpSystNetwork.Protocol

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

  @doc section: :protocol_api
  @doc """
  Evaluates an IP address struct to see if it represents an entire network or
  sub-net rather than a host.

  If the function finds that a sub-net is represented by the struct,
  the function returns true.  Otherwise false.

  > #### Other Non-address IPs {: .warning}
  >
  > Multicast addresses are currently not detected as will be treated as regular
  > IP addresses.  Therefore this function will return true for multicast
  > addresses where it should return false.
  >
  > You should not assume that the IP address business logic in this Component
  > is authoritative or complete.  Test any special cases specifically for
  > compliance with the area in which you are working.

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
end
