# Source File: integration_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_utils_guards/test/integration_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystUtilsGuardsTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use Msutils.Guards

  @moduletag :integration
  @moduletag :capture_log

  describe "is_reg_atom/1" do
    test "returns true for a regular atom" do
      assert is_reg_atom(:regular_atom)
    end

    test "returns false for nil" do
      refute is_reg_atom(nil)
    end

    test "returns false for true" do
      refute is_reg_atom(true)
    end

    test "returns false for false" do
      refute is_reg_atom(false)
    end

    test "returns false for a string" do
      refute is_reg_atom("string")
    end

    test "returns false for an integer" do
      refute is_reg_atom(42)
    end

    test "returns false for a float" do
      refute is_reg_atom(3.14)
    end

    test "returns false for a list" do
      refute is_reg_atom([1, 2, 3])
    end

    test "returns false for a tuple" do
      refute is_reg_atom({:a, :b, :c})
    end

    test "returns false for a map" do
      refute is_reg_atom(%{key: "value"})
    end

    test "returns false for a function" do
      refute is_reg_atom(fn -> :ok end)
    end
  end

  describe "is_uuid/1" do
    test "returns true for valid UUIDs" do
      for _ <- 1..1_000_000 do
        uuid =
          [
            String.pad_leading(Integer.to_string(:rand.uniform(0xFFFFFFFF), 16), 8, "0"),
            String.pad_leading(Integer.to_string(:rand.uniform(0xFFFF), 16), 4, "0"),
            String.pad_leading(Integer.to_string(:rand.uniform(0xFFFF), 16), 4, "0"),
            String.pad_leading(Integer.to_string(:rand.uniform(0xFFFF), 16), 4, "0"),
            String.pad_leading(Integer.to_string(:rand.uniform(0xFFFFFFFFFFFF), 16), 12, "0")
          ]
          |> Enum.join("-")

        assert is_uuid(uuid)
      end
    end

    test "returns false for a non-UUID" do
      refute is_uuid(nil)

      for _ <- 1..1_000_000 do
        str =
          1..Enum.random(1..256)
          |> Enum.map_join(fn _ -> <<Enum.random(?a..?z)>> end)

        refute is_uuid(str)
      end
    end
  end
end
