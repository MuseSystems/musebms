# Source File: logger_handler_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_telemetry/test/logger_handler_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule LoggerHandlerTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias MscmpSystTelemetry.Impl.Handlers.Logger, as: LoggerHandler

  @moduletag :unit
  @moduletag :capture_log

  describe "handle_event/4" do
    test "correctly logs a :debug event" do
      message = "Test debug message"
      context = %{some: :data}

      log =
        capture_log(fn ->
          LoggerHandler.handle_event(
            [:my_component, :my_category, :event_debug],
            %{},
            %{function: :my_func, arity: 1, context: context, message: message, module: MyModule},
            nil
          )
        end)

      assert log =~ "[debug]"
      assert log =~ message
      assert log =~ "component=my_component"
      assert log =~ "category=my_category"
      assert log =~ "module=MyModule"
      assert log =~ "function=my_func"
      assert log =~ "arity=1"
      assert log =~ "context=#{inspect(context)}"
    end

    test "correctly logs an :info event" do
      message = "Test info message"
      context = %{some: :data}

      log =
        capture_log(fn ->
          LoggerHandler.handle_event(
            [:my_component, :my_category, :event_info],
            %{},
            %{function: :my_func, arity: 1, context: context, message: message, module: MyModule},
            nil
          )
        end)

      assert log =~ "[info]"
      assert log =~ message
      assert log =~ "component=my_component"
      assert log =~ "category=my_category"
      assert log =~ "module=MyModule"
      assert log =~ "function=my_func"
      assert log =~ "arity=1"
      assert log =~ "context=#{inspect(context)}"
    end

    test "correctly logs a :warn event" do
      message = "Test warn message"
      context = %{some: :data}

      log =
        capture_log(fn ->
          LoggerHandler.handle_event(
            [:my_component, :my_category, :event_warn],
            %{},
            %{function: :my_func, arity: 1, context: context, message: message, module: MyModule},
            nil
          )
        end)

      assert log =~ "[warning]"
      assert log =~ message
      assert log =~ "component=my_component"
      assert log =~ "category=my_category"
      assert log =~ "module=MyModule"
      assert log =~ "function=my_func"
      assert log =~ "arity=1"
      assert log =~ "context=#{inspect(context)}"
    end

    test "correctly logs an :error event" do
      message = "Test error message"
      context = %{some: :data}

      log =
        capture_log(fn ->
          LoggerHandler.handle_event(
            [:my_component, :my_category, :event_error],
            %{},
            %{function: :my_func, arity: 1, context: context, message: message, module: MyModule},
            nil
          )
        end)

      assert log =~ "[error]"
      assert log =~ message
      assert log =~ "component=my_component"
      assert log =~ "category=my_category"
      assert log =~ "module=MyModule"
      assert log =~ "function=my_func"
      assert log =~ "arity=1"
      assert log =~ "context=#{inspect(context)}"
    end

    test "correctly logs an :api_call, :stop event" do
      context = %{some: :data}
      duration = 12_345

      log =
        capture_log(fn ->
          LoggerHandler.handle_event(
            [:my_component, :my_category, :api_call, :stop],
            %{duration: duration},
            %{
              function: :my_api_func,
              arity: 2,
              context: context,
              module: MyModule
            },
            nil
          )
        end)

      duration_us = System.convert_time_unit(duration, :native, :microsecond)
      assert log =~ "[info]"

      assert log =~ "Telemetry Event: [:my_component, :my_category, :api_call, :stop]"

      assert log =~ "component=my_component"
      assert log =~ "category=my_category"
      assert log =~ "module=MyModule"
      assert log =~ "function=my_api_func"
      assert log =~ "arity=2"
      assert log =~ "context=#{inspect(context)}"
      assert log =~ "duration_us=#{duration_us}"
    end

    test "ignores unknown events" do
      assert LoggerHandler.handle_event([:unknown], %{}, %{}, nil) == :ok
    end
  end

  describe "attach_logger_handler/1 and detach_logger_handler/1" do
    setup do
      events = [
        [:mscmp_syst_telemetry, :general, :event_debug],
        [:mscmp_syst_telemetry, :general, :event_info],
        [:mscmp_syst_telemetry, :general, :api_call, :stop]
      ]

      handler_id = LoggerHandler

      on_exit(fn ->
        for event <- events do
          :telemetry.detach({handler_id, event})
        end
      end)

      :ok
    end

    test "attaches and detaches handlers correctly" do
      opts = [
        component: :mscmp_syst_telemetry,
        log: [:debug, :info],
        api_calls: true,
        categories: [:general]
      ]

      handler_id = LoggerHandler

      # Attach
      assert LoggerHandler.attach_logger_handler(opts) == :ok

      # Verify attachment
      debug_handlers = :telemetry.list_handlers([:mscmp_syst_telemetry, :general, :event_debug])
      info_handlers = :telemetry.list_handlers([:mscmp_syst_telemetry, :general, :event_info])
      api_handlers = :telemetry.list_handlers([:mscmp_syst_telemetry, :general, :api_call, :stop])
      warn_handlers = :telemetry.list_handlers([:mscmp_syst_telemetry, :general, :event_warn])

      assert Enum.any?(
               debug_handlers,
               &(&1.id == {handler_id, [:mscmp_syst_telemetry, :general, :event_debug]})
             )

      assert Enum.any?(
               info_handlers,
               &(&1.id == {handler_id, [:mscmp_syst_telemetry, :general, :event_info]})
             )

      assert Enum.any?(
               api_handlers,
               &(&1.id == {handler_id, [:mscmp_syst_telemetry, :general, :api_call, :stop]})
             )

      assert Enum.empty?(warn_handlers)

      # Detach
      assert LoggerHandler.detach_logger_handler(opts) == :ok

      # Verify detachment
      debug_handlers = :telemetry.list_handlers([:mscmp_syst_telemetry, :general, :event_debug])
      info_handlers = :telemetry.list_handlers([:mscmp_syst_telemetry, :general, :event_info])
      api_handlers = :telemetry.list_handlers([:mscmp_syst_telemetry, :general, :api_call, :stop])

      assert Enum.empty?(debug_handlers)
      assert Enum.empty?(info_handlers)
      assert Enum.empty?(api_handlers)
    end
  end
end
