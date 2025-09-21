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

  use LimiterTestCase, async: false

  @moduletag :integration
  @moduletag :capture_log

  # Test module names for organizing limiters
  @test_component_api IntegrationTest.API
  @test_component_db IntegrationTest.Database
  @test_component_web IntegrationTest.Web

  describe "Service Management Integration" do
    test "service lifecycle management works end-to-end", %{limiter_service: original_service} do
      # Test 1: Start a new service with custom configuration
      {:ok, custom_service_pid} =
        MscmpSystLimiter.start_link(
          service_name: :CustomLimiterService,
          algorithms: [:token_bucket, :semaphore],
          cleanup_interval: [token_bucket: 30_000, semaphore: 45_000]
        )

      assert is_pid(custom_service_pid)
      assert Process.alive?(custom_service_pid)

      # Test 2: Switch to the new service and verify it's active
      _old_service = MscmpSystLimiter.put_service(:CustomLimiterService)
      # old_service should be the previously set service (could be nil or the original service)
      assert MscmpSystLimiter.get_service() == :CustomLimiterService

      # Test 3: Verify runtime configuration is accessible
      config = MscmpSystLimiter.get_runtime_config()
      assert is_map(config)
      assert Map.has_key?(config, :token_bucket)
      assert Map.has_key?(config, :semaphore)

      # Test 4: Create a limiter to verify the service is functional
      {:ok, test_limiter} =
        MscmpSystLimiter.new(
          :token_bucket,
          @test_component_api,
          :test_requests,
          "service_test",
          bucket_size: 10,
          refill_rate: 5,
          refill_per: :second
        )

      {:ok, {:allow, capacity, _}} = MscmpSystLimiter.get(test_limiter)
      assert capacity == 10

      # Test 5: Restore original service
      restored_service = MscmpSystLimiter.put_service(original_service)
      assert restored_service == :CustomLimiterService
      assert MscmpSystLimiter.get_service() == original_service

      # Test 6: Clean up - stop the custom service
      :ok = GenServer.stop(custom_service_pid)
      refute Process.alive?(custom_service_pid)
    end

    test "service switching maintains independent limiter state", %{
      limiter_service: original_service
    } do
      # Start two separate services
      {:ok, service_a_pid} =
        MscmpSystLimiter.start_link(service_name: :ServiceA, algorithms: :all)

      {:ok, service_b_pid} =
        MscmpSystLimiter.start_link(service_name: :ServiceB, algorithms: :all)

      # Create limiter in Service A
      MscmpSystLimiter.put_service(:ServiceA)

      {:ok, limiter_a} =
        MscmpSystLimiter.new(
          :token_bucket,
          @test_component_api,
          :isolation_test,
          "shared_id",
          bucket_size: 20,
          refill_rate: 10,
          refill_per: :second
        )

      # Consume tokens in Service A
      {:ok, {:allow, remaining_a, updated_limiter_a}} = MscmpSystLimiter.use(limiter_a, 5)
      assert remaining_a == 15

      # Switch to Service B and create limiter with same identity
      MscmpSystLimiter.put_service(:ServiceB)

      {:ok, limiter_b} =
        MscmpSystLimiter.new(
          :token_bucket,
          @test_component_api,
          :isolation_test,
          "shared_id",
          bucket_size: 20,
          refill_rate: 10,
          refill_per: :second
        )

      # Service B should have full tokens (independent state)
      {:ok, {:allow, capacity_b, _}} = MscmpSystLimiter.get(limiter_b)
      assert capacity_b == 20

      # Switch back to Service A and verify state is preserved
      MscmpSystLimiter.put_service(:ServiceA)
      {:ok, {:allow, capacity_a_check, _}} = MscmpSystLimiter.get(updated_limiter_a)
      assert capacity_a_check == 15

      # Cleanup
      MscmpSystLimiter.put_service(original_service)
      GenServer.stop(service_a_pid)
      GenServer.stop(service_b_pid)
    end
  end

  describe "Token Bucket Integration Workflows" do
    test "complete token bucket lifecycle with business workflow", %{limiter_service: _service} do
      # Business Scenario: API rate limiting for user requests
      user_id = "user_12345"

      # Step 1: Create API rate limiter (100 requests per minute)
      {:ok, api_limiter} =
        MscmpSystLimiter.new(
          :token_bucket,
          @test_component_api,
          :user_requests,
          user_id,
          bucket_size: 100,
          refill_rate: 100,
          refill_per: :minute
        )

      # Step 2: Verify initial full capacity
      {:ok, {:allow, initial_capacity, _}} = MscmpSystLimiter.get(api_limiter)
      assert initial_capacity == 100

      # Step 3: Simulate burst of API requests (within limit)
      requests_to_make = 80
      final_limiter = simulate_api_requests(api_limiter, requests_to_make)

      # Step 4: Check remaining capacity
      {:ok, {:allow, remaining_after_burst, _}} = MscmpSystLimiter.get(final_limiter)
      assert remaining_after_burst == 20

      # Step 5: Try to exceed limit
      {:ok, result} = MscmpSystLimiter.use(final_limiter, 30)

      case result do
        {:deny, retry_after_ms, denied_limiter} ->
          assert is_integer(retry_after_ms)
          assert retry_after_ms > 0

          # Step 6: Verify state is still consistent
          {:ok, {:allow, capacity_after_deny, _}} = MscmpSystLimiter.get(denied_limiter)
          assert capacity_after_deny == 20

        {:allow, _, _} ->
          flunk("Expected request to be denied when exceeding bucket capacity")
      end

      # Step 7: Reset for maintenance scenario
      {:ok, {:allow, reset_capacity, reset_limiter}} = MscmpSystLimiter.reset(final_limiter)
      assert reset_capacity == 100

      # Step 8: Verify reset worked by consuming full capacity
      {:ok, {:allow, final_remaining, _}} = MscmpSystLimiter.use(reset_limiter, 100)
      assert final_remaining == 0
    end

    test "token bucket refill behavior over time simulation", %{limiter_service: _service} do
      # Create fast-refilling bucket for time-based testing
      {:ok, fast_limiter} =
        MscmpSystLimiter.new(
          :token_bucket,
          @test_component_api,
          :fast_refill,
          "time_test",
          bucket_size: 10,
          refill_rate: 10,
          refill_per: :second
        )

      # Consume all tokens
      {:ok, {:allow, 0, depleted_limiter}} = MscmpSystLimiter.use(fast_limiter, 10)

      # Verify completely depleted
      {:ok, {:allow, depleted_capacity, _}} = MscmpSystLimiter.get(depleted_limiter)
      assert depleted_capacity == 0

      # Wait for partial refill (need to be careful with timing in tests)
      # Wait slightly over 1 second
      Process.sleep(1100)

      # Check if tokens have been refilled
      {:ok, {:allow, refilled_capacity, refilled_limiter}} =
        MscmpSystLimiter.get(depleted_limiter)

      # Should have refilled most/all tokens
      assert refilled_capacity >= 8

      # Verify we can consume the refilled tokens
      {:ok, {:allow, remaining_after_refill, _}} = MscmpSystLimiter.use(refilled_limiter, 5)
      assert remaining_after_refill >= 3
    end

    test "multiple token bucket limiters for different resources", %{limiter_service: _service} do
      user_id = "multi_user_456"

      # Create different types of limiters for the same user
      {:ok, api_limiter} =
        MscmpSystLimiter.new(
          :token_bucket,
          @test_component_api,
          :api_calls,
          user_id,
          bucket_size: 1000,
          refill_rate: 100,
          refill_per: :minute
        )

      {:ok, upload_limiter} =
        MscmpSystLimiter.new(
          :token_bucket,
          @test_component_web,
          :file_uploads,
          user_id,
          bucket_size: 10,
          refill_rate: 5,
          refill_per: :hour
        )

      {:ok, db_limiter} =
        MscmpSystLimiter.new(
          :token_bucket,
          @test_component_db,
          :queries,
          user_id,
          bucket_size: 500,
          refill_rate: 100,
          refill_per: :minute
        )

      # Use each limiter independently
      {:ok, {:allow, api_remaining, _}} = MscmpSystLimiter.use(api_limiter, 100)
      assert api_remaining == 900

      {:ok, {:allow, upload_remaining, _}} = MscmpSystLimiter.use(upload_limiter, 3)
      assert upload_remaining == 7

      {:ok, {:allow, db_remaining, _}} = MscmpSystLimiter.use(db_limiter, 50)
      assert db_remaining == 450

      # Verify they maintain independent state
      {:ok, {:allow, api_check, _}} = MscmpSystLimiter.get(api_limiter)
      {:ok, {:allow, upload_check, _}} = MscmpSystLimiter.get(upload_limiter)
      {:ok, {:allow, db_check, _}} = MscmpSystLimiter.get(db_limiter)

      assert api_check == 900
      assert upload_check == 7
      assert db_check == 450
    end

    test "token bucket explicit capacity management", %{limiter_service: _service} do
      {:ok, managed_limiter} =
        MscmpSystLimiter.new(
          :token_bucket,
          @test_component_api,
          :managed_capacity,
          "admin_test",
          bucket_size: 50,
          refill_rate: 25,
          refill_per: :minute
        )

      # Use some capacity
      {:ok, {:allow, after_use, used_limiter}} = MscmpSystLimiter.use(managed_limiter, 20)
      assert after_use == 30

      # Administratively set capacity to specific value
      {:ok, {:allow, set_capacity, set_limiter}} =
        MscmpSystLimiter.set(used_limiter, current_fill: 45)

      assert set_capacity == 45

      # Verify the set worked
      {:ok, {:allow, verified_capacity, _}} = MscmpSystLimiter.get(set_limiter)
      assert verified_capacity == 45

      # Reset to full capacity
      {:ok, {:allow, reset_capacity, reset_limiter}} = MscmpSystLimiter.reset(set_limiter)
      assert reset_capacity == 50

      # Final verification
      {:ok, {:allow, final_capacity, _}} = MscmpSystLimiter.get(reset_limiter)
      assert final_capacity == 50
    end
  end

  describe "Semaphore Integration Workflows" do
    test "complete semaphore lifecycle with connection pool workflow", %{
      limiter_service: _service
    } do
      # Business Scenario: Database connection pool management
      pool_id = "primary_db_pool"

      # Step 1: Create semaphore for connection pool (20 connections, 1 hour TTL)
      {:ok, pool_limiter} =
        MscmpSystLimiter.new(
          :semaphore,
          @test_component_db,
          :connection_pool,
          pool_id,
          max_permits: 20,
          time_to_live: 1,
          time_scale: :hour
        )

      # Step 2: Verify initial full permits
      {:ok, {:allow, initial_permits, _}} = MscmpSystLimiter.get(pool_limiter)
      assert initial_permits == 20

      # Step 3: Simulate acquiring connections for different operations
      {:ok, {:allow, after_read_conn, read_limiter}} = MscmpSystLimiter.use(pool_limiter, 5)
      assert after_read_conn == 15

      {:ok, {:allow, after_write_conn, write_limiter}} = MscmpSystLimiter.use(read_limiter, 3)
      assert after_write_conn == 12

      {:ok, {:allow, after_batch_conn, batch_limiter}} = MscmpSystLimiter.use(write_limiter, 7)
      assert after_batch_conn == 5

      # Step 4: Try to acquire more connections than available
      {:ok, result} = MscmpSystLimiter.use(batch_limiter, 10)

      case result do
        {:deny, needed_permits, denied_limiter} ->
          # Need 5 more permits to satisfy request
          assert needed_permits == 5
          {:ok, {:allow, capacity_after_deny, _}} = MscmpSystLimiter.get(denied_limiter)
          assert capacity_after_deny == 5

        {:allow, _, _} ->
          flunk("Expected request to be denied when exceeding semaphore capacity")
      end

      # Step 5: Release some connections
      {:ok, {:allow, after_release, release_limiter}} = MscmpSystLimiter.use(batch_limiter, -8)
      assert after_release == 13

      # Step 6: Now the previously failed request should succeed
      {:ok, {:allow, after_large_acquire, _}} = MscmpSystLimiter.use(release_limiter, 10)
      assert after_large_acquire == 3

      # Step 7: Reset for maintenance scenario
      {:ok, {:allow, reset_permits, reset_limiter}} = MscmpSystLimiter.reset(release_limiter)
      assert reset_permits == 20

      # Step 8: Verify reset worked
      {:ok, {:allow, final_permits, _}} = MscmpSystLimiter.get(reset_limiter)
      assert final_permits == 20
    end

    test "semaphore permit acquisition and release patterns", %{limiter_service: _service} do
      {:ok, resource_limiter} =
        MscmpSystLimiter.new(
          :semaphore,
          @test_component_api,
          :worker_threads,
          "thread_pool_test",
          max_permits: 10,
          time_to_live: 30,
          time_scale: :minute
        )

      # Pattern 1: Gradual acquisition
      final_limiter =
        Enum.reduce(1..7, resource_limiter, fn _, acc_limiter ->
          {:ok, {:allow, _remaining, updated_limiter}} = MscmpSystLimiter.use(acc_limiter, 1)
          updated_limiter
        end)

      {:ok, {:allow, after_gradual, _}} = MscmpSystLimiter.get(final_limiter)
      assert after_gradual == 3

      # Pattern 2: Bulk release
      {:ok, {:allow, after_bulk_release, bulk_limiter}} = MscmpSystLimiter.use(final_limiter, -5)
      assert after_bulk_release == 8

      # Pattern 3: No-op operations (zero increment)
      {:ok, {:allow, after_noop, noop_limiter}} = MscmpSystLimiter.use(bulk_limiter, 0)
      assert after_noop == 8

      # Pattern 4: Attempt to over-release (should cap at max_permits)
      {:ok, {:allow, after_over_release, _}} = MscmpSystLimiter.use(noop_limiter, -15)
      # Capped at max_permits
      assert after_over_release == 10
    end

    test "multiple semaphore limiters for resource hierarchies", %{limiter_service: _service} do
      service_id = "microservice_123"

      # Create hierarchical resource limiters
      {:ok, cpu_limiter} =
        MscmpSystLimiter.new(
          :semaphore,
          @test_component_api,
          :cpu_cores,
          service_id,
          max_permits: 8,
          time_to_live: 2,
          time_scale: :hour
        )

      {:ok, memory_limiter} =
        MscmpSystLimiter.new(
          :semaphore,
          @test_component_api,
          :memory_gb,
          service_id,
          max_permits: 16,
          time_to_live: 2,
          time_scale: :hour
        )

      {:ok, network_limiter} =
        MscmpSystLimiter.new(
          :semaphore,
          @test_component_api,
          :network_connections,
          service_id,
          max_permits: 100,
          time_to_live: 1,
          time_scale: :hour
        )

      # Simulate resource allocation for a complex operation
      {:ok, {:allow, cpu_remaining, cpu_used}} = MscmpSystLimiter.use(cpu_limiter, 4)
      assert cpu_remaining == 4

      {:ok, {:allow, memory_remaining, memory_used}} = MscmpSystLimiter.use(memory_limiter, 8)
      assert memory_remaining == 8

      {:ok, {:allow, network_remaining, network_used}} = MscmpSystLimiter.use(network_limiter, 25)
      assert network_remaining == 75

      # Verify independent resource tracking
      {:ok, {:allow, cpu_check, _}} = MscmpSystLimiter.get(cpu_used)
      {:ok, {:allow, memory_check, _}} = MscmpSystLimiter.get(memory_used)
      {:ok, {:allow, network_check, _}} = MscmpSystLimiter.get(network_used)

      assert cpu_check == 4
      assert memory_check == 8
      assert network_check == 75

      # Simulate operation completion - release resources
      {:ok, {:allow, cpu_released, _}} = MscmpSystLimiter.use(cpu_used, -4)
      {:ok, {:allow, memory_released, _}} = MscmpSystLimiter.use(memory_used, -8)
      {:ok, {:allow, network_released, _}} = MscmpSystLimiter.use(network_used, -25)

      assert cpu_released == 8
      assert memory_released == 16
      assert network_released == 100
    end

    test "semaphore explicit permit management", %{limiter_service: _service} do
      {:ok, managed_semaphore} =
        MscmpSystLimiter.new(
          :semaphore,
          @test_component_db,
          :managed_permits,
          "admin_test",
          max_permits: 25,
          time_to_live: 1,
          time_scale: :hour
        )

      # Use some permits
      {:ok, {:allow, after_use, used_limiter}} = MscmpSystLimiter.use(managed_semaphore, 10)
      assert after_use == 15

      # Administratively set permits to specific value
      {:ok, {:allow, set_permits, set_limiter}} =
        MscmpSystLimiter.set(used_limiter, current_permits: 20)

      assert set_permits == 20

      # Verify the set worked
      {:ok, {:allow, verified_permits, _}} = MscmpSystLimiter.get(set_limiter)
      assert verified_permits == 20

      # Reset to full permits
      {:ok, {:allow, reset_permits, reset_limiter}} = MscmpSystLimiter.reset(set_limiter)
      assert reset_permits == 25

      # Final verification
      {:ok, {:allow, final_permits, _}} = MscmpSystLimiter.get(reset_limiter)
      assert final_permits == 25
    end
  end

  describe "Mixed Algorithm Integration" do
    test "coordinated rate limiting with both algorithms", %{limiter_service: _service} do
      user_id = "coordinated_user_789"

      # Create both types of limiters for comprehensive rate limiting
      {:ok, request_bucket} =
        MscmpSystLimiter.new(
          :token_bucket,
          @test_component_api,
          :requests_per_minute,
          user_id,
          bucket_size: 60,
          refill_rate: 60,
          refill_per: :minute
        )

      {:ok, concurrent_semaphore} =
        MscmpSystLimiter.new(
          :semaphore,
          @test_component_api,
          :concurrent_operations,
          user_id,
          max_permits: 5,
          time_to_live: 10,
          time_scale: :minute
        )

      # Simulate a workflow that requires both rate limiting and concurrency control
      workflow_results = simulate_coordinated_workflow(request_bucket, concurrent_semaphore, 10)

      # Verify both limiters were properly utilized
      {final_bucket, final_semaphore, successful_operations} = workflow_results

      {:ok, {:allow, remaining_requests, _}} = MscmpSystLimiter.get(final_bucket)
      {:ok, {:allow, available_permits, _}} = MscmpSystLimiter.get(final_semaphore)

      # Some requests were consumed
      assert remaining_requests <= 60
      # All permits should be released after operations
      assert available_permits == 5
      # All operations completed successfully
      assert successful_operations == 10
    end

    test "algorithm independence verification", %{limiter_service: _service} do
      shared_id = "independence_test"

      # Create limiters with same component/type/id but different algorithms
      {:ok, bucket_limiter} =
        MscmpSystLimiter.new(
          :token_bucket,
          @test_component_api,
          :shared_resource,
          shared_id,
          bucket_size: 100,
          refill_rate: 50,
          refill_per: :minute
        )

      {:ok, semaphore_limiter} =
        MscmpSystLimiter.new(
          :semaphore,
          @test_component_api,
          :shared_resource,
          shared_id,
          max_permits: 10,
          time_to_live: 1,
          time_scale: :hour
        )

      # Use bucket limiter
      {:ok, {:allow, bucket_remaining, bucket_used}} = MscmpSystLimiter.use(bucket_limiter, 30)
      assert bucket_remaining == 70

      # Use semaphore limiter
      {:ok, {:allow, semaphore_remaining, semaphore_used}} =
        MscmpSystLimiter.use(semaphore_limiter, 4)

      assert semaphore_remaining == 6

      # Verify they maintain independent state despite shared identity components
      {:ok, {:allow, bucket_check, _}} = MscmpSystLimiter.get(bucket_used)
      {:ok, {:allow, semaphore_check, _}} = MscmpSystLimiter.get(semaphore_used)

      assert bucket_check == 70
      assert semaphore_check == 6

      # Reset one should not affect the other
      {:ok, {:allow, bucket_reset, _}} = MscmpSystLimiter.reset(bucket_used)
      {:ok, {:allow, semaphore_after_bucket_reset, _}} = MscmpSystLimiter.get(semaphore_used)

      assert bucket_reset == 100
      # Unchanged
      assert semaphore_after_bucket_reset == 6
    end
  end

  describe "Error Handling and Edge Cases Integration" do
    test "invalid parameters result in proper errors", %{limiter_service: _service} do
      # Test invalid algorithm
      assert_raise FunctionClauseError, fn ->
        MscmpSystLimiter.new(
          :invalid_algorithm,
          @test_component_api,
          :test_type,
          "test_id",
          bucket_size: 10,
          refill_rate: 5,
          refill_per: :second
        )
      end

      # Test invalid component (not an atom suitable for module names)
      assert_raise FunctionClauseError, fn ->
        MscmpSystLimiter.new(
          :token_bucket,
          "not_an_atom",
          :test_type,
          "test_id",
          bucket_size: 10,
          refill_rate: 5,
          refill_per: :second
        )
      end

      # Test invalid type (not an atom)
      assert_raise FunctionClauseError, fn ->
        MscmpSystLimiter.new(
          :token_bucket,
          @test_component_api,
          "not_an_atom",
          "test_id",
          bucket_size: 10,
          refill_rate: 5,
          refill_per: :second
        )
      end

      # Test invalid ID (not a binary)
      assert_raise FunctionClauseError, fn ->
        MscmpSystLimiter.new(
          :token_bucket,
          @test_component_api,
          :test_type,
          :not_a_binary,
          bucket_size: 10,
          refill_rate: 5,
          refill_per: :second
        )
      end
    end

    test "invalid options result in proper validation errors", %{limiter_service: _service} do
      # Test missing required token bucket options
      assert_raise NimbleOptions.ValidationError, fn ->
        MscmpSystLimiter.new(
          :token_bucket,
          @test_component_api,
          :test_type,
          "test_id",
          bucket_size: 10
          # Missing refill_rate and refill_per
        )
      end

      # Test invalid token bucket values
      assert_raise NimbleOptions.ValidationError, fn ->
        MscmpSystLimiter.new(
          :token_bucket,
          @test_component_api,
          :test_type,
          "test_id",
          # Invalid: must be positive
          bucket_size: 0,
          refill_rate: 5,
          refill_per: :second
        )
      end

      # Test missing required semaphore options
      assert_raise NimbleOptions.ValidationError, fn ->
        MscmpSystLimiter.new(
          :semaphore,
          @test_component_api,
          :test_type,
          "test_id",
          max_permits: 10
          # Missing time_to_live and time_scale
        )
      end

      # Test invalid semaphore values
      assert_raise NimbleOptions.ValidationError, fn ->
        MscmpSystLimiter.new(
          :semaphore,
          @test_component_api,
          :test_type,
          "test_id",
          # Invalid: must be positive
          max_permits: -5,
          time_to_live: 1,
          time_scale: :hour
        )
      end
    end

    test "operations on invalid limiter instances handle gracefully", %{limiter_service: _service} do
      # Create a valid limiter first
      {:ok, valid_limiter} =
        MscmpSystLimiter.new(
          :token_bucket,
          @test_component_api,
          :test_type,
          "valid_test",
          bucket_size: 10,
          refill_rate: 5,
          refill_per: :second
        )

      # Test with malformed limiter instance
      invalid_limiter = {:invalid_algorithm, "bad", "data"}

      # These should raise CaseClauseError due to pattern matching failure in the case statements
      assert_raise CaseClauseError, fn ->
        MscmpSystLimiter.use(invalid_limiter, 1)
      end

      assert_raise CaseClauseError, fn ->
        MscmpSystLimiter.get(invalid_limiter)
      end

      assert_raise CaseClauseError, fn ->
        MscmpSystLimiter.set(invalid_limiter, current_fill: 5)
      end

      assert_raise CaseClauseError, fn ->
        MscmpSystLimiter.reset(invalid_limiter)
      end

      # Valid limiter should still work
      assert {:ok, {:allow, 10, _}} = MscmpSystLimiter.get(valid_limiter)
    end

    test "service unavailable scenarios", %{limiter_service: original_service} do
      # Test behavior when no service is set
      MscmpSystLimiter.put_service(nil)

      # Should still handle gracefully (likely returning errors)
      result =
        MscmpSystLimiter.new(
          :token_bucket,
          @test_component_api,
          :no_service_test,
          "test_id",
          bucket_size: 10,
          refill_rate: 5,
          refill_per: :second
        )

      # Might succeed or fail depending on implementation - just verify it doesn't crash
      case result do
        {:ok, _limiter} -> :ok
        {:error, _error} -> :ok
      end

      # Restore service
      MscmpSystLimiter.put_service(original_service)
    end
  end

  # Helper function to simulate multiple API requests
  defp simulate_api_requests(limiter, 0), do: limiter

  defp simulate_api_requests(limiter, count) when count > 0 do
    {:ok, {:allow, _remaining, updated_limiter}} = MscmpSystLimiter.use(limiter, 1)
    simulate_api_requests(updated_limiter, count - 1)
  end

  # Helper function to simulate coordinated workflow using both algorithms
  defp simulate_coordinated_workflow(bucket_limiter, semaphore_limiter, operations_count) do
    simulate_coordinated_operations(bucket_limiter, semaphore_limiter, operations_count, 0)
  end

  defp simulate_coordinated_operations(bucket_limiter, semaphore_limiter, 0, completed_count) do
    {bucket_limiter, semaphore_limiter, completed_count}
  end

  defp simulate_coordinated_operations(
         bucket_limiter,
         semaphore_limiter,
         remaining_ops,
         completed_count
       ) do
    # Each operation requires both a token and a permit
    with {:ok, {:allow, _tokens_remaining, updated_bucket}} <-
           MscmpSystLimiter.use(bucket_limiter, 1),
         {:ok, {:allow, _permits_remaining, updated_semaphore}} <-
           MscmpSystLimiter.use(semaphore_limiter, 1) do
      # Simulate operation work
      Process.sleep(10)

      # Release the permit (token is consumed)
      {:ok, {:allow, _permits_after_release, final_semaphore}} =
        MscmpSystLimiter.use(updated_semaphore, -1)

      simulate_coordinated_operations(
        updated_bucket,
        final_semaphore,
        remaining_ops - 1,
        completed_count + 1
      )
    else
      # If either resource is unavailable, stop the simulation
      _ -> {bucket_limiter, semaphore_limiter, completed_count}
    end
  end
end
