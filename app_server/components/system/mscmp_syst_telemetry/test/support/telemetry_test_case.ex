# Source File: telemetry_test_case.ex
# Location:    musebms/app_server/components/system/mscmp_syst_telemetry/test/support/telemetry_test_case.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule TelemetryTestCase do
  @moduledoc """
  A reusable ExUnit Case Template for tests that need to capture and assert
  on telemetry events emitted by the `MscmpSystTelemetry` macros.

  ## Options

    * `:component` (atom, required) - The component name atom used to configure
      the telemetry events.
    * `:test_module` (atom, required) - The name of the test module that will
      be emitting the telemetry events.
    * `:category` (atom, optional) - The category used in telemetry events.
      Defaults to `:general`.

  This template injects a `setup` block that attaches a telemetry handler, a
  helper function to process the events, and an alias to the specified
  `:test_module`.
  """

  use ExUnit.CaseTemplate

  using(opts) do
    # Extract the component and test module from the options provided to `use`
    component = Keyword.fetch!(opts, :component)
    test_module = Keyword.fetch!(opts, :test_module)
    category = Keyword.get(opts, :category, :general)

    quote do
      # Alias the test module for convenience in the tests
      alias unquote(test_module)

      setup do
        handler_id = make_ref()

        # Dynamically build the event names using the provided options
        component_name = unquote(component)
        category_name = unquote(category)

        :telemetry.attach_many(
          handler_id,
          [
            [component_name, category_name, :api_call, :start],
            [component_name, category_name, :api_call, :stop],
            [component_name, category_name, :log_debug],
            [component_name, category_name, :log_info],
            [component_name, category_name, :log_warn],
            [component_name, category_name, :log_error]
          ],
          # The helper function is also injected by this template
          &handle_telemetry_event/4,
          self()
        )

        on_exit(fn ->
          :telemetry.detach(handler_id)
        end)

        :ok
      end

      # This helper function will be injected into the test that uses this case.
      # The typespec is included for clarity.
      @spec handle_telemetry_event(
              :telemetry.event_name(),
              :telemetry.measurements(),
              :telemetry.metadata(),
              pid()
            ) :: term()
      def handle_telemetry_event(event, measurements, metadata, pid) do
        # In the unit tests, we need the full event. In the integration tests,
        # we might only care about the event name. To support both, we'll
        # define a private function in the test itself to transform the event
        # before sending, or just send the part we care about.
        # For simplicity and to support all current tests, we send everything.
        send(pid, {:telemetry_event, event, measurements, metadata})
      end
    end
  end
end
