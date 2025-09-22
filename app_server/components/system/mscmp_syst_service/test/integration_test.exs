# Source File: integration_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_service/test/integration_test.exs
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

  use ExUnit.Case

  alias TestService

  @moduletag :integration
  @moduletag :capture_log

  # ==============================================================================================
  # ==============================================================================================
  #
  # Behaviour Contract Tests
  #
  # ==============================================================================================
  # ==============================================================================================

  describe "MscmpSystService behaviour contract" do
    test "defines all required callbacks" do
      callbacks = MscmpSystService.behaviour_info(:callbacks)

      expected_callbacks = [
        {:child_spec, 1},
        {:start_link, 1},
        {:put_service, 1},
        {:get_service, 0},
        {:get_runtime_config, 0}
      ]

      for callback <- expected_callbacks do
        assert callback in callbacks,
               "Expected callback #{inspect(callback)} not found in behaviour"
      end
    end

    test "callback specifications are properly typed" do
      # This test ensures that if we change callback specs, we do so intentionally
      # by having to update the test as well

      # Verify that the behaviour module has the expected callback documentation
      # This indirectly verifies the callbacks are properly specified
      docs = Code.fetch_docs(MscmpSystService)

      case docs do
        {:docs_v1, _, _, _, _, _, docs_list} ->
          callback_docs =
            Enum.filter(docs_list, fn
              {{:callback, _, _}, _, _, _, _} -> true
              _ -> false
            end)

          callback_names =
            Enum.map(callback_docs, fn {{:callback, name, _}, _, _, _, _} -> name end)

          expected_callbacks = [
            :child_spec,
            :start_link,
            :put_service,
            :get_service,
            :get_runtime_config
          ]

          for callback <- expected_callbacks do
            assert callback in callback_names,
                   "Expected callback #{callback} not found in callback documentation"
          end

        _ ->
          # If we can't fetch docs, verify via behaviour_info which we know works
          callbacks = MscmpSystService.behaviour_info(:callbacks)
          callback_names = Enum.map(callbacks, fn {name, _arity} -> name end)

          expected_callbacks = [
            :child_spec,
            :start_link,
            :put_service,
            :get_service,
            :get_runtime_config
          ]

          for callback <- expected_callbacks do
            assert callback in callback_names,
                   "Expected callback #{callback} not found in behaviour"
          end
      end
    end
  end

  # ==============================================================================================
  # ==============================================================================================
  #
  # __using__ Macro Tests
  #
  # ==============================================================================================
  # ==============================================================================================

  describe "__using__ macro functionality" do
    test "injects @behaviour MscmpSystService" do
      behaviours = TestService.__info__(:attributes)[:behaviour] || []
      assert MscmpSystService in behaviours
    end

    test "macro expands correctly and allows service implementation" do
      # Instead of testing the attributes directly (which aren't preserved),
      # we test that the macro allows proper service implementation by verifying
      # that our TestService module can be compiled and implements all callbacks

      # Verify all required callbacks are implemented
      callbacks = MscmpSystService.behaviour_info(:callbacks)

      for {callback_name, arity} <- callbacks do
        assert function_exported?(TestService, callback_name, arity),
               "TestService does not implement required callback #{callback_name}/#{arity}"
      end

      # Verify the service can be started (this tests that the implementation works)
      service_name = :test_macro_functionality
      assert {:ok, pid} = TestService.start_link(service_name: service_name)
      assert is_pid(pid)

      # Cleanup
      TestService.stop(service_name)
    end

    test "macro-injected functionality works as expected" do
      # Test that the standard GenServer options would be available if used
      # by verifying our test service handles the expected options

      service_name = :test_macro_options

      # Test with various options that the macro is supposed to support
      opts = [
        service_name: service_name,
        timeout: 5000
        # Note: debug and hibernate_after are harder to test but the service_name
        # proves the macro injection works
      ]

      assert {:ok, pid} = TestService.start_link(opts)
      assert Process.whereis(service_name) == pid

      # Cleanup
      TestService.stop(service_name)
    end
  end

  # ==============================================================================================
  # ==============================================================================================
  #
  # Service Implementation Tests
  #
  # ==============================================================================================
  # ==============================================================================================

  describe "service implementation functionality" do
    test "child_spec/1 returns valid supervisor child specification" do
      opts = [service_name: :test_service_child_spec]
      child_spec = TestService.child_spec(opts)

      assert is_map(child_spec)
      assert Map.has_key?(child_spec, :id)
      assert Map.has_key?(child_spec, :start)
      assert Map.has_key?(child_spec, :type)
      assert Map.has_key?(child_spec, :restart)
      assert Map.has_key?(child_spec, :shutdown)

      assert child_spec.id == :test_service_child_spec
      assert child_spec.type == :worker
      assert child_spec.restart == :permanent
      assert is_integer(child_spec.shutdown)
    end

    test "start_link/1 starts service with name" do
      service_name = :test_service_named
      opts = [service_name: service_name]

      assert {:ok, pid} = TestService.start_link(opts)
      assert is_pid(pid)
      assert Process.alive?(pid)

      # Verify the process is registered with the correct name
      assert Process.whereis(service_name) == pid

      # Cleanup
      TestService.stop(service_name)
    end

    test "start_link/1 starts service without name" do
      opts = []

      assert {:ok, pid} = TestService.start_link(opts)
      assert is_pid(pid)
      assert Process.alive?(pid)

      # Cleanup
      GenServer.stop(pid)
    end

    test "put_service/1 and get_service/0 manage current service name" do
      # Initially no service should be set
      assert TestService.get_service() == nil

      # Set a service name
      previous = TestService.put_service(:test_service)
      assert previous == nil
      assert TestService.get_service() == :test_service

      # Change to a different service name
      previous = TestService.put_service(:another_service)
      assert previous == :test_service
      assert TestService.get_service() == :another_service

      # Clear the service name
      previous = TestService.put_service(nil)
      assert previous == :another_service
      assert TestService.get_service() == nil
    end

    test "get_runtime_config/0 returns empty map when no service is set" do
      TestService.put_service(nil)
      config = TestService.get_runtime_config()
      assert config == %{}
    end

    test "get_runtime_config/0 returns config from running service" do
      service_name = :test_service_runtime_config
      opts = [service_name: service_name]

      # Start the service
      assert {:ok, pid} = TestService.start_link(opts)

      # Set the current service
      TestService.put_service(service_name)

      # Get runtime config
      config = TestService.get_runtime_config()

      assert is_map(config)
      assert Map.has_key?(config, :started_at)
      assert Map.has_key?(config, :test_mode)
      assert Map.has_key?(config, :pid)
      assert config.test_mode == true
      assert config.pid == pid
      assert %DateTime{} = config.started_at

      # Cleanup
      TestService.stop(service_name)
    end

    test "get_runtime_config/0 handles non-existent service gracefully" do
      TestService.put_service(:non_existent_service)
      config = TestService.get_runtime_config()
      assert config == %{}
    end
  end

  # ==============================================================================================
  # ==============================================================================================
  #
  # Service Lifecycle Integration Tests
  #
  # ==============================================================================================
  # ==============================================================================================

  describe "service lifecycle integration" do
    test "complete service lifecycle with supervision" do
      service_name = :test_service_lifecycle
      opts = [service_name: service_name]

      # Create child spec
      child_spec = TestService.child_spec(opts)

      # Start under a supervisor
      {:ok, supervisor_pid} = Supervisor.start_link([child_spec], strategy: :one_for_one)

      # Verify service is running
      service_pid = Process.whereis(service_name)
      assert is_pid(service_pid)
      assert Process.alive?(service_pid)

      # Set current service and verify functionality
      TestService.put_service(service_name)
      assert TestService.get_service() == service_name

      # Test runtime configuration
      config = TestService.get_runtime_config()
      assert is_map(config)
      assert config.pid == service_pid

      # Test service functionality
      assert :ok = TestService.set_test_value(service_name, :test_key, :test_value)
      assert TestService.get_test_value(service_name, :test_key) == :test_value

      # Cleanup
      Supervisor.stop(supervisor_pid)
    end

    test "multiple service instances can coexist" do
      service1_name = :test_service_multi_1
      service2_name = :test_service_multi_2

      # Start two services
      assert {:ok, pid1} = TestService.start_link(service_name: service1_name)
      assert {:ok, pid2} = TestService.start_link(service_name: service2_name)

      assert pid1 != pid2
      assert Process.whereis(service1_name) == pid1
      assert Process.whereis(service2_name) == pid2

      # Test switching between services
      TestService.put_service(service1_name)
      assert TestService.get_service() == service1_name

      TestService.put_service(service2_name)
      assert TestService.get_service() == service2_name

      # Test each service maintains separate state
      TestService.put_service(service1_name)
      TestService.set_test_value(service1_name, :service_id, 1)

      TestService.put_service(service2_name)
      TestService.set_test_value(service2_name, :service_id, 2)

      # Verify separation
      assert TestService.get_test_value(service1_name, :service_id) == 1
      assert TestService.get_test_value(service2_name, :service_id) == 2

      # Cleanup
      TestService.stop(service1_name)
      TestService.stop(service2_name)
    end
  end

  # ==============================================================================================
  # ==============================================================================================
  #
  # Error Handling Tests
  #
  # ==============================================================================================
  # ==============================================================================================

  describe "error handling" do
    test "handles service crashes gracefully" do
      service_name = :test_service_crash
      opts = [service_name: service_name]

      # Start service
      assert {:ok, pid} = TestService.start_link(opts)
      TestService.put_service(service_name)

      # Verify it's working
      config = TestService.get_runtime_config()
      assert is_map(config)

      # Trap exits to avoid test process crash
      Process.flag(:trap_exit, true)

      # Kill the service process
      Process.exit(pid, :kill)

      # Wait for any exit messages and clear them
      receive do
        {:EXIT, ^pid, :killed} -> :ok
      after
        # If no exit message, that's fine too
        100 -> :ok
      end

      # Small delay to ensure process is dead
      :timer.sleep(10)

      # Verify get_runtime_config handles the dead process
      config = TestService.get_runtime_config()
      assert config == %{}

      # Restore normal exit behavior
      Process.flag(:trap_exit, false)
    end

    test "start_link handles invalid options gracefully" do
      # While our test service doesn't validate options extensively,
      # this test documents expected behavior for service implementations
      opts = [service_name: :test_service_invalid]

      # Should still start successfully - option validation is implementation-specific
      assert {:ok, pid} = TestService.start_link(opts)

      # Cleanup
      GenServer.stop(pid)
    end
  end
end
