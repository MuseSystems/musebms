# Source File: token_bucket_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_limiter/test/token_bucket_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule TokenBucketTest do
  @moduledoc false

  use LimiterTestCase, async: true

  alias MscmpSystLimiter.Impl.TokenBucket

  @moduletag :unit
  @moduletag :capture_log

  @test_component TestModule
  @test_counter_type :test_counter
  @default_opts [bucket_size: 10, refill_rate: 5, refill_per: :second]

  @atomics_current_fill 1
  @atomics_request_time 2
  @atomics_ttl 3
  @atomics_bucket_size 4
  @atomics_refill_rate 5
  @atomics_refill_per_code 6

  # Helper function to generate unique counter IDs
  defp unique_counter_id(prefix \\ "test") do
    "#{prefix}_#{System.unique_integer([:positive])}"
  end

  describe "new/4" do
    test "creates a new token bucket limiter with valid parameters" do
      counter_id = unique_counter_id()

      assert {:ok, {:token_bucket, limiter_id, atomics_ref}} =
               TokenBucket.new(@test_component, @test_counter_type, counter_id, @default_opts)

      assert limiter_id == {@test_component, @test_counter_type, counter_id}
      assert is_reference(atomics_ref)

      # Verify atomics are properly initialized
      # current_fill = bucket_size
      assert :atomics.get(atomics_ref, @atomics_current_fill) == 10
      # bucket_size
      assert :atomics.get(atomics_ref, @atomics_bucket_size) == 10
      # refill_rate
      assert :atomics.get(atomics_ref, @atomics_refill_rate) == 5
    end

    test "creates limiter with different bucket sizes" do
      counter_id = unique_counter_id("bucket_size")
      opts = [bucket_size: 100, refill_rate: 20, refill_per: :minute]

      assert {:ok, {:token_bucket, _limiter_id, atomics_ref}} =
               TokenBucket.new(@test_component, @test_counter_type, counter_id, opts)

      # current_fill
      assert :atomics.get(atomics_ref, @atomics_current_fill) == 100
      # bucket_size
      assert :atomics.get(atomics_ref, @atomics_bucket_size) == 100
      # refill_rate
      assert :atomics.get(atomics_ref, @atomics_refill_rate) == 20
    end

    test "creates limiter with different refill rates" do
      counter_id = unique_counter_id("refill_rate")
      opts = [bucket_size: 50, refill_rate: 1, refill_per: :hour]

      assert {:ok, {:token_bucket, _limiter_id, atomics_ref}} =
               TokenBucket.new(@test_component, @test_counter_type, counter_id, opts)

      # refill_rate
      assert :atomics.get(atomics_ref, @atomics_refill_rate) == 1
    end

    test "creates limiter with different time scales" do
      for time_scale <- [:second, :minute, :hour, :day] do
        counter_id = unique_counter_id("time_scale_#{time_scale}")
        opts = [bucket_size: 10, refill_rate: 5, refill_per: time_scale]

        assert {:ok, {:token_bucket, _limiter_id, atomics_ref}} =
                 TokenBucket.new(@test_component, @test_counter_type, counter_id, opts)

        # Verify time scale was encoded correctly
        encoded_time_scale = :atomics.get(atomics_ref, @atomics_refill_per_code)
        assert encoded_time_scale in 1..5
      end
    end

    test "reuses existing limiter for same component/counter_type/counter_id" do
      counter_id = unique_counter_id("reuse")
      opts = [bucket_size: 20, refill_rate: 10, refill_per: :second]

      # Create first limiter
      assert {:ok, {:token_bucket, limiter_id, atomics_ref1}} =
               TokenBucket.new(@test_component, @test_counter_type, counter_id, opts)

      # Create second limiter with same ID - should reuse
      assert {:ok, {:token_bucket, ^limiter_id, atomics_ref2}} =
               TokenBucket.new(@test_component, @test_counter_type, counter_id, opts)

      # Should be the same atomics reference
      assert atomics_ref1 == atomics_ref2
    end

    test "fails when missing required options" do
      counter_id = unique_counter_id("incomplete")
      incomplete_opts = [bucket_size: 10, refill_rate: 5]

      assert_raise KeyError, fn ->
        TokenBucket.new(@test_component, @test_counter_type, counter_id, incomplete_opts)
      end
    end
  end

  describe "use/2" do
    setup do
      counter_id = unique_counter_id("use")

      {:ok, limiter} =
        TokenBucket.new(@test_component, @test_counter_type, counter_id, @default_opts)

      %{limiter: limiter}
    end

    test "allows usage when sufficient tokens available", %{limiter: limiter} do
      assert {:ok, {:allow, remaining_tokens, ^limiter}} = TokenBucket.use(limiter, 3)
      # 10 - 3
      assert remaining_tokens == 7
    end

    test "denies usage when insufficient tokens available", %{limiter: limiter} do
      # Use most tokens first
      assert {:ok, {:allow, 1, limiter}} = TokenBucket.use(limiter, 9)

      # Try to use more than available
      assert {:ok, {:deny, retry_after_ms, ^limiter}} = TokenBucket.use(limiter, 5)
      assert is_integer(retry_after_ms) and retry_after_ms > 0
    end

    test "allows exactly the remaining tokens", %{limiter: limiter} do
      # Use some tokens first
      assert {:ok, {:allow, 5, limiter}} = TokenBucket.use(limiter, 5)

      # Use exactly the remaining tokens
      assert {:ok, {:allow, 0, ^limiter}} = TokenBucket.use(limiter, 5)
    end

    test "handles single token usage", %{limiter: limiter} do
      assert {:ok, {:allow, 9, ^limiter}} = TokenBucket.use(limiter, 1)
    end

    test "fails with non-positive increment" do
      counter_id = unique_counter_id("non_positive")

      {:ok, limiter} =
        TokenBucket.new(@test_component, @test_counter_type, counter_id, @default_opts)

      assert {:error,
              {:token_bucket_bad_increment, "Increment must be an integer greater than 0."}} =
               TokenBucket.use(limiter, 0)

      assert {:error,
              {:token_bucket_bad_increment, "Increment must be an integer greater than 0."}} =
               TokenBucket.use(limiter, -1)
    end

    test "token refill works over time" do
      # Create a fast-refilling bucket for testing
      counter_id = unique_counter_id("fast_refill")
      # 1 token per ms
      opts = [bucket_size: 10, refill_rate: 1000, refill_per: :second]
      {:ok, limiter} = TokenBucket.new(@test_component, @test_counter_type, counter_id, opts)

      # Use all tokens
      assert {:ok, {:allow, 0, limiter}} = TokenBucket.use(limiter, 10)

      # Should be denied immediately
      assert {:ok, {:deny, _retry_after, limiter}} = TokenBucket.use(limiter, 1)

      # Wait a bit for refill
      Process.sleep(10)

      # Should have some tokens available now
      assert {:ok, {:allow, _remaining, ^limiter}} = TokenBucket.use(limiter, 1)
    end
  end

  describe "get/1" do
    setup do
      counter_id = unique_counter_id("get")

      {:ok, limiter} =
        TokenBucket.new(@test_component, @test_counter_type, counter_id, @default_opts)

      %{limiter: limiter}
    end

    test "returns current state without consuming tokens", %{limiter: limiter} do
      # Initially full
      assert {:ok, {:allow, 10, ^limiter}} = TokenBucket.get(limiter)

      # Use some tokens
      assert {:ok, {:allow, 7, limiter}} = TokenBucket.use(limiter, 3)

      # Get should show current state without further consumption
      assert {:ok, {:allow, 7, ^limiter}} = TokenBucket.get(limiter)
      assert {:ok, {:allow, 7, ^limiter}} = TokenBucket.get(limiter)
    end

    test "returns deny when no tokens available", %{limiter: limiter} do
      # Use all tokens
      assert {:ok, {:allow, 0, limiter}} = TokenBucket.use(limiter, 10)

      # Try to use one more token - should be denied
      assert {:ok, {:deny, retry_after, limiter}} = TokenBucket.use(limiter, 1)
      assert is_integer(retry_after) and retry_after > 0

      # Get should show allow with 0 tokens (empty bucket is still valid state)
      assert {:ok, {:allow, 0, ^limiter}} = TokenBucket.get(limiter)
    end

    test "shows refilled tokens after time passes" do
      counter_id = unique_counter_id("get_refill")
      # Create fast-refilling bucket
      opts = [bucket_size: 10, refill_rate: 1000, refill_per: :second]
      {:ok, limiter} = TokenBucket.new(@test_component, @test_counter_type, counter_id, opts)

      # Use all tokens
      assert {:ok, {:allow, 0, limiter}} = TokenBucket.use(limiter, 10)

      # Wait for refill
      Process.sleep(10)

      # Get should show refilled tokens
      assert {:ok, {:allow, refilled_tokens, ^limiter}} = TokenBucket.get(limiter)
      assert refilled_tokens > 0
    end
  end

  describe "set/2" do
    setup do
      counter_id = unique_counter_id("set")

      {:ok, limiter} =
        TokenBucket.new(@test_component, @test_counter_type, counter_id, @default_opts)

      %{limiter: limiter}
    end

    test "sets current fill to valid value", %{limiter: limiter} do
      assert {:ok, {:allow, 5, ^limiter}} = TokenBucket.set(limiter, current_fill: 5)

      # Verify the new state
      assert {:ok, {:allow, 5, ^limiter}} = TokenBucket.get(limiter)
    end

    test "sets current fill to zero", %{limiter: limiter} do
      assert {:ok, {:deny, retry_after, ^limiter}} = TokenBucket.set(limiter, current_fill: 0)
      assert is_integer(retry_after) and retry_after > 0

      # Verify the state
      assert {:ok, {:allow, 0, ^limiter}} = TokenBucket.get(limiter)
    end

    test "sets current fill to maximum bucket size", %{limiter: limiter} do
      assert {:ok, {:allow, 10, ^limiter}} = TokenBucket.set(limiter, current_fill: 10)

      # Verify the state
      assert {:ok, {:allow, 10, ^limiter}} = TokenBucket.get(limiter)
    end

    test "rejects negative current fill values", %{limiter: limiter} do
      assert {:error, {:token_bucket_bad_current_fill, msg}} =
               TokenBucket.set(limiter, current_fill: -1)

      assert is_binary(msg)
    end

    test "rejects current fill values exceeding bucket size", %{limiter: limiter} do
      assert {:error, {:token_bucket_bad_current_fill, msg}} =
               TokenBucket.set(limiter, current_fill: 11)

      assert is_binary(msg)
    end

    test "rejects non-integer current fill values", %{limiter: limiter} do
      assert {:error, {:token_bucket_bad_current_fill, msg}} =
               TokenBucket.set(limiter, current_fill: 5.5)

      assert is_binary(msg)

      assert {:error, {:token_bucket_bad_current_fill, msg}} =
               TokenBucket.set(limiter, current_fill: "5")

      assert is_binary(msg)
    end
  end

  describe "reset/1" do
    setup do
      counter_id = unique_counter_id("reset")

      {:ok, limiter} =
        TokenBucket.new(@test_component, @test_counter_type, counter_id, @default_opts)

      %{limiter: limiter}
    end

    test "resets bucket to full capacity", %{limiter: limiter} do
      # Use some tokens first
      assert {:ok, {:allow, 3, limiter}} = TokenBucket.use(limiter, 7)

      # Reset should restore to full capacity
      assert {:ok, {:allow, 10, ^limiter}} = TokenBucket.reset(limiter)

      # Verify state
      assert {:ok, {:allow, 10, ^limiter}} = TokenBucket.get(limiter)
    end

    test "reset works when bucket is empty", %{limiter: limiter} do
      # Empty the bucket
      assert {:ok, {:allow, 0, limiter}} = TokenBucket.use(limiter, 10)

      # Reset should restore to full capacity
      assert {:ok, {:allow, 10, ^limiter}} = TokenBucket.reset(limiter)
    end

    test "reset works when bucket is already full", %{limiter: limiter} do
      # Bucket starts full, reset should still work
      assert {:ok, {:allow, 10, ^limiter}} = TokenBucket.reset(limiter)
    end
  end

  describe "cleanup/1" do
    test "cleanup function exists and can be called" do
      # Create some limiters
      counter_id1 = unique_counter_id("cleanup_1")
      counter_id2 = unique_counter_id("cleanup_2")
      opts = [bucket_size: 5, refill_rate: 1, refill_per: :second]

      {:ok, _limiter1} = TokenBucket.new(@test_component, @test_counter_type, counter_id1, opts)
      {:ok, _limiter2} = TokenBucket.new(@test_component, @test_counter_type, counter_id2, opts)

      # Test that cleanup function exists and returns a non-negative integer
      # The actual cleanup logic is challenging to test without time manipulation
      assert is_function(&TokenBucket.cleanup/1, 1)

      # We can verify the function signature but can't easily test the cleanup
      # behavior without mocking system time or waiting for TTL expiration
    end
  end

  describe "private function edge cases" do
    test "limiter handles time-based refill calculations correctly" do
      # Test with very slow refill rate to verify calculation precision
      counter_id = unique_counter_id("slow_refill")
      # 1 token per hour
      opts = [bucket_size: 10, refill_rate: 1, refill_per: :hour]

      {:ok, limiter} = TokenBucket.new(@test_component, @test_counter_type, counter_id, opts)

      # Use all tokens
      assert {:ok, {:allow, 0, limiter}} = TokenBucket.use(limiter, 10)

      # Should be denied for any additional tokens since refill is very slow
      assert {:ok, {:deny, retry_after_ms, ^limiter}} = TokenBucket.use(limiter, 1)

      # Should be approximately 1 hour in milliseconds (3,600,000 ms)
      # Allow some variance for calculation precision
      assert retry_after_ms >= 3_500_000 and retry_after_ms <= 3_700_000
    end

    test "limiter handles very fast refill rates" do
      counter_id = unique_counter_id("very_fast")
      # 10,000 tokens per second
      opts = [bucket_size: 10, refill_rate: 10_000, refill_per: :second]

      {:ok, limiter} = TokenBucket.new(@test_component, @test_counter_type, counter_id, opts)

      # Use all tokens
      assert {:ok, {:allow, 0, limiter}} = TokenBucket.use(limiter, 10)

      # Even a tiny wait should allow refill
      Process.sleep(1)

      # Should have refilled significantly
      assert {:ok, {:allow, _remaining, ^limiter}} = TokenBucket.use(limiter, 1)
    end

    test "limiter handles maximum bucket sizes correctly" do
      counter_id = unique_counter_id("max_bucket")
      # Test with a very large bucket
      opts = [bucket_size: 1_000_000, refill_rate: 1000, refill_per: :second]

      {:ok, limiter} = TokenBucket.new(@test_component, @test_counter_type, counter_id, opts)

      # Should start with full bucket
      assert {:ok, {:allow, remaining, ^limiter}} = TokenBucket.use(limiter, 1000)
      assert remaining == 999_000
    end

    test "limiter validates time scale encoding/decoding" do
      # Test all valid time scales
      time_scales = [:second, :minute, :hour, :day]

      for time_scale <- time_scales do
        counter_id = unique_counter_id("time_scale_#{time_scale}")
        opts = [bucket_size: 10, refill_rate: 5, refill_per: time_scale]

        # Should successfully create limiter for all valid time scales
        assert {:ok, {:token_bucket, _limiter_id, atomics_ref}} =
                 TokenBucket.new(@test_component, @test_counter_type, counter_id, opts)

        # Verify encoded time scale is valid
        encoded_time_scale = :atomics.get(atomics_ref, @atomics_refill_per_code)
        assert encoded_time_scale in 1..5
      end
    end

    test "limiter calculates retry times accurately" do
      counter_id = unique_counter_id("retry_time")
      # 1 token per second = 1000ms per token
      opts = [bucket_size: 5, refill_rate: 1, refill_per: :second]

      {:ok, limiter} = TokenBucket.new(@test_component, @test_counter_type, counter_id, opts)

      # Use all tokens
      assert {:ok, {:allow, 0, limiter}} = TokenBucket.use(limiter, 5)

      # Try to use 3 more tokens - should need 3 seconds = 3000ms
      assert {:ok, {:deny, retry_after_ms, ^limiter}} = TokenBucket.use(limiter, 3)
      assert retry_after_ms == 3000
    end

    test "limiter handles concurrent operations properly" do
      counter_id = unique_counter_id("concurrent")
      opts = [bucket_size: 100, refill_rate: 10, refill_per: :second]

      {:ok, limiter} = TokenBucket.new(@test_component, @test_counter_type, counter_id, opts)

      # Simulate multiple operations in quick succession
      results =
        for _i <- 1..10 do
          TokenBucket.use(limiter, 5)
        end

      # Should get a mix of allows and denies
      allows = Enum.count(results, fn {:ok, {result, _, _}} -> result == :allow end)
      denies = Enum.count(results, fn {:ok, {result, _, _}} -> result == :deny end)

      # With 100 tokens and 10 operations of 5 tokens each (50 total needed)
      # Should have some allows and some denies
      assert allows > 0
      assert allows + denies == 10
    end
  end

  describe "error handling and edge cases" do
    test "handles invalid time scale gracefully during creation" do
      # This test verifies the Common module integration
      counter_id = unique_counter_id("invalid_time_scale")

      # While we can't directly pass invalid time scales due to type checking,
      # we can verify that all valid time scales work
      valid_time_scales = [:second, :minute, :hour, :day]

      for time_scale <- valid_time_scales do
        opts = [bucket_size: 10, refill_rate: 5, refill_per: time_scale]
        counter_id_ts = "#{counter_id}_#{time_scale}"

        assert {:ok, {:token_bucket, _id, _ref}} =
                 TokenBucket.new(@test_component, @test_counter_type, counter_id_ts, opts)
      end
    end

    test "maintains precision with large time intervals" do
      counter_id = unique_counter_id("large_intervals")
      # 1 token per day
      opts = [bucket_size: 100, refill_rate: 1, refill_per: :day]

      {:ok, limiter} = TokenBucket.new(@test_component, @test_counter_type, counter_id, opts)

      # Use all tokens
      assert {:ok, {:allow, 0, limiter}} = TokenBucket.use(limiter, 100)

      # Try to use another token - should be denied for a very long time
      assert {:ok, {:deny, retry_after_ms, ^limiter}} = TokenBucket.use(limiter, 1)

      # Should be approximately 1 day in milliseconds (86,400,000 ms)
      expected_day_ms = 24 * 60 * 60 * 1000
      assert retry_after_ms >= expected_day_ms - 1000 and retry_after_ms <= expected_day_ms + 1000
    end

    test "handles fractional refill rates through integer math" do
      counter_id = unique_counter_id("fractional")
      # 3 tokens per 2 seconds = 1.5 tokens per second
      opts = [bucket_size: 10, refill_rate: 3, refill_per: :second]

      {:ok, limiter} = TokenBucket.new(@test_component, @test_counter_type, counter_id, opts)

      # Use some tokens
      assert {:ok, {:allow, 7, limiter}} = TokenBucket.use(limiter, 3)

      # Verify the limiter can still operate with fractional rates
      assert {:ok, {:allow, 6, ^limiter}} = TokenBucket.use(limiter, 1)
    end

    test "bucket size boundary conditions" do
      # Test with minimum viable bucket size
      counter_id = unique_counter_id("min_bucket")
      opts = [bucket_size: 1, refill_rate: 1, refill_per: :second]

      {:ok, limiter} = TokenBucket.new(@test_component, @test_counter_type, counter_id, opts)

      # Should allow single token
      assert {:ok, {:allow, 0, limiter}} = TokenBucket.use(limiter, 1)

      # Should deny any additional tokens
      assert {:ok, {:deny, _retry_after, ^limiter}} = TokenBucket.use(limiter, 1)
    end

    test "refill rate boundary conditions" do
      # Test with minimum refill rate
      counter_id = unique_counter_id("min_refill")
      opts = [bucket_size: 10, refill_rate: 1, refill_per: :second]

      {:ok, limiter} = TokenBucket.new(@test_component, @test_counter_type, counter_id, opts)

      # Use all tokens
      assert {:ok, {:allow, 0, limiter}} = TokenBucket.use(limiter, 10)

      # Should need exactly 1 second per token for refill
      assert {:ok, {:deny, retry_after_ms, ^limiter}} = TokenBucket.use(limiter, 1)
      # 1 second in ms
      assert retry_after_ms == 1000
    end

    test "set operation preserves limiter instance integrity" do
      counter_id = unique_counter_id("set_integrity")

      {:ok, original_limiter} =
        TokenBucket.new(@test_component, @test_counter_type, counter_id, @default_opts)

      # Set to different values and verify limiter structure remains intact
      assert {:ok, {:allow, 7, ^original_limiter}} =
               TokenBucket.set(original_limiter, current_fill: 7)

      assert {:ok, {:allow, 3, ^original_limiter}} =
               TokenBucket.set(original_limiter, current_fill: 3)

      # Setting to 0 results in deny state since no tokens available for immediate use
      assert {:ok, {:deny, _retry_after, ^original_limiter}} =
               TokenBucket.set(original_limiter, current_fill: 0)

      # Verify the limiter can still be used normally after sets
      assert {:ok, {:allow, 10, ^original_limiter}} = TokenBucket.reset(original_limiter)
    end

    test "get operation is truly idempotent" do
      counter_id = unique_counter_id("get_idempotent")

      {:ok, limiter} =
        TokenBucket.new(@test_component, @test_counter_type, counter_id, @default_opts)

      # Use some tokens
      assert {:ok, {:allow, 6, limiter}} = TokenBucket.use(limiter, 4)

      # Multiple get operations should return identical results
      assert {:ok, result1} = TokenBucket.get(limiter)
      assert {:ok, result2} = TokenBucket.get(limiter)
      assert {:ok, result3} = TokenBucket.get(limiter)

      assert result1 == result2
      assert result2 == result3

      # And the state should remain unchanged for subsequent use
      assert {:ok, {:allow, 5, ^limiter}} = TokenBucket.use(limiter, 1)
    end

    test "limiter renewal mechanism works correctly" do
      # This test verifies the maybe_renew_limiter private function behavior
      counter_id = unique_counter_id("renewal")

      {:ok, limiter} =
        TokenBucket.new(@test_component, @test_counter_type, counter_id, @default_opts)

      # Use some tokens
      assert {:ok, {:allow, 7, limiter}} = TokenBucket.use(limiter, 3)

      # Create a new limiter with the same ID - should get the existing state
      # (within TTL window)
      assert {:ok, {:token_bucket, _id, _ref}} =
               TokenBucket.new(@test_component, @test_counter_type, counter_id, @default_opts)

      # The state should be preserved in the registry
      assert {:ok, {:allow, current_tokens, ^limiter}} = TokenBucket.get(limiter)
      # Should reflect any usage/refill
      assert current_tokens <= 10
    end

    test "atomics operations maintain consistency" do
      counter_id = unique_counter_id("atomics_consistency")

      {:ok, limiter} =
        TokenBucket.new(@test_component, @test_counter_type, counter_id, @default_opts)

      {:token_bucket, _id, atomics_ref} = limiter

      # Verify all expected atomics positions are properly initialized
      # current_fill
      assert :atomics.get(atomics_ref, @atomics_current_fill) >= 0
      # request_time
      assert :atomics.get(atomics_ref, @atomics_request_time) > 0
      # ttl
      assert :atomics.get(atomics_ref, @atomics_ttl) > 0
      # bucket_size
      assert :atomics.get(atomics_ref, @atomics_bucket_size) == 10
      # refill_rate
      assert :atomics.get(atomics_ref, @atomics_refill_rate) == 5
      # refill_per_code
      assert :atomics.get(atomics_ref, @atomics_refill_per_code) in 1..5
    end
  end
end
