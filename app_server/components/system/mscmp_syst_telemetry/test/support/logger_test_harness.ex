# Source File: logger_test_harness.ex
# Location:    musebms/app_server/components/system/mscmp_syst_telemetry/test/support/logger_test_harness.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule LoggerTestHarness do
  @moduledoc """
  Provides functionality to test the `MscmpSystTelemetry` logger handler.

  This module allows attaching a test-specific handler that captures log-like
  messages and sends them to the test process for assertion, avoiding conflicts
  with `ExUnit.CaptureLog`.
  """

  @handler_id __MODULE__

  def setup_harness(log_opts) do
    # Convert the log options into a list of telemetry event suffixes.
    events = build_event_list(log_opts)

    # Attach the test handler for the specified events.
    :telemetry.attach_many(@handler_id, events, &handle_telemetry_event/4, self())
  end

  def teardown_harness(_log_opts) do
    # Detach the test handler.
    :telemetry.detach(@handler_id)
  end

  # Private helper to build the event list from options.
  defp build_event_list(opts) do
    log_events =
      (opts[:log] || [])
      |> Enum.map(fn level -> [:_, :_, String.to_atom("event_#{level}")] end)

    api_events =
      if opts[:api_calls] do
        [[:_, :_, :api_call, :stop]]
      else
        []
      end

    log_events ++ api_events
  end

  # The handler function that sends captured events to the test process.
  @spec handle_telemetry_event(
          :telemetry.event_name(),
          :telemetry.event_measurements(),
          :telemetry.event_metadata(),
          pid()
        ) :: term()
  def handle_telemetry_event(event, _measurements, metadata, pid) do
    send(pid, {:logger_harness_event, event, metadata})
  end
end
