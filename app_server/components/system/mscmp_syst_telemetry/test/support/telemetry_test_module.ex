# Source File: telemetry_test_module.ex
# Location:    musebms/app_server/components/system/mscmp_syst_telemetry/test/support/telemetry_test_module.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule TelemetryTestModule do
  @moduledoc false
  use MscmpSystTelemetry, component: :mscmp_syst_telemetry_test, categories: [:general]

  def instrumented_function(context) do
    api_telemetry :general, context do
      # Simulate some work
      :timer.sleep(10)
      {:ok, "result"}
    end
  end

  def instrumented_function_no_context do
    api_telemetry :general, [] do
      {:ok, "no context result"}
    end
  end

  def log_debug_event(message, context), do: log_debug(:general, message, context)

  def log_info_event(message, context), do: log_info(:general, message, context)

  def log_warn_event(message, context), do: log_warn(:general, message, context)

  def log_error_event(message, context), do: log_error(:general, message, context)
end
