# Source File: test_helper.exs
# Location:    musebms/app_server/components/system/mscmp_syst_options/test/test_helper.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

# Load test support files
Code.require_file("support/options_test_case.ex", __DIR__)

_test_kind =
  if ExUnit.configuration() |> Keyword.get(:include) |> Enum.member?(:integration) do
    ExUnit.configure(seed: 0)
    :integration_testing
  else
    ExUnit.configure(exclude: [:integration])
    :unit_testing
  end

ExUnit.start()
