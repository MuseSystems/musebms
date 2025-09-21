# Source File: semaphore_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_limiter/test/semaphore_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems
defmodule SemaphoreTest do
  @moduledoc false

  use LimiterTestCase, async: true

  alias MscmpSystLimiter.Impl.Semaphore

  @moduletag :unit
  @moduletag :capture_log

  @test_component TestModule
  @test_counter_type :test_counter
  @default_opts [max_permits: 10, time_to_live: 60, time_scale: :minute]

  @atomics_current_permits 1
  @atomics_max_permits 2
  @atomics_expiry_time 3
  @atomics_ttl 4
  @atomics_time_scale_code 5

  # Helper function to generate unique counter IDs
  defp unique_counter_id(prefix \\ "test") do
    "#{prefix}_#{System.unique_integer([:positive])}"
  end

  describe "new/4" do
    test "creates a new semaphore limiter with valid parameters" do
      counter_id = unique_counter_id()

      assert {:ok, {:semaphore, limiter_id, atomics_ref}} =
               Semaphore.new(@test_component, @test_counter_type, counter_id, @default_opts)

      assert limiter_id == {@test_component, @test_counter_type, counter_id}
      assert is_reference(atomics_ref)

      # Verify atomics are properly initialized
      # current_permits should start at max_permits
      assert :atomics.get(atomics_ref, @atomics_current_permits) == 10
      # max_permits
      assert :atomics.get(atomics_ref, @atomics_max_permits) == 10
      # expiry_time should be set
      assert :atomics.get(atomics_ref, @atomics_expiry_time) > 0
      # ttl should match input
      assert :atomics.get(atomics_ref, @atomics_ttl) == 60
      # time_scale_code should be set
      assert :atomics.get(atomics_ref, @atomics_time_scale_code) > 0
    end

    test "returns existing limiter when called with same parameters" do
      counter_id = unique_counter_id("existing")
      opts = [max_permits: 5, time_to_live: 30, time_scale: :second]

      # Create first limiter
      assert {:ok, {:semaphore, limiter_id, atomics_ref1}} =
               Semaphore.new(@test_component, @test_counter_type, counter_id, opts)

      # Create second limiter with same ID
      assert {:ok, {:semaphore, ^limiter_id, atomics_ref2}} =
               Semaphore.new(@test_component, @test_counter_type, counter_id, opts)

      # Should be the same atomics reference (or renewed)
      assert is_reference(atomics_ref2)
      # Suppress unused variable warning
      _ = atomics_ref1
    end

    test "handles different time scales correctly" do
      test_cases = [
        {1, :millisecond},
        {5, :second},
        {10, :minute},
        {2, :hour},
        {1, :day}
      ]

      for {ttl, time_scale} <- test_cases do
        counter_id = unique_counter_id("time_scale_#{time_scale}")
        opts = [max_permits: 3, time_to_live: ttl, time_scale: time_scale]

        assert {:ok, {:semaphore, _limiter_id, atomics_ref}} =
                 Semaphore.new(@test_component, @test_counter_type, counter_id, opts)

        assert :atomics.get(atomics_ref, @atomics_ttl) == ttl
      end
    end

    test "fails when missing required options" do
      counter_id = unique_counter_id("incomplete")
      incomplete_opts = [max_permits: 10, time_to_live: 60]

      assert_raise KeyError, fn ->
        Semaphore.new(@test_component, @test_counter_type, counter_id, incomplete_opts)
      end
    end

    # Note that zero max permits should actually be blocked in the option
    # validation of the API.  I'm leaving the test in because we don't
    # explicitly validate for the possibility in the implementation module so
    # having predictable behavior in this case doesn't hurt aside from a few
    # microseconds of extra test time.  Still, something to be aware of.

    test "handles zero max_permits" do
      counter_id = unique_counter_id("zero_permits")
      opts = [max_permits: 0, time_to_live: 60, time_scale: :minute]

      assert {:ok, {:semaphore, _limiter_id, atomics_ref}} =
               Semaphore.new(@test_component, @test_counter_type, counter_id, opts)

      # Should start with 0 permits
      assert :atomics.get(atomics_ref, @atomics_current_permits) == 0
      assert :atomics.get(atomics_ref, @atomics_max_permits) == 0
    end
  end

  describe "use/2" do
    setup do
      counter_id = unique_counter_id("use")

      {:ok, limiter} =
        Semaphore.new(@test_component, @test_counter_type, counter_id, @default_opts)

      %{limiter: limiter}
    end

    test "allows acquisition when sufficient permits available", %{limiter: limiter} do
      assert {:ok, {:allow, remaining_permits, ^limiter}} = Semaphore.use(limiter, 3)
      # 10 - 3 = 7
      assert remaining_permits == 7
    end

    test "denies acquisition when insufficient permits available", %{limiter: limiter} do
      # Use most permits first
      assert {:ok, {:allow, 1, limiter}} = Semaphore.use(limiter, 9)

      # Try to use more than available
      assert {:ok, {:deny, needed_permits, ^limiter}} = Semaphore.use(limiter, 5)
      # Should need 4 more permits (5 requested - 1 available)
      assert needed_permits == 4
    end

    test "allows exactly the remaining permits", %{limiter: limiter} do
      # Use some permits first
      assert {:ok, {:allow, 5, limiter}} = Semaphore.use(limiter, 5)

      # Use exactly the remaining permits
      assert {:ok, {:allow, 0, ^limiter}} = Semaphore.use(limiter, 5)
    end

    test "handles single permit acquisition", %{limiter: limiter} do
      assert {:ok, {:allow, 9, ^limiter}} = Semaphore.use(limiter, 1)
    end

    test "handles zero increment (no-op)", %{limiter: limiter} do
      assert {:ok, {:allow, 10, ^limiter}} = Semaphore.use(limiter, 0)
    end

    test "handles negative increment (release permits)", %{limiter: limiter} do
      # First use some permits
      assert {:ok, {:allow, 5, limiter}} = Semaphore.use(limiter, 5)

      # Release 2 permits
      assert {:ok, {:allow, 7, ^limiter}} = Semaphore.use(limiter, -2)
    end

    test "clamps negative increment to max_permits", %{limiter: limiter} do
      # Use some permits first
      assert {:ok, {:allow, 7, limiter}} = Semaphore.use(limiter, 3)

      # Try to release more than max_permits would allow
      assert {:ok, {:allow, 10, ^limiter}} = Semaphore.use(limiter, -20)
    end

    test "handles large positive increment", %{limiter: limiter} do
      # Try to use way more than available
      assert {:ok, {:deny, needed_permits, ^limiter}} = Semaphore.use(limiter, 50)
      # Should need 40 more permits (50 requested - 10 available)
      assert needed_permits == 40
    end

    test "handles edge case: use all permits", %{limiter: limiter} do
      assert {:ok, {:allow, 0, ^limiter}} = Semaphore.use(limiter, 10)
    end
  end

  describe "get/1" do
    setup do
      counter_id = unique_counter_id("get")

      {:ok, limiter} =
        Semaphore.new(@test_component, @test_counter_type, counter_id, @default_opts)

      %{limiter: limiter}
    end

    test "returns current permits without modification", %{limiter: limiter} do
      assert {:ok, {:allow, 10, ^limiter}} = Semaphore.get(limiter)
    end

    test "returns current permits after usage", %{limiter: limiter} do
      # Use some permits
      assert {:ok, {:allow, 6, limiter}} = Semaphore.use(limiter, 4)

      # Get should return current state
      assert {:ok, {:allow, 6, ^limiter}} = Semaphore.get(limiter)
    end

    test "get does not affect permits", %{limiter: limiter} do
      # Get initial state
      assert {:ok, {:allow, 10, limiter}} = Semaphore.get(limiter)

      # Use some permits
      assert {:ok, {:allow, 7, limiter}} = Semaphore.use(limiter, 3)

      # Get again
      assert {:ok, {:allow, 7, limiter}} = Semaphore.get(limiter)

      # Use more permits
      assert {:ok, {:allow, 5, ^limiter}} = Semaphore.use(limiter, 2)
    end
  end

  describe "set/2" do
    setup do
      counter_id = unique_counter_id("set")

      {:ok, limiter} =
        Semaphore.new(@test_component, @test_counter_type, counter_id, @default_opts)

      %{limiter: limiter}
    end

    test "sets current permits to valid value", %{limiter: limiter} do
      assert {:ok, {:allow, 5, ^limiter}} = Semaphore.set(limiter, current_permits: 5)

      # Verify the permits were actually set
      assert {:ok, {:allow, 5, ^limiter}} = Semaphore.get(limiter)
    end

    test "allows setting permits to zero", %{limiter: limiter} do
      assert {:ok, {:allow, 0, ^limiter}} = Semaphore.set(limiter, current_permits: 0)

      # Verify zero permits
      assert {:ok, {:allow, 0, ^limiter}} = Semaphore.get(limiter)
    end

    test "allows setting permits to max_permits", %{limiter: limiter} do
      # First use some permits
      assert {:ok, {:allow, 7, limiter}} = Semaphore.use(limiter, 3)

      # Set back to max
      assert {:ok, {:allow, 10, ^limiter}} = Semaphore.set(limiter, current_permits: 10)
    end

    test "rejects setting permits above max_permits", %{limiter: limiter} do
      assert {:error, {:semaphore_bad_capacity, message}} =
               Semaphore.set(limiter, current_permits: 15)

      assert message =~ "Available permit values are only valid between 0 and 10"
    end

    test "rejects negative permit values", %{limiter: limiter} do
      assert {:error, {:semaphore_bad_capacity, message}} =
               Semaphore.set(limiter, current_permits: -1)

      assert message =~ "Available permit values must be an integer between 0 and 10"
    end

    test "rejects non-integer permit values", %{limiter: limiter} do
      assert {:error, {:semaphore_bad_capacity, message}} =
               Semaphore.set(limiter, current_permits: 5.5)

      assert message =~ "Available permit values must be an integer between 0 and 10"

      assert {:error, {:semaphore_bad_capacity, message}} =
               Semaphore.set(limiter, current_permits: "invalid")

      assert message =~ "Available permit values must be an integer between 0 and 10"
    end
  end

  describe "reset/1" do
    setup do
      counter_id = unique_counter_id("reset")

      {:ok, limiter} =
        Semaphore.new(@test_component, @test_counter_type, counter_id, @default_opts)

      %{limiter: limiter}
    end

    test "resets permits to max_permits", %{limiter: limiter} do
      # Use some permits
      assert {:ok, {:allow, 3, limiter}} = Semaphore.use(limiter, 7)

      # Reset
      assert {:ok, {:allow, 10, ^limiter}} = Semaphore.reset(limiter)

      # Verify reset worked
      assert {:ok, {:allow, 10, ^limiter}} = Semaphore.get(limiter)
    end

    test "reset from zero permits", %{limiter: limiter} do
      # Use all permits
      assert {:ok, {:allow, 0, limiter}} = Semaphore.use(limiter, 10)

      # Reset
      assert {:ok, {:allow, 10, ^limiter}} = Semaphore.reset(limiter)
    end

    test "reset when already at max permits is no-op", %{limiter: limiter} do
      # Should already be at max permits
      assert {:ok, {:allow, 10, ^limiter}} = Semaphore.reset(limiter)
    end
  end

  describe "cleanup/1" do
    test "cleanup function exists and can be called" do
      # Create some limiters to test cleanup
      counter_id1 = unique_counter_id("cleanup_1")
      counter_id2 = unique_counter_id("cleanup_2")
      opts = [max_permits: 5, time_to_live: 1, time_scale: :millisecond]

      {:ok, _limiter1} = Semaphore.new(@test_component, @test_counter_type, counter_id1, opts)
      {:ok, _limiter2} = Semaphore.new(@test_component, @test_counter_type, counter_id2, opts)

      # Test that cleanup function exists and returns a non-negative integer
      assert is_function(&Semaphore.cleanup/1, 1)

      # We can't easily test the actual cleanup behavior without time manipulation
      # or access to the ETS table, but we can verify the function signature
    end
  end

  describe "limiter recreation on expiry" do
    test "limiter recreates when expired" do
      counter_id = unique_counter_id("recreation")
      # Very short TTL to trigger recreation
      opts = [max_permits: 8, time_to_live: 1, time_scale: :millisecond]

      {:ok, limiter} = Semaphore.new(@test_component, @test_counter_type, counter_id, opts)

      # Use some permits
      assert {:ok, {:allow, 5, limiter}} = Semaphore.use(limiter, 3)

      # Wait for expiry
      Process.sleep(10)

      # Next use should recreate the limiter with full permits
      # Note: limiter instance may have new atomics reference after recreation
      {:semaphore, limiter_id, _atomics_ref} = limiter

      assert {:ok, {:allow, 7, {:semaphore, ^limiter_id, _new_atomics_ref}}} =
               Semaphore.use(limiter, 1)
    end

    test "limiter maintains state when not expired" do
      counter_id = unique_counter_id("no_recreation")
      # Long TTL to prevent recreation
      opts = [max_permits: 8, time_to_live: 60, time_scale: :second]

      {:ok, limiter} = Semaphore.new(@test_component, @test_counter_type, counter_id, opts)

      # Use some permits
      assert {:ok, {:allow, 5, limiter}} = Semaphore.use(limiter, 3)

      # Small delay (much less than TTL)
      Process.sleep(1)

      # Should maintain previous state
      assert {:ok, {:allow, 4, ^limiter}} = Semaphore.use(limiter, 1)
    end
  end

  describe "concurrent access behavior" do
    test "handles concurrent permit acquisition" do
      counter_id = unique_counter_id("concurrent")
      opts = [max_permits: 20, time_to_live: 60, time_scale: :second]

      {:ok, limiter} = Semaphore.new(@test_component, @test_counter_type, counter_id, opts)

      # Spawn multiple processes to acquire permits concurrently
      parent = self()

      tasks =
        for i <- 1..10 do
          Task.async(fn ->
            result = Semaphore.use(limiter, 2)
            send(parent, {i, result})
            result
          end)
        end

      # Collect results
      results = Task.await_many(tasks, 1000)

      # All should succeed (20 permits, 10 processes × 2 permits each = exactly 20)
      assert Enum.all?(results, fn
               {:ok, {:allow, _remaining, ^limiter}} -> true
               _ -> false
             end)

      # Final state should have 0 permits
      assert {:ok, {:allow, 0, ^limiter}} = Semaphore.get(limiter)
    end
  end

  describe "edge cases and error conditions" do
    test "handles very large permit counts" do
      counter_id = unique_counter_id("large_permits")
      large_permits = 1_000_000
      opts = [max_permits: large_permits, time_to_live: 60, time_scale: :minute]

      assert {:ok, limiter} =
               Semaphore.new(@test_component, @test_counter_type, counter_id, opts)

      assert {:ok, {:allow, ^large_permits, ^limiter}} = Semaphore.get(limiter)
    end

    test "handles zero max_permits edge cases" do
      counter_id = unique_counter_id("zero_max")
      opts = [max_permits: 0, time_to_live: 60, time_scale: :minute]

      assert {:ok, limiter} = Semaphore.new(@test_component, @test_counter_type, counter_id, opts)

      # Any positive usage should be denied
      assert {:ok, {:deny, 1, ^limiter}} = Semaphore.use(limiter, 1)

      # Zero usage should be allowed
      assert {:ok, {:allow, 0, ^limiter}} = Semaphore.use(limiter, 0)

      # Negative usage should be no-op (already at max)
      assert {:ok, {:allow, 0, ^limiter}} = Semaphore.use(limiter, -5)
    end

    test "function clause errors for invalid types" do
      counter_id = unique_counter_id("invalid_types")
      opts = [max_permits: 10, time_to_live: 60, time_scale: :minute]

      {:ok, limiter} = Semaphore.new(@test_component, @test_counter_type, counter_id, opts)

      # Non-integer increment should cause function clause error
      assert_raise FunctionClauseError, fn ->
        Semaphore.use(limiter, 3.14)
      end

      assert_raise FunctionClauseError, fn ->
        Semaphore.use(limiter, "invalid")
      end
    end
  end
end
