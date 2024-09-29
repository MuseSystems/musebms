# Source File: rate_limiter_test.exs
# Location:    musebms/components/system/mscmp_syst_limiter/test/rate_limiter_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule RateLimiterTest do
  use ExUnit.Case, async: true

  alias MscmpSystLimiter.Impl.RateLimiter

  @moduletag :unit
  @moduletag :capture_log

  describe "get_counter_name/2" do
    test "returns correct counter name" do
      assert RateLimiter.get_counter_name(:test_counter, "123") == "test_counter_123"
    end
  end

  describe "get_check_rate_function/3" do
    test "returns a function" do
      check_rate_fn = RateLimiter.get_check_rate_function(:test_counter, 60_000, 3)
      assert is_function(check_rate_fn, 1)
    end

    test "returned function checks rate correctly" do
      check_rate_fn = RateLimiter.get_check_rate_function(:test_counter, 60_000, 3)

      assert {:allow, 1} = check_rate_fn.("test_id")
      assert {:allow, 2} = check_rate_fn.("test_id")
      assert {:allow, 3} = check_rate_fn.("test_id")
      assert {:deny, 3} = check_rate_fn.("test_id")
    end
  end

  describe "check_rate/4" do
    test "allows and denies correctly" do
      assert {:allow, 1} = RateLimiter.check_rate(:test_counter, "id1", 60_000, 3)
      assert {:allow, 2} = RateLimiter.check_rate(:test_counter, "id1", 60_000, 3)
      assert {:allow, 3} = RateLimiter.check_rate(:test_counter, "id1", 60_000, 3)
      assert {:deny, 3} = RateLimiter.check_rate(:test_counter, "id1", 60_000, 3)
    end
  end

  describe "check_rate_with_increment/5" do
    test "allows and denies correctly with custom increment" do
      assert {:allow, 2} =
               RateLimiter.check_rate_with_increment(:test_counter, "id2", 60_000, 5, 2)

      assert {:allow, 4} =
               RateLimiter.check_rate_with_increment(:test_counter, "id2", 60_000, 5, 2)

      assert {:deny, 5} =
               RateLimiter.check_rate_with_increment(:test_counter, "id2", 60_000, 5, 2)
    end
  end

  describe "inspect_counter/4" do
    test "returns correct counter information" do
      RateLimiter.check_rate(:test_counter, "id3", 60_000, 3)

      assert {:ok, {count, count_remaining, ms_to_next_counter, created_at, updated_at}} =
               RateLimiter.inspect_counter(:test_counter, "id3", 60_000, 3)

      assert count == 1
      assert count_remaining == 2
      assert is_integer(ms_to_next_counter)
      assert is_integer(created_at)
      assert is_integer(updated_at)
    end
  end

  describe "delete_counters/2" do
    test "deletes counters successfully" do
      RateLimiter.check_rate(:test_counter, "id4", 60_000, 3)
      assert {:ok, 1} = RateLimiter.delete_counters(:test_counter, "id4")

      assert {:ok, {0, 3, _, nil, nil}} =
               RateLimiter.inspect_counter(:test_counter, "id4", 60_000, 3)
    end
  end
end
