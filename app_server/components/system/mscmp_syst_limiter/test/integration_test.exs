# Source File: integration_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_limiter/test/integration_test.exs
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

  # We're not using LimiterTestCase because all it currently does is call
  # `MscmpSystLimiter.put_service(TestSupport.get_limiter_service_name())`
  # and we want to manage the current Process service exlicitly in the tests.

  use ExUnit.Case, async: false

  @moduletag :integration
  @moduletag :capture_log

  # Testing Names
  @test_limiter_all Test.Limiter.All
  @test_limiter_one Test.Limiter.One
  @test_limiter_custom Test.Limiter.Custom

  @test_comp_all_1 Test.Component.All_1
  @test_comp_all_2 Test.Component.All_2
  @test_comp_one_1 Test.Component.One_1

  @test_comp_cust_1 Test.Component.Custom_1
  @test_comp_cust_2 Test.Component.Custom_2

  describe "Phase 01 - Service Init & Startup" do
    test "Step 01.01 - Startup 'All' Limiter/Default Opts" do
      assert child_spec = MscmpSystLimiter.child_spec(service_name: @test_limiter_all)

      assert %{id: MscmpSystLimiter, start: {MscmpSystLimiter, :start_link, [opts]}} = child_spec
      assert {:ok, :infinity} === Keyword.fetch(opts, :timeout)
      assert {:ok, [all: 60_000]} === Keyword.fetch(opts, :cleanup_interval)
      assert {:ok, :all} === Keyword.fetch(opts, :algorithms)
      assert {:ok, @test_limiter_all} === Keyword.fetch(opts, :service_name)

      assert {:ok, pid} =
               DynamicSupervisor.start_child(
                 :"MscmpSystLimiter.TestSupportDynSupervisor",
                 child_spec
               )

      assert is_pid(pid)
    end

    test "Step 01.02 - Validate 'All' Limiter Runtime Config" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      assert %{
               semaphore: {semaphore_table, semaphore_cleanup_interval},
               token_bucket: {token_bucket_table, token_bucket_cleanup_interval}
             } = MscmpSystLimiter.get_runtime_config()

      assert is_reference(semaphore_table)
      assert 60_000 === semaphore_cleanup_interval

      assert is_reference(token_bucket_table)
      assert 60_000 === token_bucket_cleanup_interval

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 01.03 - Startup 'One' Limiter/Single Algorithm" do
      assert child_spec =
               MscmpSystLimiter.child_spec(
                 service_name: @test_limiter_one,
                 algorithms: [:semaphore]
               )

      assert %{id: MscmpSystLimiter, start: {MscmpSystLimiter, :start_link, [opts]}} = child_spec
      assert {:ok, :infinity} === Keyword.fetch(opts, :timeout)
      assert {:ok, [all: 60_000]} === Keyword.fetch(opts, :cleanup_interval)
      assert {:ok, [:semaphore]} === Keyword.fetch(opts, :algorithms)
      assert {:ok, @test_limiter_one} === Keyword.fetch(opts, :service_name)

      assert {:ok, pid} =
               DynamicSupervisor.start_child(
                 :"MscmpSystLimiter.TestSupportDynSupervisor",
                 child_spec
               )

      assert is_pid(pid)
    end

    test "Step 01.04 - Validate 'One' Limiter Runtime Config" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_one)
      assert @test_limiter_one === MscmpSystLimiter.get_service()

      assert %{
               semaphore: {semaphore_table, semaphore_cleanup_interval},
               token_bucket: {token_bucket_table, token_bucket_cleanup_interval}
             } = MscmpSystLimiter.get_runtime_config()

      assert is_reference(semaphore_table)
      assert 60_000 === semaphore_cleanup_interval

      assert is_nil(token_bucket_table)
      assert 60_000 === token_bucket_cleanup_interval

      assert @test_limiter_one === MscmpSystLimiter.put_service(nil)
    end

    test "Step 01.05 - Startup 'Custom' Limiter/Specified Options" do
      assert child_spec =
               MscmpSystLimiter.child_spec(
                 service_name: @test_limiter_custom,
                 algorithms: [:semaphore, :token_bucket],
                 cleanup_interval: [all: 60_000, semaphore: 15_000, token_bucket: 10_000]
               )

      assert %{id: MscmpSystLimiter, start: {MscmpSystLimiter, :start_link, [opts]}} = child_spec
      assert {:ok, :infinity} === Keyword.fetch(opts, :timeout)
      assert {:ok, cleanup_intervals} = Keyword.fetch(opts, :cleanup_interval)
      assert {:ok, 60_000} === Keyword.fetch(cleanup_intervals, :all)
      assert {:ok, 15_000} === Keyword.fetch(cleanup_intervals, :semaphore)
      assert {:ok, 10_000} === Keyword.fetch(cleanup_intervals, :token_bucket)
      assert {:ok, algorithms} = Keyword.fetch(opts, :algorithms)
      assert :semaphore in algorithms
      assert :token_bucket in algorithms
      assert {:ok, @test_limiter_custom} === Keyword.fetch(opts, :service_name)

      assert {:ok, pid} =
               DynamicSupervisor.start_child(
                 :"MscmpSystLimiter.TestSupportDynSupervisor",
                 child_spec
               )

      assert is_pid(pid)
    end

    test "Step 01.06 - Validate 'Custom' Limiter Runtime Config" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_custom)
      assert @test_limiter_custom === MscmpSystLimiter.get_service()

      assert %{
               semaphore: {semaphore_table, semaphore_cleanup_interval},
               token_bucket: {token_bucket_table, token_bucket_cleanup_interval}
             } = MscmpSystLimiter.get_runtime_config()

      assert is_reference(semaphore_table)
      assert 15_000 === semaphore_cleanup_interval

      assert is_reference(token_bucket_table)
      assert 10_000 === token_bucket_cleanup_interval

      assert @test_limiter_custom === MscmpSystLimiter.put_service(nil)
    end
  end

  describe "Phase 02 - Rate Limiting Operations" do
    test "Step 02.01 - Create Token Bucket Limiter" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      assert {:ok, limiter} =
               MscmpSystLimiter.new(
                 :token_bucket,
                 @test_comp_all_1,
                 :token_bucket_test,
                 "token_bucket_creation_test",
                 bucket_size: 100,
                 refill_rate: 10,
                 refill_per: :second
               )

      assert {:token_bucket, {@test_comp_all_1, :token_bucket_test, "token_bucket_creation_test"},
              _config} = limiter

      # Verify initial state - should have full bucket
      assert {:ok, {:allow, capacity, _}} = MscmpSystLimiter.get(limiter)
      assert 100 === capacity

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 02.02 - Create Semaphore Limiter" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      assert {:ok, limiter} =
               MscmpSystLimiter.new(
                 :semaphore,
                 @test_comp_all_2,
                 :semaphore_test,
                 "semaphore_creation_test",
                 max_permits: 20,
                 time_to_live: 5,
                 time_scale: :minute
               )

      assert {:semaphore, {@test_comp_all_2, :semaphore_test, "semaphore_creation_test"}, _config} =
               limiter

      # Verify initial state - should have full permits
      assert {:ok, {:allow, permits, _}} = MscmpSystLimiter.get(limiter)
      assert 20 === permits

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 02.03 - Token Bucket Use Operations" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      # Create token bucket (10 tokens, refill 5 per second)
      assert {:ok, limiter} =
               MscmpSystLimiter.new(
                 :token_bucket,
                 @test_comp_all_1,
                 :token_bucket_use_test,
                 "token_bucket_use_test",
                 bucket_size: 10,
                 refill_rate: 5,
                 refill_per: :second
               )

      # Consume 3 tokens - should be allowed
      assert {:ok, {:allow, remaining, updated_limiter}} = MscmpSystLimiter.use(limiter, 3)
      assert 7 === remaining

      # Consume 5 more tokens - should be allowed
      assert {:ok, {:allow, remaining, updated_limiter}} =
               MscmpSystLimiter.use(updated_limiter, 5)

      assert 2 === remaining

      # Try to consume 5 tokens when only 2 remain - should be denied
      assert {:ok, {:deny, retry_after_ms, _}} = MscmpSystLimiter.use(updated_limiter, 5)
      assert is_integer(retry_after_ms) and retry_after_ms > 0

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 02.04 - Semaphore Use Operations" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      # Create semaphore (5 permits, 1 hour TTL)
      assert {:ok, limiter} =
               MscmpSystLimiter.new(
                 :semaphore,
                 @test_comp_all_2,
                 :semaphore_use_test,
                 "semaphore_use_test",
                 max_permits: 5,
                 time_to_live: 1,
                 time_scale: :hour
               )

      # Acquire 2 permits - should be allowed
      assert {:ok, {:allow, remaining, updated_limiter}} = MscmpSystLimiter.use(limiter, 2)
      assert 3 === remaining

      # Try to acquire 5 permits when only 3 remain - should be denied
      assert {:ok, {:deny, needed_permits, _}} = MscmpSystLimiter.use(updated_limiter, 5)
      assert 2 === needed_permits

      # Release 1 permit back to the pool
      assert {:ok, {:allow, remaining, updated_limiter}} =
               MscmpSystLimiter.use(updated_limiter, -1)

      assert 4 === remaining

      # Now acquire 2 permits - should be allowed
      assert {:ok, {:allow, remaining, _}} = MscmpSystLimiter.use(updated_limiter, 2)
      assert 2 === remaining

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 02.05 - Get Operations" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      # Test token bucket get
      assert {:ok, token_limiter} =
               MscmpSystLimiter.new(
                 :token_bucket,
                 @test_comp_all_1,
                 :token_bucket_get_test,
                 "token_bucket_get_test",
                 bucket_size: 10,
                 refill_rate: 5,
                 refill_per: :second
               )

      # Check initial state
      assert {:ok, {:allow, capacity, _}} = MscmpSystLimiter.get(token_limiter)
      assert 10 === capacity

      # Consume some tokens
      assert {:ok, {:allow, remaining, updated_limiter}} = MscmpSystLimiter.use(token_limiter, 3)
      assert 7 === remaining

      # Check state after consumption
      assert {:ok, {:allow, current_capacity, _}} = MscmpSystLimiter.get(updated_limiter)
      assert 7 === current_capacity

      # Test semaphore get
      assert {:ok, semaphore_limiter} =
               MscmpSystLimiter.new(
                 :semaphore,
                 @test_comp_all_2,
                 :semaphore_get_test,
                 "semaphore_get_test",
                 max_permits: 5,
                 time_to_live: 1,
                 time_scale: :hour
               )

      # Check initial state
      assert {:ok, {:allow, permits, _}} = MscmpSystLimiter.get(semaphore_limiter)
      assert 5 === permits

      # Acquire some permits
      assert {:ok, {:allow, remaining, updated_limiter}} =
               MscmpSystLimiter.use(semaphore_limiter, 2)

      assert 3 === remaining

      # Check state after acquisition
      assert {:ok, {:allow, current_permits, _}} = MscmpSystLimiter.get(updated_limiter)
      assert 3 === current_permits

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 02.06 - Set Operations" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      # Test token bucket set
      assert {:ok, token_limiter} =
               MscmpSystLimiter.new(
                 :token_bucket,
                 @test_comp_all_1,
                 :token_bucket_set_test,
                 "token_bucket_set_test",
                 bucket_size: 10,
                 refill_rate: 5,
                 refill_per: :second
               )

      # Consume some tokens
      assert {:ok, {:allow, remaining, depleted_limiter}} = MscmpSystLimiter.use(token_limiter, 7)
      assert 3 === remaining

      # Set bucket to half capacity
      assert {:ok, {:allow, set_capacity, set_limiter}} =
               MscmpSystLimiter.set(depleted_limiter, current_fill: 5)

      assert 5 === set_capacity

      # Verify the new capacity is in effect
      assert {:ok, {:allow, current_capacity, _}} = MscmpSystLimiter.get(set_limiter)
      assert 5 === current_capacity

      # Test semaphore set
      assert {:ok, semaphore_limiter} =
               MscmpSystLimiter.new(
                 :semaphore,
                 @test_comp_all_2,
                 :semaphore_set_test,
                 "semaphore_set_test",
                 max_permits: 10,
                 time_to_live: 1,
                 time_scale: :hour
               )

      # Acquire some permits
      assert {:ok, {:allow, remaining, depleted_limiter}} =
               MscmpSystLimiter.use(semaphore_limiter, 6)

      assert 4 === remaining

      # Set permits to a specific value
      assert {:ok, {:allow, set_permits, set_limiter}} =
               MscmpSystLimiter.set(depleted_limiter, current_permits: 8)

      assert 8 === set_permits

      # Verify the new permit count is in effect
      assert {:ok, {:allow, current_permits, _}} = MscmpSystLimiter.get(set_limiter)
      assert 8 === current_permits

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 02.07 - Reset Operations" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      # Test token bucket reset
      assert {:ok, token_limiter} =
               MscmpSystLimiter.new(
                 :token_bucket,
                 @test_comp_all_1,
                 :token_bucket_reset_test,
                 "token_bucket_reset_test",
                 bucket_size: 10,
                 refill_rate: 5,
                 refill_per: :second
               )

      # Consume most tokens
      assert {:ok, {:allow, remaining, depleted_limiter}} = MscmpSystLimiter.use(token_limiter, 8)
      assert 2 === remaining

      # Reset the limiter - should restore full capacity
      assert {:ok, {:allow, reset_capacity, reset_limiter}} =
               MscmpSystLimiter.reset(depleted_limiter)

      assert 10 === reset_capacity

      # Verify we can now consume the full amount again
      assert {:ok, {:allow, final_remaining, _}} = MscmpSystLimiter.use(reset_limiter, 8)
      assert 2 === final_remaining

      # Test semaphore reset
      assert {:ok, semaphore_limiter} =
               MscmpSystLimiter.new(
                 :semaphore,
                 @test_comp_all_2,
                 :semaphore_reset_test,
                 "semaphore_reset_test",
                 max_permits: 5,
                 time_to_live: 1,
                 time_scale: :hour
               )

      # Acquire most permits
      assert {:ok, {:allow, remaining, depleted_limiter}} =
               MscmpSystLimiter.use(semaphore_limiter, 4)

      assert 1 === remaining

      # Reset the semaphore - should restore all permits
      assert {:ok, {:allow, reset_permits, reset_limiter}} =
               MscmpSystLimiter.reset(depleted_limiter)

      assert 5 === reset_permits

      # Verify we can now acquire permits again
      assert {:ok, {:allow, final_remaining, _}} = MscmpSystLimiter.use(reset_limiter, 3)
      assert 2 === final_remaining

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 02.08 - Limiter Identity and Idempotency" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      # Create first limiter
      assert {:ok, limiter1} =
               MscmpSystLimiter.new(
                 :token_bucket,
                 @test_comp_all_1,
                 :token_bucket_identity_test,
                 "token_bucket_identity_test",
                 bucket_size: 10,
                 refill_rate: 5,
                 refill_per: :second
               )

      # Consume some tokens
      assert {:ok, {:allow, remaining, _}} = MscmpSystLimiter.use(limiter1, 3)
      assert 7 === remaining

      # Create limiter with same identity - should return existing limiter
      assert {:ok, limiter2} =
               MscmpSystLimiter.new(
                 :token_bucket,
                 @test_comp_all_1,
                 :token_bucket_identity_test,
                 "token_bucket_identity_test",
                 bucket_size: 10,
                 refill_rate: 5,
                 refill_per: :second
               )

      # Should have the same state (7 tokens remaining)
      assert {:ok, {:allow, capacity, _}} = MscmpSystLimiter.get(limiter2)
      assert 7 === capacity

      # Create limiter with different identity - should be separate
      assert {:ok, limiter3} =
               MscmpSystLimiter.new(
                 :token_bucket,
                 @test_comp_all_1,
                 :token_bucket_identity_test_2,
                 "token_bucket_identity_test_2",
                 bucket_size: 10,
                 refill_rate: 5,
                 refill_per: :second
               )

      # Should have full capacity (10 tokens)
      assert {:ok, {:allow, capacity, _}} = MscmpSystLimiter.get(limiter3)
      assert 10 === capacity

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 02.09 - Cross-Algorithm Operations" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      # Create both types of limiters
      assert {:ok, token_limiter} =
               MscmpSystLimiter.new(
                 :token_bucket,
                 @test_comp_all_1,
                 :token_bucket_cross_test,
                 "token_bucket_cross_test",
                 bucket_size: 10,
                 refill_rate: 5,
                 refill_per: :second
               )

      assert {:ok, semaphore_limiter} =
               MscmpSystLimiter.new(
                 :semaphore,
                 @test_comp_all_2,
                 :semaphore_cross_test,
                 "semaphore_cross_test",
                 max_permits: 5,
                 time_to_live: 1,
                 time_scale: :hour
               )

      # Use both limiters independently
      assert {:ok, {:allow, token_remaining, updated_token}} =
               MscmpSystLimiter.use(token_limiter, 3)

      assert 7 === token_remaining

      assert {:ok, {:allow, semaphore_remaining, updated_semaphore}} =
               MscmpSystLimiter.use(semaphore_limiter, 2)

      assert 3 === semaphore_remaining

      # Verify both limiters maintain their independent state
      assert {:ok, {:allow, token_capacity, _}} = MscmpSystLimiter.get(updated_token)
      assert 7 === token_capacity

      assert {:ok, {:allow, semaphore_permits, _}} = MscmpSystLimiter.get(updated_semaphore)
      assert 3 === semaphore_permits

      # Reset one limiter without affecting the other
      assert {:ok, {:allow, reset_capacity, _}} = MscmpSystLimiter.reset(updated_token)
      assert 10 === reset_capacity

      # Other limiter should be unchanged
      assert {:ok, {:allow, semaphore_permits, _}} = MscmpSystLimiter.get(updated_semaphore)
      assert 3 === semaphore_permits

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end
  end

  describe "Phase 03 - Error Handling & Edge Cases" do
    test "Step 03.01 - Ensure no service restarts" do
      assert child_spec =
               MscmpSystLimiter.child_spec(
                 service_name: @test_limiter_all,
                 algorithms: [:semaphore]
               )

      assert %{id: MscmpSystLimiter, start: {MscmpSystLimiter, :start_link, [opts]}} = child_spec
      assert {:ok, @test_limiter_all} === Keyword.fetch(opts, :service_name)

      assert {:error, error} =
               DynamicSupervisor.start_child(
                 :"MscmpSystLimiter.TestSupportDynSupervisor",
                 child_spec
               )

      assert %Mserror.LimiterError{kind: :service_management, cause: {:already_started, _}} =
               error
    end

    test "Step 03.02 - Invalid Algorithm in new/5" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      assert_raise FunctionClauseError, fn ->
        MscmpSystLimiter.new(
          :invalid_algorithm,
          @test_comp_all_1,
          :invalid_algorithm_test,
          "invalid_algorithm_test",
          bucket_size: 10,
          refill_rate: 5,
          refill_per: :second
        )
      end

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 03.03 - Invalid Component in new/5" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      assert_raise FunctionClauseError, fn ->
        MscmpSystLimiter.new(
          :token_bucket,
          "invalid_component",
          :invalid_component_test,
          "invalid_component_test",
          bucket_size: 10,
          refill_rate: 5,
          refill_per: :second
        )
      end

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 03.04 - Invalid Type in new/5" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      assert_raise FunctionClauseError, fn ->
        MscmpSystLimiter.new(
          :token_bucket,
          @test_comp_all_1,
          "invalid_type",
          "invalid_type_test",
          bucket_size: 10,
          refill_rate: 5,
          refill_per: :second
        )
      end

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 03.05 - Invalid ID in new/5" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      assert_raise FunctionClauseError, fn ->
        MscmpSystLimiter.new(
          :token_bucket,
          @test_comp_all_1,
          :token_bucket_test,
          123,
          bucket_size: 10,
          refill_rate: 5,
          refill_per: :second
        )
      end

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 03.06 - Missing Required Options in new/5" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      # Missing bucket_size for token bucket
      assert_raise NimbleOptions.ValidationError, fn ->
        MscmpSystLimiter.new(
          :token_bucket,
          @test_comp_all_1,
          :missing_opts_test,
          "missing_opts_test",
          refill_rate: 5,
          refill_per: :second
        )
      end

      # Missing max_permits for semaphore
      assert_raise NimbleOptions.ValidationError, fn ->
        MscmpSystLimiter.new(
          :semaphore,
          @test_comp_all_2,
          :semaphore_test,
          "semaphore_missing_opts_test",
          time_to_live: 5,
          time_scale: :minute
        )
      end

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 03.07 - Invalid Options in new/5" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      # Invalid bucket_size (negative)
      assert_raise NimbleOptions.ValidationError, fn ->
        MscmpSystLimiter.new(
          :token_bucket,
          @test_comp_all_1,
          :token_bucket_test,
          "token_bucket_invalid_test",
          bucket_size: -10,
          refill_rate: 5,
          refill_per: :second
        )
      end

      # Invalid max_permits (zero)
      assert_raise NimbleOptions.ValidationError, fn ->
        MscmpSystLimiter.new(
          :semaphore,
          @test_comp_all_2,
          :semaphore_test,
          "semaphore_invalid_permits_test",
          max_permits: 0,
          time_to_live: 5,
          time_scale: :minute
        )
      end

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 03.08 - Invalid Increment in use/2" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      # Create token bucket limiter
      assert {:ok, limiter} =
               MscmpSystLimiter.new(
                 :token_bucket,
                 @test_comp_all_1,
                 :token_bucket_test,
                 "token_bucket_invalid_increment_test",
                 bucket_size: 10,
                 refill_rate: 5,
                 refill_per: :second
               )

      # Token bucket doesn't support negative increments
      assert {:error, error} = MscmpSystLimiter.use(limiter, -1)
      assert %Mserror.LimiterError{kind: :limiter_management} = error

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 03.09 - Invalid Options in set/2" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      # Create token bucket limiter
      assert {:ok, limiter} =
               MscmpSystLimiter.new(
                 :token_bucket,
                 @test_comp_all_1,
                 :token_bucket_test,
                 "token_bucket_invalid_set_test",
                 bucket_size: 10,
                 refill_rate: 5,
                 refill_per: :second
               )

      # Set current_fill to value exceeding bucket_size
      assert {:error, error} = MscmpSystLimiter.set(limiter, current_fill: 15)
      assert %Mserror.LimiterError{kind: :limiter_management} = error

      # Create semaphore limiter
      assert {:ok, semaphore_limiter} =
               MscmpSystLimiter.new(
                 :semaphore,
                 @test_comp_all_2,
                 :semaphore_test,
                 "semaphore_invalid_set_test",
                 max_permits: 5,
                 time_to_live: 1,
                 time_scale: :hour
               )

      # Set current_permits to value exceeding max_permits
      assert {:error, error} = MscmpSystLimiter.set(semaphore_limiter, current_permits: 10)
      assert %Mserror.LimiterError{kind: :limiter_management} = error

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 03.10 - Operations Without Active Service" do
      # Clear any active service
      assert nil === MscmpSystLimiter.put_service(nil)
      assert nil === MscmpSystLimiter.get_service()

      # Try to create limiter without active service
      assert {:error, error} =
               MscmpSystLimiter.new(
                 :token_bucket,
                 @test_comp_all_1,
                 :token_bucket_test,
                 "no_service_test",
                 bucket_size: 10,
                 refill_rate: 5,
                 refill_per: :second
               )

      assert %Mserror.LimiterError{kind: :limiter_management} = error
    end

    test "Step 03.11 - Edge Case: Zero Increment in Semaphore" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      # Create semaphore limiter
      assert {:ok, limiter} =
               MscmpSystLimiter.new(
                 :semaphore,
                 @test_comp_all_2,
                 :semaphore_test,
                 "semaphore_zero_increment_test",
                 max_permits: 5,
                 time_to_live: 1,
                 time_scale: :hour
               )

      # Zero increment should be a no-op
      assert {:ok, {:allow, permits, _}} = MscmpSystLimiter.use(limiter, 0)
      assert 5 === permits

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 03.12 - Edge Case: Boundary Values in set/2" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      # Create token bucket limiter
      assert {:ok, limiter} =
               MscmpSystLimiter.new(
                 :token_bucket,
                 @test_comp_all_1,
                 :token_bucket_test,
                 "token_bucket_boundary_test",
                 bucket_size: 10,
                 refill_rate: 5,
                 refill_per: :second
               )

      # Set to minimum value (0)
      assert {:ok, {:deny, wait_time, _}} = MscmpSystLimiter.set(limiter, current_fill: 0)
      assert 200 === wait_time

      # Set to maximum value (bucket_size)
      assert {:ok, {:allow, capacity, _}} = MscmpSystLimiter.set(limiter, current_fill: 10)
      assert 10 === capacity

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end

    test "Step 03.13 - Concurrent Operations" do
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      # Create semaphore limiter
      assert {:ok, limiter} =
               MscmpSystLimiter.new(
                 :semaphore,
                 @test_comp_all_2,
                 :semaphore_test,
                 "semaphore_concurrent_test",
                 max_permits: 3,
                 time_to_live: 1,
                 time_scale: :hour
               )

      # Simulate concurrent operations by calling use/2 multiple times
      # This tests thread safety
      results =
        Enum.map(1..5, fn _ ->
          MscmpSystLimiter.use(limiter, 1)
        end)

      # Should have some allows and some denies
      allows =
        Enum.count(results, fn
          {:ok, {:allow, _, _}} -> true
          _ -> false
        end)

      denies =
        Enum.count(results, fn
          {:ok, {:deny, _, _}} -> true
          _ -> false
        end)

      assert allows > 0
      assert denies > 0
      assert allows + denies === 5

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end
  end

  describe "Phase 04 - Service Shutdown" do
    test "Step 04.01 - Graceful Service Shutdown" do
      pid = Process.whereis(@test_limiter_custom)
      assert is_pid(pid)

      # Set the service as active
      assert nil === MscmpSystLimiter.put_service(@test_limiter_custom)
      assert @test_limiter_custom === MscmpSystLimiter.get_service()

      assert {:ok, token_limiter} =
               MscmpSystLimiter.new(
                 :token_bucket,
                 @test_comp_cust_1,
                 :token_bucket_test,
                 "token_bucket_shutdown_test",
                 bucket_size: 10,
                 refill_rate: 5,
                 refill_per: :second
               )

      assert {:ok, semaphore_limiter} =
               MscmpSystLimiter.new(
                 :semaphore,
                 @test_comp_cust_2,
                 :semaphore_test,
                 "semaphore_shutdown_test",
                 max_permits: 5,
                 time_to_live: 1,
                 time_scale: :hour
               )

      assert {:ok, {:allow, _, _}} = MscmpSystLimiter.use(token_limiter, 3)
      assert {:ok, {:allow, _, _}} = MscmpSystLimiter.use(semaphore_limiter, 2)

      assert :ok =
               DynamicSupervisor.terminate_child(
                 :"MscmpSystLimiter.TestSupportDynSupervisor",
                 pid
               )

      assert false === Process.alive?(pid)

      assert @test_limiter_custom === MscmpSystLimiter.put_service(nil)
    end

    test "Step 04.02 - Operations After Service Shutdown" do
      pid = Process.whereis(@test_limiter_one)
      assert is_pid(pid)

      # Set service as active and create a limiter
      assert nil === MscmpSystLimiter.put_service(@test_limiter_one)

      assert {:ok, limiter} =
               MscmpSystLimiter.new(
                 :semaphore,
                 @test_comp_one_1,
                 :semaphore_test,
                 "semaphore_shutdown_ops_test",
                 max_permits: 5,
                 time_to_live: 1,
                 time_scale: :hour
               )

      # Shutdown the service
      assert :ok =
               DynamicSupervisor.terminate_child(
                 :"MscmpSystLimiter.TestSupportDynSupervisor",
                 pid
               )

      # The LLM originally put tests here to ensure that existing counters were
      # no longer usable after the services are shut down... not an unreasonable
      # assumption... but wrong.  Our counters aren't dependent on the service,
      # only counter creation and renewal is dependent on the service being
      # alive an active.

      # Clear the service reference
      assert @test_limiter_one === MscmpSystLimiter.put_service(nil)
    end

    test "Step 04.03 - Service Restart After Shutdown" do
      pid = Process.whereis(@test_limiter_all)
      assert is_pid(pid)

      # Shutdown the service
      assert :ok =
               DynamicSupervisor.terminate_child(
                 :"MscmpSystLimiter.TestSupportDynSupervisor",
                 pid
               )

      assert false === Process.alive?(pid)

      # Start the same service again
      assert child_spec = MscmpSystLimiter.child_spec(service_name: @test_limiter_all)

      assert {:ok, new_pid} =
               DynamicSupervisor.start_child(
                 :"MscmpSystLimiter.TestSupportDynSupervisor",
                 child_spec
               )

      assert is_pid(new_pid)
      assert new_pid !== pid

      # Verify the restarted service works
      assert nil === MscmpSystLimiter.put_service(@test_limiter_all)
      assert @test_limiter_all === MscmpSystLimiter.get_service()

      assert {:ok, limiter} =
               MscmpSystLimiter.new(
                 :token_bucket,
                 @test_comp_all_1,
                 :token_bucket_test,
                 "token_bucket_restart_test",
                 bucket_size: 10,
                 refill_rate: 5,
                 refill_per: :second
               )

      assert {:ok, {:allow, capacity, _}} = MscmpSystLimiter.get(limiter)
      assert 10 === capacity

      # Cleanup
      assert :ok =
               DynamicSupervisor.terminate_child(
                 :"MscmpSystLimiter.TestSupportDynSupervisor",
                 new_pid
               )

      assert @test_limiter_all === MscmpSystLimiter.put_service(nil)
    end
  end
end
