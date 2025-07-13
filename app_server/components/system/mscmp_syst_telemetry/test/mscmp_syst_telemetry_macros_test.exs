# Source File: mscmp_syst_telemetry_macros_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_telemetry/test/mscmp_syst_telemetry_macros_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystTelemetryMacrosTest do
  @moduledoc false
  use TelemetryTestCase,
    async: true,
    component: :mscmp_syst_telemetry_test,
    test_module: TelemetryTestModule

  @moduletag :unit
  @moduletag :capture_log

  test "__using__ macro correctly sets up a module" do
    assert hd(TelemetryTestModule.__info__(:attributes)[:component]) == :mscmp_syst_telemetry_test
  end

  describe "api_telemetry/2 macro" do
    test "emits a :telemetry.span event with context" do
      context = %{user_id: 1, account_id: 2}
      assert TelemetryTestModule.instrumented_function(context) == {:ok, "result"}

      assert_receive {:telemetry_event,
                      [
                        :mscmp_syst_telemetry_test,
                        :general,
                        :api_call,
                        :start
                      ], %{system_time: _},
                      %{
                        context: ^context,
                        function: :instrumented_function,
                        arity: 1,
                        module: TelemetryTestModule
                      }}

      assert_receive {:telemetry_event,
                      [
                        :mscmp_syst_telemetry_test,
                        :general,
                        :api_call,
                        :stop
                      ], %{duration: _},
                      %{
                        context: ^context,
                        function: :instrumented_function,
                        arity: 1,
                        module: TelemetryTestModule
                      }}
    end

    test "emits a :telemetry.span event with empty context" do
      assert TelemetryTestModule.instrumented_function_no_context() == {:ok, "no context result"}

      assert_receive {:telemetry_event,
                      [
                        :mscmp_syst_telemetry_test,
                        :general,
                        :api_call,
                        :start
                      ], %{system_time: _},
                      %{
                        context: [],
                        function: :instrumented_function_no_context,
                        arity: 0,
                        module: TelemetryTestModule
                      }}

      assert_receive {:telemetry_event,
                      [
                        :mscmp_syst_telemetry_test,
                        :general,
                        :api_call,
                        :stop
                      ], %{duration: _},
                      %{
                        context: [],
                        function: :instrumented_function_no_context,
                        arity: 0,
                        module: TelemetryTestModule
                      }}
    end
  end

  describe "logging macros" do
    test "log_debug/2 emits a debug event with context" do
      message = "debug message with context"
      context = %{data: "debug"}
      TelemetryTestModule.log_debug_event(message, context)

      assert_receive {:telemetry_event,
                      [
                        :mscmp_syst_telemetry_test,
                        :general,
                        :event_debug
                      ], %{},
                      %{
                        message: ^message,
                        context: ^context,
                        function: :log_debug_event,
                        arity: 2,
                        module: TelemetryTestModule
                      }}
    end

    test "log_info/2 emits an info event with context" do
      message = "info message with context"
      context = %{data: "info"}
      TelemetryTestModule.log_info_event(message, context)

      assert_receive {:telemetry_event,
                      [
                        :mscmp_syst_telemetry_test,
                        :general,
                        :event_info
                      ], %{},
                      %{
                        message: ^message,
                        context: ^context,
                        function: :log_info_event,
                        arity: 2,
                        module: TelemetryTestModule
                      }}
    end

    test "log_warn/2 emits a warn event with context" do
      message = "warn message with context"
      context = %{data: "warn"}
      TelemetryTestModule.log_warn_event(message, context)

      assert_receive {:telemetry_event,
                      [
                        :mscmp_syst_telemetry_test,
                        :general,
                        :event_warn
                      ], %{},
                      %{
                        message: ^message,
                        context: ^context,
                        function: :log_warn_event,
                        arity: 2,
                        module: TelemetryTestModule
                      }}
    end

    test "log_error/2 emits an error event with context" do
      message = "error message with context"
      context = %{data: "error"}
      TelemetryTestModule.log_error_event(message, context)

      assert_receive {:telemetry_event,
                      [
                        :mscmp_syst_telemetry_test,
                        :general,
                        :event_error
                      ], %{},
                      %{
                        message: ^message,
                        context: ^context,
                        function: :log_error_event,
                        arity: 2,
                        module: TelemetryTestModule
                      }}
    end
  end
end
