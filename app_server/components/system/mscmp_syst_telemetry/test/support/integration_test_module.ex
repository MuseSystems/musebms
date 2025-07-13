# Source File: integration_test_module.ex
# Location:    musebms/app_server/components/system/mscmp_syst_telemetry/test/support/integration_test_module.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule IntegrationTestModule do
  @moduledoc false
  use MscmpSystTelemetry, component: :mscmp_syst_telemetry_int_test, categories: [:test, :general]

  def run_api_call, do: api_telemetry(:test, [], do: :ok)
  def run_log_call, do: log_info(:test, "Integration test log", [])
end
