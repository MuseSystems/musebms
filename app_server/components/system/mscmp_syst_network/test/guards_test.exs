# Source File: guards_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_network/test/guards_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule GuardsTest do
  use ExUnit.Case, async: true

  import MscmpSystNetwork.Guards

  alias MscmpSystNetwork.Types.{IpV4, IpV6}

  #
  # defguard is_ipv4_tuple(addr)
  #

  test "Can verify valid IPv4 address tuples" do
    Enum.each(1..1_000, fn _ ->
      {_, addr_struct} = TestSupport.get_random_ipv4()

      assert true === is_ipv4_tuple(addr_struct.address)
    end)
  end

  test "Can exclude invalid IPv4 address tuples" do
    # Bad tuples
    assert false === is_ipv4_tuple({10, 1, 1})
    assert false === is_ipv4_tuple({10, 1, 1, 1, 1})
    assert false === is_ipv4_tuple({10, 1, 1, 256})
    assert false === is_ipv4_tuple({:test, :test, :test, :test})

    # IPv6 tuple
    assert false === is_ipv4_tuple({64923, 30712, 29005, 51899, 0, 0, 0, 32})

    # non-tuple
    assert false === is_ipv4_tuple(TestSupport.get_random_ipv4())
    assert false === is_ipv4_tuple("10.1.1.25")
  end

  #
  # defguard is_ipv6_tuple(addr)
  #

  test "Can verify valid IPv6 address tuples" do
    Enum.each(1..1_000, fn _ ->
      {_, addr_struct} = TestSupport.get_random_ipv6()

      assert true === is_ipv6_tuple(addr_struct.address)
    end)
  end

  test "Can exclude invalid IPv6 address tuples" do
    # Bad tuples
    assert false === is_ipv6_tuple({64923, 30712, 29005, 51899, 0, 0, 1})
    assert false === is_ipv6_tuple({64923, 30712, 29005, 51899, 0, 0, 0, 0, 1})
    assert false === is_ipv6_tuple({66923, 30712, 29005, 51899, 0, 0, 0, 1})
    assert false === is_ipv6_tuple({:test, :test, :test, :test})

    # IPv4 tuple
    assert false === is_ipv6_tuple({10, 1, 1, 123})

    # non-tuple
    assert false === is_ipv6_tuple(TestSupport.get_random_ipv6())
    assert false === is_ipv6_tuple("fd9b:77f8:714d:cabb::1")
  end

  #
  # defguard is_ip_tuple(addr) when is_ipv4_tuple(addr) or is_ipv6_tuple(addr)
  #

  test "Can verify valid IPv4 or IPv6 tuples" do
    Enum.each(1..10_000, fn _ ->
      switch_value = :rand.uniform(2)

      {_, addr_struct} =
        if switch_value === 1,
          do: TestSupport.get_random_ipv4(),
          else: TestSupport.get_random_ipv6()

      assert true === is_ip_tuple(addr_struct.address)
    end)
  end

  test "Can exclude invalid IP address tuples" do
    #
    # IpV4
    #

    # Bad tuples
    assert false === is_ip_tuple({10, 1, 1})
    assert false === is_ip_tuple({10, 1, 1, 1, 1})
    assert false === is_ip_tuple({10, 1, 1, 256})
    assert false === is_ip_tuple({:test, :test, :test, :test})

    # non-tuple
    assert false === is_ip_tuple(TestSupport.get_random_ipv4())
    assert false === is_ip_tuple("10.1.1.25")

    #
    # IpV6
    #

    # Bad tuples
    assert false === is_ip_tuple({64923, 30712, 29005, 51899, 0, 0, 1})
    assert false === is_ip_tuple({64923, 30712, 29005, 51899, 0, 0, 0, 0, 1})
    assert false === is_ip_tuple({66923, 30712, 29005, 51899, 0, 0, 0, 1})
    assert false === is_ip_tuple({:test, :test, :test, :test, :test, :test, :test, :test})

    # non-tuple
    assert false === is_ip_tuple(TestSupport.get_random_ipv6())
    assert false === is_ip_tuple("fd9b:77f8:714d:cabb::1")
  end

  #
  # defguard is_ipv4_mask(mask) when is_integer(mask) and mask >= 0 and mask <= 32
  #

  test "Can validate or invalidate IPv4 sub-net mask length" do
    Enum.each(1..100, &assert(&1 <= 32 === is_ipv4_mask(&1)))
  end

  #
  # defguard is_ipv6_mask(prefix) when is_integer(prefix) and prefix >= 0 and prefix <= 128
  #

  test "Can validate or invalidate IPv6 prefix length" do
    Enum.each(1..150, &assert(&1 <= 128 === is_ipv6_mask(&1)))
  end

  #
  # defguard is_ipv4(addr)
  #

  test "Can verify valid IPv4 address struct" do
    Enum.each(1..1_000, fn _ ->
      {_, addr_struct} = TestSupport.get_random_ipv4()
      assert true === is_ipv4(addr_struct)
    end)
  end

  test "Can exclude invalid IPv4 address structs" do
    # Bad struct
    assert false === is_ipv4(%IpV4{address: {10, 1, 1}, mask: 32})
    assert false === is_ipv4(%IpV4{address: {10, 1, 1, 25}, mask: nil})
    assert false === is_ipv4(%IpV4{address: {10, 1, 1, 25}, mask: 64})
    assert false === is_ipv4(%IpV4{address: {10, 1, 1, 1, 1}, mask: 24})
    assert false === is_ipv4(%IpV4{address: {10, 1, 1, 256}, mask: 8})
    assert false === is_ipv4(%IpV4{address: {:test, :test, :test, :test}, mask: 16})

    # IPv6 struct
    assert false === is_ipv4(%IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 32}, mask: 128})

    # non-struct
    {_, addr_struct} = TestSupport.get_random_ipv4()
    assert false === is_ipv4(addr_struct.address)
    assert false === is_ipv4("10.1.1.25")
  end

  #
  # defguard is_ipv6(addr)
  #

  test "Can verify valid IPv6 address struct" do
    Enum.each(1..1_000, fn _ ->
      {_, addr_struct} = TestSupport.get_random_ipv6()
      assert true === is_ipv6(addr_struct)
    end)
  end

  test "Can exclude invalid IPv6 address structs" do
    # Bad struct
    assert false === is_ipv6(%IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 1}, mask: 32})
    assert false === is_ipv6(%IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 32}, mask: nil})
    assert false === is_ipv6(%IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 32}, mask: 192})

    assert false ===
             is_ipv6(%IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0, 1}, mask: 68})

    assert false === is_ipv6(%IpV6{address: {66923, 30712, 29005, 51899, 0, 0, 0, 1}, mask: 8})

    assert false ===
             is_ipv6(%IpV6{
               address: {:test, :test, :test, :test, :test, :test, :test, :test},
               mask: 36
             })

    # IPv4 struct
    assert false === is_ipv6(%IpV4{address: {10, 1, 1, 42}, mask: 32})

    # non-struct
    {_, addr_struct} = TestSupport.get_random_ipv6()
    assert false === is_ipv6(addr_struct.address)
    assert false === is_ipv6("fd9b:77f8:714d:cabb::1")
  end

  #
  # defguard is_ip(addr) when is_ipv4(addr) or is_ipv6(addr)
  #

  test "Can verify either IPv4 or IPv6 address structs" do
    Enum.each(1..10_000, fn _ ->
      switch_value = :rand.uniform(2)

      {_, addr_struct} =
        if switch_value === 1,
          do: TestSupport.get_random_ipv4(),
          else: TestSupport.get_random_ipv6()

      assert true === is_ip(addr_struct)
    end)
  end

  test "Can exclude invalid IP address structs" do
    #
    # IPv4
    #

    # Bad struct
    assert false === is_ip(%IpV4{address: {10, 1, 1}, mask: 32})
    assert false === is_ip(%IpV4{address: {10, 1, 1, 25}, mask: nil})
    assert false === is_ip(%IpV4{address: {10, 1, 1, 25}, mask: 64})
    assert false === is_ip(%IpV4{address: {10, 1, 1, 1, 1}, mask: 24})
    assert false === is_ip(%IpV4{address: {10, 1, 1, 256}, mask: 8})
    assert false === is_ip(%IpV4{address: {:test, :test, :test, :test}, mask: 16})

    # non-struct
    {_, addr_struct} = TestSupport.get_random_ipv4()
    assert false === is_ip(addr_struct.address)
    assert false === is_ip("10.1.1.25")

    #
    # IPv6
    #

    # Bad struct
    assert false === is_ip(%IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 1}, mask: 32})
    assert false === is_ip(%IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 32}, mask: nil})
    assert false === is_ip(%IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 32}, mask: 192})

    assert false ===
             is_ip(%IpV6{address: {64923, 30712, 29005, 51899, 0, 0, 0, 0, 1}, mask: 68})

    assert false === is_ip(%IpV6{address: {66923, 30712, 29005, 51899, 0, 0, 0, 1}, mask: 8})

    assert false ===
             is_ip(%IpV6{
               address: {:test, :test, :test, :test, :test, :test, :test, :test},
               mask: 36
             })

    # non-struct
    {_, addr_struct} = TestSupport.get_random_ipv6()
    assert false === is_ip(addr_struct.address)
    assert false === is_ip("fd9b:77f8:714d:cabb::1")
  end
end
