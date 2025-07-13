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

    assert_receive {:telemetry_event, [:mscmp_syst_telemetry_int_test, :test, :event_info], _, _}
  end

  # ==============================================================================================
  #
  # Topic 2: Logger Handler Functionality
  #
  # ==============================================================================================

  describe "Logger handler" do
    import ExUnit.CaptureLog

    setup do
      :ok =
        MscmpSystTelemetry.attach_logger_handler(
          component: :mscmp_syst_telemetry_int_test,
          log: [:info],
          api_calls: true,
          categories: [:test]
        )

      on_exit(fn ->
        MscmpSystTelemetry.detach_logger_handler(
          component: :mscmp_syst_telemetry_int_test,
          log: [:info],
          api_calls: true,
          categories: [:test]
        )
      end)
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

    test "Step 2.02: After being detached, the logger handler no longer logs telemetry events" do
      # The handler is attached by the setup block. We first detach it.
      :ok =
        MscmpSystTelemetry.detach_logger_handler(
          component: :mscmp_syst_telemetry_int_test,
          log: [:info],
          api_calls: true,
          categories: [:test]
        )

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

  # The handle_telemetry_event/4 function is injected by TelemetryTestCase
end
