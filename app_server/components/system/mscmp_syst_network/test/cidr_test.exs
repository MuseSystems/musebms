# Source File: cidr_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_network/test/cidr_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule CidrTest do
  use ExUnit.Case, async: true

  import Bitwise

  alias MscmpSystNetwork.Impl
  alias MscmpSystNetwork.Types.{IpV4, IpV6}

  @moduletag :capture_log

  #
  # IpV4 parse! Testing
  #

  test "Can parse! IPv4 simple IP address" do
    Enum.each(1..500_000, fn _ ->
      {:host, test_addr} = get_random_ipv4(:host)
      test_str = :inet.ntoa(test_addr.address) |> List.to_string()

      assert test_addr === Impl.Cidr.parse!(test_str, nil)
    end)

    Enum.each(1..500_000, fn _ ->
      {:host, test_addr} = get_random_ipv4(:host)
      test_str = :inet.ntoa(test_addr.address) |> List.to_string()

      assert test_addr === Impl.Cidr.parse!(test_str)
    end)
  end

  test "Can parse! IPv4 host address using CIDR notation" do
    Enum.each(1..500_000, fn _ ->
      {:host, test_addr} = get_random_ipv4(:host)
      test_str = Impl.IpV4.to_string(test_addr)

      assert test_addr === Impl.Cidr.parse!(test_str, nil)
    end)

    Enum.each(1..500_000, fn _ ->
      {:host, test_addr} = get_random_ipv4(:host)
      test_str = Impl.IpV4.to_string(test_addr)

      assert test_addr === Impl.Cidr.parse!(test_str)
    end)
  end

  test "Can parse! IPv4 sub-net address using CIDR notation" do
    Enum.each(1..500_000, fn _ ->
      {:network, test_addr} = get_random_ipv4(:network)
      test_str = Impl.IpV4.to_string(test_addr)

      assert test_addr === Impl.Cidr.parse!(test_str, nil)
    end)

    Enum.each(1..500_000, fn _ ->
      {:network, test_addr} = get_random_ipv4(:network)
      test_str = Impl.IpV4.to_string(test_addr)

      assert test_addr === Impl.Cidr.parse!(test_str)
    end)
  end

  test "Cannot parse! invalid IPv4 strings" do
    assert catch_error(Impl.Cidr.parse!("10.1.1.1.1"))
    assert catch_error(Impl.Cidr.parse!("10.1.1.1.1/32"))
    assert catch_error(Impl.Cidr.parse!("10.1.1.1/32/32"))
    assert catch_error(Impl.Cidr.parse!("10.1.1.1/-32"))
  end

  #
  # IpV4 parse Testing
  #

  test "Can parse IPv4 simple IP address" do
    Enum.each(1..10, fn _ ->
      {:host, test_addr} = get_random_ipv4(:host)
      test_str = :inet.ntoa(test_addr.address) |> List.to_string()

      assert {:ok, test_addr} === Impl.Cidr.parse(test_str)
    end)
  end

  test "Can parse IPv4 host address using CIDR notation" do
    Enum.each(1..10, fn _ ->
      {:host, test_addr} = get_random_ipv4(:host)
      test_str = Impl.IpV4.to_string(test_addr)

      assert {:ok, test_addr} === Impl.Cidr.parse(test_str)
    end)
  end

  test "Can parse IPv4 sub-net address using CIDR notation" do
    Enum.each(1..10, fn _ ->
      {:network, test_addr} = get_random_ipv4(:network)
      test_str = Impl.IpV4.to_string(test_addr)

      assert {:ok, test_addr} === Impl.Cidr.parse(test_str)
    end)
  end

  test "Cannot parse invalid IPv4 strings" do
    assert {:error, %MscmpSystError{code: :undefined_error}} = Impl.Cidr.parse("10.1.1.1.1")
    assert {:error, %MscmpSystError{code: :undefined_error}} = Impl.Cidr.parse("10.1.1.1.1/32")
    assert {:error, %MscmpSystError{code: :undefined_error}} = Impl.Cidr.parse("10.1.1.1/32/32")
    assert {:error, %MscmpSystError{code: :undefined_error}} = Impl.Cidr.parse("10.1.1.1/-32")
  end

  #
  # IpV6 parse! Testing
  #

  test "Can parse! IPv6 simple IP address" do
    Enum.each(1..500_000, fn _ ->
      {:host, test_addr} = get_random_ipv6(:host)
      test_str = :inet.ntoa(test_addr.address) |> List.to_string()

      assert test_addr === Impl.Cidr.parse!(test_str, nil)
    end)

    Enum.each(1..500_000, fn _ ->
      {:host, test_addr} = get_random_ipv6(:host)
      test_str = :inet.ntoa(test_addr.address) |> List.to_string()

      assert test_addr === Impl.Cidr.parse!(test_str)
    end)
  end

  test "Can parse! IPv6 host address using CIDR notation" do
    Enum.each(1..500_000, fn _ ->
      {:host, test_addr} = get_random_ipv6(:host)
      test_str = Impl.IpV6.to_string(test_addr)

      assert test_addr === Impl.Cidr.parse!(test_str, nil)
    end)

    Enum.each(1..500_000, fn _ ->
      {:host, test_addr} = get_random_ipv6(:host)
      test_str = Impl.IpV6.to_string(test_addr)

      assert test_addr === Impl.Cidr.parse!(test_str)
    end)
  end

  test "Can parse! IPv6 sub-net address using CIDR notation" do
    Enum.each(1..500_000, fn _ ->
      {:network, test_addr} = get_random_ipv6(:network)
      test_str = Impl.IpV6.to_string(test_addr)

      assert test_addr === Impl.Cidr.parse!(test_str, nil)
    end)

    Enum.each(1..500_000, fn _ ->
      {:network, test_addr} = get_random_ipv6(:network)
      test_str = Impl.IpV6.to_string(test_addr)

      assert test_addr === Impl.Cidr.parse!(test_str)
    end)
  end

  test "Cannot parse! invalid IPv6 strings" do
    assert catch_error(Impl.Cidr.parse!("2001::0010::abcd"))
    assert catch_error(Impl.Cidr.parse!("2001::0010::abcd/128"))
    assert catch_error(Impl.Cidr.parse!("2001::0010:abcd/128/128"))
    assert catch_error(Impl.Cidr.parse!("2001::0010:abcd/-128"))
  end

  #
  # IpV6 parse Testing
  #

  test "Can parse IPv6 simple IP address" do
    Enum.each(1..10, fn _ ->
      {:host, test_addr} = get_random_ipv6(:host)
      test_str = :inet.ntoa(test_addr.address) |> List.to_string()

      assert {:ok, test_addr} === Impl.Cidr.parse(test_str)
    end)
  end

  test "Can parse IPv6 host address using CIDR notation" do
    Enum.each(1..10, fn _ ->
      {:host, test_addr} = get_random_ipv6(:host)
      test_str = Impl.IpV6.to_string(test_addr)

      assert {:ok, test_addr} === Impl.Cidr.parse(test_str)
    end)
  end

  test "Can parse IPv6 sub-net address using CIDR notation" do
    Enum.each(1..10, fn _ ->
      {:network, test_addr} = get_random_ipv6(:network)
      test_str = Impl.IpV6.to_string(test_addr)

      assert {:ok, test_addr} === Impl.Cidr.parse(test_str)
    end)
  end

  test "Cannot parse invalid IPv6 strings" do
    assert {:error, %MscmpSystError{code: :undefined_error}} = Impl.Cidr.parse("2001::0010::abcd")

    assert {:error, %MscmpSystError{code: :undefined_error}} =
             Impl.Cidr.parse("2001::0010::abcd/128")

    assert {:error, %MscmpSystError{code: :undefined_error}} =
             Impl.Cidr.parse("2001::0010:abcd/128/128")

    assert {:error, %MscmpSystError{code: :undefined_error}} =
             Impl.Cidr.parse("2001::0010:abcd/-128")
  end

  #
  # Private support functions
  #

  defp get_random_ipv4(:host) do
    <<a, b, c, d>> = :rand.bytes(4)
    {:host, %IpV4{address: {a, b, c, d}, mask: 32}}
  end

  defp get_random_ipv4(:network) do
    seed = :rand.bytes(4)
    <<seed_int::unsigned-integer-size(32)>> = seed

    mask_length = :rand.uniform(31)

    <<mask::unsigned-integer-size(32)>> = <<-1 <<< (32 - mask_length)::32>>

    <<a, b, c, d>> = <<band(seed_int, mask)::32>>

    {:network, %IpV4{address: {a, b, c, d}, mask: mask_length}}
  end

  defp get_random_ipv4(:broadcast) do
    seed = :rand.bytes(4)
    <<seed_int::unsigned-integer-size(32)>> = seed

    mask_length = :rand.uniform(31)

    <<mask::unsigned-integer-size(32)>> = <<-1 <<< (32 - mask_length)::32>>

    inverse_mask = bnot(mask) |> band(0xFFFF_FFFF)

    broadcast_address = seed_int ||| inverse_mask

    <<a, b, c, d>> = <<broadcast_address::32>>

    {:broadcast, %IpV4{address: {a, b, c, d}, mask: mask_length}}
  end

  defp get_random_ipv4(:any, weights \\ {70, 15}) do
    h_weight = elem(weights, 0)
    n_weight = elem(weights, 0) + elem(weights, 1)
    selector = :rand.uniform(100)

    cond do
      selector <= h_weight -> get_random_ipv4(:host)
      selector <= n_weight -> get_random_ipv4(:network)
      true -> get_random_ipv4(:broadcast)
    end
  end

  defp get_random_ipv6(:host) do
    <<a::unsigned-integer-size(16), b::unsigned-integer-size(16), c::unsigned-integer-size(16),
      d::unsigned-integer-size(16), e::unsigned-integer-size(16), f::unsigned-integer-size(16),
      g::unsigned-integer-size(16), h::unsigned-integer-size(16)>> = :rand.bytes(16)

    {:host, %IpV6{address: {a, b, c, d, e, f, g, h}, mask: 128}}
  end

  defp get_random_ipv6(:network) do
    seed = :rand.bytes(16)
    <<seed_int::unsigned-integer-size(128)>> = seed

    # Make our network prefixes a multiple of 4 for readability.
    prefix = :rand.uniform(31) * 4

    <<mask::unsigned-integer-size(128)>> = <<-1 <<< (128 - prefix)::128>>

    <<a::unsigned-integer-size(16), b::unsigned-integer-size(16), c::unsigned-integer-size(16),
      d::unsigned-integer-size(16), e::unsigned-integer-size(16), f::unsigned-integer-size(16),
      g::unsigned-integer-size(16), h::unsigned-integer-size(16)>> = <<band(seed_int, mask)::128>>

    {:network, %IpV6{address: {a, b, c, d, e, f, g, h}, mask: prefix}}
  end

  defp get_random_ipv6(:any, h_weight \\ 70) do
    if :rand.uniform(100) <= h_weight, do: get_random_ipv6(:host), else: get_random_ipv6(:network)
  end
end
