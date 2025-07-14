# Source File: integration_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_telemetry/test/integration_test.exs
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

  use TelemetryTestCase,
    async: false,
    component: :mscmp_syst_telemetry_int_test,
    test_module: IntegrationTestModule,
    category: :test

  import ExUnit.CaptureLog

  alias LoggerTestHarness

  @moduletag :integration
  @moduletag :capture_log

  # ==============================================================================================
  #
  # Topic 1: Telemetry Event Emission
  #
  # ==============================================================================================

  test "Step 1.01: The telemetry macros emit events which are captured by the test process" do
    IntegrationTestModule.run_api_call()
    IntegrationTestModule.run_log_call()

    assert_receive {:telemetry_event,
                    [
                      :mscmp_syst_telemetry_int_test,
                      :test,
                      :api_call,
                      :start
                    ], _, _}

    assert_receive {:telemetry_event,
                    [
                      :mscmp_syst_telemetry_int_test,
                      :test,
                      :api_call,
                      :stop
                    ], _, _}

    assert_receive {:telemetry_event, [:mscmp_syst_telemetry_int_test, :test, :log_info], _, _}
  end

  # ==============================================================================================
  #
  # Topic 2: Logger Handler Functionality
  #
  # ==============================================================================================

  describe "Logger handler" do
    import ExUnit.CaptureLog

    setup do
      handler_id = {MscmpSystTelemetry, :mscmp_syst_telemetry_int_test, self()}

      # Attach a single handler for both log_info and api_call_stop events
      :ok =
        MscmpSystTelemetry.attach_logger_handler(
          handler_id,
          :mscmp_syst_telemetry_int_test,
          [:test],
          [:log_info, :api_call_stop]
        )

      on_exit(fn ->
        MscmpSystTelemetry.detach_logger_handler(handler_id)
      end)

      {:ok, handler_id: handler_id}
    end

    test "Step 2.01: When attached, the logger handler logs telemetry events" do
      log =
        capture_log(fn ->
          IntegrationTestModule.run_log_call()
          IntegrationTestModule.run_api_call()
          # Add a small delay to allow the async logger to process the events.
          Process.sleep(50)
        end)

      assert log =~ "Integration test log"

      assert log =~
               "Telemetry Event: [:mscmp_syst_telemetry_int_test, :test, :api_call, :stop]"
    end

    test "Step 2.02: After being detached, the logger handler no longer logs telemetry events", %{
      handler_id: handler_id
    } do
      # The handler is attached by the setup block. We first detach it.
      :ok = MscmpSystTelemetry.detach_logger_handler(handler_id)

      log =
        capture_log(fn ->
          IntegrationTestModule.run_log_call()
          IntegrationTestModule.run_api_call()
          # Add a small delay to ensure we don't capture any stray logs.
          Process.sleep(50)
        end)

      assert log == ""
    end
  end

  # ==============================================================================================
  #
  # Topic 3: Event Generation Integration
  #
  # ==============================================================================================

  describe "Event Generation Integration" do
    test "Step 3.01: generate_events/3 produces events that can be used for handler attachment" do
      # Generate events using the public API
      {:ok, events} =
        MscmpSystTelemetry.generate_events(
          :mscmp_syst_telemetry_int_test,
          [:test],
          [:log_info, :api_call_stop]
        )

      # Verify the events are in the expected format
      expected_events = [
        [:mscmp_syst_telemetry_int_test, :test, :log_info],
        [:mscmp_syst_telemetry_int_test, :test, :api_call, :stop]
      ]

      assert events == expected_events

      # Use the generated events to manually attach a handler (demonstrating integration)
      handler_id = {__MODULE__, :manual_attachment, self()}

      assert :telemetry.attach_many(
               handler_id,
               events,
               &handle_manual_event/4,
               nil
             ) == :ok

      # Clean up
      :telemetry.detach(handler_id)
    end

    test "Step 3.02: Event generation integrates with logger handler attachment workflow" do
      # This test demonstrates the end-to-end process:
      # 1. Generate events through public API
      # 2. Use those events in handler attachment
      # 3. Verify the handler receives the expected events

      handler_id = {__MODULE__, :integration_test, self()}

      # Step 1: Use the public API for handler attachment (which uses generate_events internally)
      :ok =
        MscmpSystTelemetry.attach_logger_handler(
          handler_id,
          :mscmp_syst_telemetry_int_test,
          [:test],
          [:log_info]
        )

      # Step 2: Verify events are properly generated and attached by triggering an event
      log =
        capture_log(fn ->
          IntegrationTestModule.run_log_call()
          Process.sleep(10)
        end)

      # Step 3: Verify the integration worked end-to-end
      assert log =~ "Integration test log"

      # Clean up
      :ok = MscmpSystTelemetry.detach_logger_handler(handler_id)
    end

    test "Step 3.03: Multiple event kinds integration with single handler attachment" do
      # This test shows how generate_events supports complex handler scenarios
      # where one handler listens to multiple event types

      handler_id = {__MODULE__, :multi_event_test, self()}

      # Attach handler for multiple event kinds using the public API
      :ok =
        MscmpSystTelemetry.attach_logger_handler(
          handler_id,
          :mscmp_syst_telemetry_int_test,
          [:test],
          [:log_info, :api_call_stop]
        )

      # Trigger both types of events and verify they're both handled
      log =
        capture_log(fn ->
          # Triggers log_info event
          IntegrationTestModule.run_log_call()
          # Triggers api_call start/stop events
          IntegrationTestModule.run_api_call()
          Process.sleep(50)
        end)

      # Verify both event types were logged
      assert log =~ "Integration test log"
      assert log =~ "Telemetry Event: [:mscmp_syst_telemetry_int_test, :test, :api_call, :stop]"

      # Clean up
      :ok = MscmpSystTelemetry.detach_logger_handler(handler_id)
    end
  end

  # Helper function for manual event handling in integration tests
  defp handle_manual_event(_event_name, _measurements, _metadata, _config) do
    # Simple handler for testing purposes
    :ok
  end

  # The handle_telemetry_event/4 function is injected by TelemetryTestCase
end
