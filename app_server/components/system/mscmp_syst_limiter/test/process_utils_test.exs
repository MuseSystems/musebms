# Source File: process_utils_test.ex
# Location:    musebms/app_server/components/system/mscmp_syst_limiter/test/process_utils_test.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule ProcessUtilsTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias MscmpSystLimiter.Runtime.ProcessUtils

  @moduletag :unit
  @moduletag :capture_log

  # Helper to get a test limiter service name
  defp get_test_limiter_service do
    TestSupport.get_limiter_service_name()
  end

  describe "get_runtime_config/0" do
    test "returns nil when no runtime config is set" do
      # Clear any existing config
      Process.delete(:"MscmpSystLimiter.runtime_config")

      assert ProcessUtils.get_runtime_config() == nil
    end

    test "returns the runtime config when it is set" do
      test_config = %{algorithm: :token_bucket, limit: 100}
      Process.put(:"MscmpSystLimiter.runtime_config", test_config)

      assert ProcessUtils.get_runtime_config() == test_config

      # Cleanup
      Process.delete(:"MscmpSystLimiter.runtime_config")
    end

    test "returns different configs for different processes" do
      # Set config in current process
      current_config = %{algorithm: :semaphore, max_permits: 50}
      Process.put(:"MscmpSystLimiter.runtime_config", current_config)

      # Spawn a task to test isolation
      task =
        Task.async(fn ->
          # This process should not see the config from the parent process
          ProcessUtils.get_runtime_config()
        end)

      task_result = Task.await(task)

      # Current process should have the config
      assert ProcessUtils.get_runtime_config() == current_config
      # Task process should not have any config
      assert task_result == nil

      # Cleanup
      Process.delete(:"MscmpSystLimiter.runtime_config")
    end
  end

  describe "put_service/1 with nil" do
    test "clears both runtime config and service name when called with nil" do
      # Set up some initial values
      Process.put(:"MscmpSystLimiter.runtime_config", %{test: :data})
      Process.put(:"MscmpSystLimiter.service_name", :test_service)

      # Call with nil should clear both
      result = ProcessUtils.put_service(nil)

      # put_service(nil) returns the previous value from Process.put
      assert result == :test_service
      assert Process.get(:"MscmpSystLimiter.runtime_config") == nil
      assert Process.get(:"MscmpSystLimiter.service_name") == nil
    end

    test "returns previous service value when called with nil" do
      # Start with no service
      Process.delete(:"MscmpSystLimiter.service_name")
      result = ProcessUtils.put_service(nil)
      assert result == nil

      # Set a service and then clear it
      Process.put(:"MscmpSystLimiter.service_name", :some_service)
      result2 = ProcessUtils.put_service(nil)
      assert result2 == :some_service
    end

    test "handles multiple calls with nil gracefully" do
      ProcessUtils.put_service(nil)
      ProcessUtils.put_service(nil)

      assert Process.get(:"MscmpSystLimiter.runtime_config") == nil
      assert Process.get(:"MscmpSystLimiter.service_name") == nil
    end
  end

  describe "put_service/1 with service name" do
    test "sets runtime config and service name from GenServer call" do
      limiter_service = get_test_limiter_service()

      # Clear any existing state
      Process.delete(:"MscmpSystLimiter.service_name")
      Process.delete(:"MscmpSystLimiter.runtime_config")

      # Call put_service with the test limiter service
      result = ProcessUtils.put_service(limiter_service)

      # Should return the previous service name (nil in this case)
      assert result == nil

      # Should set the service name in process dictionary
      assert Process.get(:"MscmpSystLimiter.service_name") == limiter_service

      # Should set the runtime config from the GenServer call
      runtime_config = Process.get(:"MscmpSystLimiter.runtime_config")
      assert runtime_config != nil
      assert is_map(runtime_config)
    end

    test "updates existing values when called multiple times" do
      limiter_service = get_test_limiter_service()

      # Set initial values
      Process.put(:"MscmpSystLimiter.runtime_config", %{old: :config})
      Process.put(:"MscmpSystLimiter.service_name", :old_service)

      # Call put_service
      result = ProcessUtils.put_service(limiter_service)

      # Should return the previous service name
      assert result == :old_service

      # Values should be updated
      assert Process.get(:"MscmpSystLimiter.service_name") == limiter_service

      runtime_config = Process.get(:"MscmpSystLimiter.runtime_config")
      assert runtime_config != %{old: :config}
      assert is_map(runtime_config)
    end

    test "handles service isolation between processes" do
      limiter_service = get_test_limiter_service()
      # Set service in current process
      ProcessUtils.put_service(limiter_service)

      # Spawn a task to test isolation
      task =
        Task.async(fn ->
          {ProcessUtils.get_service(), ProcessUtils.get_runtime_config()}
        end)

      {task_service, task_config} = Task.await(task)

      # Current process should have the service and config
      assert ProcessUtils.get_service() == limiter_service
      assert ProcessUtils.get_runtime_config() != nil

      # Task process should not have the service or config
      assert task_service == nil
      assert task_config == nil
    end
  end

  describe "get_service/0" do
    test "returns nil when no service is set" do
      # Clear any existing service
      Process.delete(:"MscmpSystLimiter.service_name")

      assert ProcessUtils.get_service() == nil
    end

    test "returns the service name when it is set" do
      limiter_service = get_test_limiter_service()
      Process.put(:"MscmpSystLimiter.service_name", limiter_service)

      assert ProcessUtils.get_service() == limiter_service

      # Cleanup
      Process.delete(:"MscmpSystLimiter.service_name")
    end

    test "returns different services for different processes" do
      # Set service in current process
      test_service = :test_limiter_service
      Process.put(:"MscmpSystLimiter.service_name", test_service)

      # Spawn a task to test isolation
      task =
        Task.async(fn ->
          ProcessUtils.get_service()
        end)

      task_result = Task.await(task)

      # Current process should have the service
      assert ProcessUtils.get_service() == test_service
      # Task process should not have any service
      assert task_result == nil

      # Cleanup
      Process.delete(:"MscmpSystLimiter.service_name")
    end

    test "reflects changes made by put_service" do
      limiter_service = get_test_limiter_service()

      # Start with clean state
      Process.delete(:"MscmpSystLimiter.service_name")
      assert ProcessUtils.get_service() == nil

      # Set service with put_service
      ProcessUtils.put_service(limiter_service)
      assert ProcessUtils.get_service() == limiter_service

      # Clear service with put_service(nil)
      ProcessUtils.put_service(nil)
      assert ProcessUtils.get_service() == nil
    end
  end

  describe "integration behavior" do
    test "put_service and get_service work together consistently" do
      limiter_service = get_test_limiter_service()

      # Start with clean state
      Process.delete(:"MscmpSystLimiter.service_name")
      Process.delete(:"MscmpSystLimiter.runtime_config")

      # Verify clean state
      assert ProcessUtils.get_service() == nil
      assert ProcessUtils.get_runtime_config() == nil

      # Set service and verify both service and config are set
      ProcessUtils.put_service(limiter_service)
      assert ProcessUtils.get_service() == limiter_service
      assert ProcessUtils.get_runtime_config() != nil

      # Clear and verify both are cleared
      ProcessUtils.put_service(nil)
      assert ProcessUtils.get_service() == nil
      assert ProcessUtils.get_runtime_config() == nil
    end

    test "process dictionary isolation works across all functions" do
      limiter_service = get_test_limiter_service()
      # Set up in current process
      ProcessUtils.put_service(limiter_service)
      current_service = ProcessUtils.get_service()
      current_config = ProcessUtils.get_runtime_config()

      # Verify current process state
      assert current_service == limiter_service
      assert current_config != nil

      # Test in spawned process
      task =
        Task.async(fn ->
          # Should see clean state
          initial_service = ProcessUtils.get_service()
          initial_config = ProcessUtils.get_runtime_config()

          # Set different service in this process
          ProcessUtils.put_service(limiter_service)
          spawned_service = ProcessUtils.get_service()
          spawned_config = ProcessUtils.get_runtime_config()

          {initial_service, initial_config, spawned_service, spawned_config}
        end)

      {initial_service, initial_config, spawned_service, spawned_config} = Task.await(task)

      # Spawned process should start clean
      assert initial_service == nil
      assert initial_config == nil

      # Spawned process should be able to set its own values
      assert spawned_service == limiter_service
      assert spawned_config != nil

      # Current process should be unaffected
      assert ProcessUtils.get_service() == current_service
      assert ProcessUtils.get_runtime_config() == current_config
    end

    test "handles rapid successive calls without issues" do
      limiter_service = get_test_limiter_service()

      # Start with clean state
      Process.delete(:"MscmpSystLimiter.service_name")
      Process.delete(:"MscmpSystLimiter.runtime_config")

      # Rapid calls should not cause issues
      for _i <- 1..10 do
        ProcessUtils.put_service(limiter_service)
        assert ProcessUtils.get_service() == limiter_service
        assert ProcessUtils.get_runtime_config() != nil

        ProcessUtils.put_service(nil)
        assert ProcessUtils.get_service() == nil
        assert ProcessUtils.get_runtime_config() == nil
      end
    end
  end

  describe "error conditions and edge cases" do
    test "handles non-existent GenServer gracefully" do
      # This test verifies the module's behavior when the GenServer doesn't exist
      # We expect this to raise an EXIT error since GenServer.call will fail
      non_existent_service = :non_existent_limiter_service

      # Store current state
      current_service = ProcessUtils.get_service()
      current_config = ProcessUtils.get_runtime_config()

      # The function will raise an exit error
      catch_exit(ProcessUtils.put_service(non_existent_service))

      # Process state should remain unchanged after the error
      assert ProcessUtils.get_service() == current_service
      assert ProcessUtils.get_runtime_config() == current_config
    end

    test "preserves type specifications behavior" do
      # Test that the functions behave according to their typespecs

      # get_runtime_config should return map() | nil
      config_result = ProcessUtils.get_runtime_config()
      assert config_result == nil or is_map(config_result)

      # get_service should return ServiceTypes.service_name() (which is GenServer.name() | nil)
      service_result = ProcessUtils.get_service()

      assert service_result == nil or is_atom(service_result) or is_pid(service_result) or
               (is_tuple(service_result) and tuple_size(service_result) >= 2)

      # put_service with nil returns the previous value (can be nil or a service name)
      # Clear any existing service first
      Process.delete(:"MscmpSystLimiter.service_name")
      nil_result = ProcessUtils.put_service(nil)
      # Should return nil since there was no previous value
      assert nil_result == nil

      # Set a service and then clear it - should return the previous service
      limiter_service = get_test_limiter_service()
      ProcessUtils.put_service(limiter_service)
      clear_result = ProcessUtils.put_service(nil)
      assert clear_result == limiter_service
    end
  end
end
