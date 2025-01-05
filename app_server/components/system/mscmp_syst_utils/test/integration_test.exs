# Source File: integration_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_utils/test/integration_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule IntegrationTest do
  @moduledoc false

  # While the integration tests cover more than just the process utilities,
  # there are no specialized test cases for the other modules.  This could
  # change in the future, but for now it's adequate and the non-process
  # test cases won't be affected.

  use ProcessTestCase, async: true
  import Msutils.Guards

  @moduletag :integration
  @moduletag :capture_log

  describe "String Utilities API" do
    test "generates a random string of the specified length" do
      assert String.length(Msutils.String.get_random_string(10)) == 10
      assert String.length(Msutils.String.get_random_string(20)) == 20
    end

    test "generates a random string using the specified character set" do
      assert Msutils.String.get_random_string(10, :alphanum) =~ ~r/^[0-9A-Z]{10}$/
      assert Msutils.String.get_random_string(10, :mixed_alphanum) =~ ~r/^[0-9A-Za-z]{10}$/
      assert Msutils.String.get_random_string(10, :b32e) =~ ~r/^[0-9A-V]{10}$/
      assert Msutils.String.get_random_string(10, :b32c) =~ ~r/^[0-9A-HJ-KM-NP-TV-Z]{10}$/
      assert Msutils.String.get_random_string(10, ~c"ABC123") =~ ~r/^[ABC123]{10}$/
    end
  end

  describe "Guards" do
    test "is_reg_atom/1 returns true for a regular atom" do
      assert is_reg_atom(:regular_atom)
    end

    test "is_reg_atom/1 returns false for nil" do
      refute is_reg_atom(nil)
    end

    test "is_reg_atom/1 returns false for true" do
      refute is_reg_atom(true)
    end

    test "is_reg_atom/1 returns false for false" do
      refute is_reg_atom(false)
    end

    test "is_reg_atom/1 returns false for a string" do
      refute is_reg_atom("string")
    end

    test "is_reg_atom/1 returns false for an integer" do
      refute is_reg_atom(42)
    end

    test "is_reg_atom/1 returns false for a float" do
      refute is_reg_atom(3.14)
    end

    test "is_reg_atom/1 returns false for a list" do
      refute is_reg_atom([1, 2, 3])
    end

    test "is_reg_atom/1 returns false for a tuple" do
      refute is_reg_atom({:a, :b, :c})
    end

    test "is_reg_atom/1 returns false for a map" do
      refute is_reg_atom(%{key: "value"})
    end

    test "is_reg_atom/1 returns false for a function" do
      refute is_reg_atom(fn -> :ok end)
    end

    test "is_uuid/1 returns true for valid UUIDs" do
      assert is_uuid("123e4567-e89b-12d3-a456-426614174000")
      assert is_uuid("00000000-0000-0000-0000-000000000000")
      assert is_uuid("ffffffff-ffff-ffff-ffff-ffffffffffff")
    end

    test "is_uuid/1 returns false for a non-UUID" do
      #  Note that we don't refute test values which are constructed using invalid
      #  hexidecimal values.  The guard only tests the shape of the string and not
      #  the actual values.

      #  nil
      refute is_uuid(nil)

      #  not a uuid string
      refute is_uuid("not-a-uuid")

      #  too short
      refute is_uuid("123e4567-e89b-12d3-a456-42661417400")

      #  too long
      refute is_uuid("123e4567-e89b-12d3-a456-4266141740000")

      #  no hyphens
      refute is_uuid("123e4567e89b12d3a456426614174000")

      #  wrong separator
      refute is_uuid("123e4567-e89b-12d3-a456_426614174000")
    end
  end

  describe "Process Utilities API" do
    test "whereis/2 returns pid for locally registered process", %{local: %{pid: pid, name: name}} do
      assert {:ok, ^pid} = Msutils.Process.whereis(name)
    end

    test "whereis/2 returns pid for globally registered process", %{
      global: %{pid: pid, name: name}
    } do
      assert {:ok, ^pid} = Msutils.Process.whereis(name)
    end

    test "whereis/2 returns pid when given a pid directly", %{unnamed: %{pid: pid}} do
      assert {:ok, ^pid} = Msutils.Process.whereis(pid)
    end

    test "whereis/2 returns error for non-existent local process" do
      assert {:error, %Mserror.ProcessUtilsError{kind: :lookup, cause: :process_not_found}} =
               Msutils.Process.whereis(:nonexistent_process)
    end

    test "whereis/2 returns error for non-existent global process" do
      assert {:error, %Mserror.ProcessUtilsError{kind: :lookup, cause: :process_not_found}} =
               Msutils.Process.whereis({:global, :nonexistent_process})
    end

    test "whereis/2 returns error for invalid process name" do
      assert {:error, %Mserror.ProcessUtilsError{kind: :lookup, cause: :invalid_name}} =
               Msutils.Process.whereis({:invalid, :name})
    end

    test "whereis/2 returns pid for via-registered process", %{via: %{pid: pid, name: name}} do
      assert {:ok, ^pid} = Msutils.Process.whereis(name)
    end

    test "whereis/2 returns error for non-existent via process" do
      assert {:error, %Mserror.ProcessUtilsError{kind: :lookup, cause: :process_not_found}} =
               Msutils.Process.whereis(
                 {:via, Registry, {MscmpSystUtils.TestRegistry, :nonexistent_process}}
               )
    end
  end
end
