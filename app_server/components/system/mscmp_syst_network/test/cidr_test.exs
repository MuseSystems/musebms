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

  alias MscmpSystNetwork.Impl

  @moduletag :capture_log

  #
  # IpV4 parse! Testing
  #

  test "Can parse! IPv4 simple IP address" do
    Enum.each(1..500_000, fn _ ->
      {:host, test_addr} = TestSupport.get_random_ipv4(:host)
      test_str = :inet.ntoa(test_addr.address) |> List.to_string()

      assert test_addr === Impl.Cidr.parse!(test_str, nil)
    end)

    Enum.each(1..500_000, fn _ ->
      {:host, test_addr} = TestSupport.get_random_ipv4(:host)
      test_str = :inet.ntoa(test_addr.address) |> List.to_string()

      assert test_addr === Impl.Cidr.parse!(test_str)
    end)
  end

  test "Can parse! IPv4 host address using CIDR notation" do
    Enum.each(1..500_000, fn _ ->
      {:host, test_addr} = TestSupport.get_random_ipv4(:host)
      test_str = Impl.IpV4.to_string(test_addr)

      assert test_addr === Impl.Cidr.parse!(test_str, nil)
    end)

    Enum.each(1..500_000, fn _ ->
      {:host, test_addr} = TestSupport.get_random_ipv4(:host)
      test_str = Impl.IpV4.to_string(test_addr)

      assert test_addr === Impl.Cidr.parse!(test_str)
    end)
  end

  test "Can parse! IPv4 sub-net address using CIDR notation" do
    Enum.each(1..500_000, fn _ ->
      {:network, test_addr} = TestSupport.get_random_ipv4(:network)
      test_str = Impl.IpV4.to_string(test_addr)

      assert test_addr === Impl.Cidr.parse!(test_str, nil)
    end)

    Enum.each(1..500_000, fn _ ->
      {:network, test_addr} = TestSupport.get_random_ipv4(:network)
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
      {:host, test_addr} = TestSupport.get_random_ipv4(:host)
      test_str = :inet.ntoa(test_addr.address) |> List.to_string()

      assert {:ok, test_addr} === Impl.Cidr.parse(test_str)
    end)
  end

  test "Can parse IPv4 host address using CIDR notation" do
    Enum.each(1..10, fn _ ->
      {:host, test_addr} = TestSupport.get_random_ipv4(:host)
      test_str = Impl.IpV4.to_string(test_addr)

      assert {:ok, test_addr} === Impl.Cidr.parse(test_str)
    end)
  end

  test "Can parse IPv4 sub-net address using CIDR notation" do
    Enum.each(1..10, fn _ ->
      {:network, test_addr} = TestSupport.get_random_ipv4(:network)
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
      {:host, test_addr} = TestSupport.get_random_ipv6(:host)
      test_str = :inet.ntoa(test_addr.address) |> List.to_string()

      assert test_addr === Impl.Cidr.parse!(test_str, nil)
    end)

    Enum.each(1..500_000, fn _ ->
      {:host, test_addr} = TestSupport.get_random_ipv6(:host)
      test_str = :inet.ntoa(test_addr.address) |> List.to_string()

      assert test_addr === Impl.Cidr.parse!(test_str)
    end)
  end

  test "Can parse! IPv6 host address using CIDR notation" do
    Enum.each(1..500_000, fn _ ->
      {:host, test_addr} = TestSupport.get_random_ipv6(:host)
      test_str = Impl.IpV6.to_string(test_addr)

      assert test_addr === Impl.Cidr.parse!(test_str, nil)
    end)

    Enum.each(1..500_000, fn _ ->
      {:host, test_addr} = TestSupport.get_random_ipv6(:host)
      test_str = Impl.IpV6.to_string(test_addr)

      assert test_addr === Impl.Cidr.parse!(test_str)
    end)
  end

  test "Can parse! IPv6 sub-net address using CIDR notation" do
    Enum.each(1..500_000, fn _ ->
      {:network, test_addr} = TestSupport.get_random_ipv6(:network)
      test_str = Impl.IpV6.to_string(test_addr)

      assert test_addr === Impl.Cidr.parse!(test_str, nil)
    end)

    Enum.each(1..500_000, fn _ ->
      {:network, test_addr} = TestSupport.get_random_ipv6(:network)
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
      {:host, test_addr} = TestSupport.get_random_ipv6(:host)
      test_str = :inet.ntoa(test_addr.address) |> List.to_string()

      assert {:ok, test_addr} === Impl.Cidr.parse(test_str)
    end)
  end

  test "Can parse IPv6 host address using CIDR notation" do
    Enum.each(1..10, fn _ ->
      {:host, test_addr} = TestSupport.get_random_ipv6(:host)
      test_str = Impl.IpV6.to_string(test_addr)

      assert {:ok, test_addr} === Impl.Cidr.parse(test_str)
    end)
  end

  test "Can parse IPv6 sub-net address using CIDR notation" do
    Enum.each(1..10, fn _ ->
      {:network, test_addr} = TestSupport.get_random_ipv6(:network)
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
end