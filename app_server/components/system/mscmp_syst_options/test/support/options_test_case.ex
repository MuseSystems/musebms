# Source File: options_test_case.ex
# Location:    musebms/app_server/components/system/mscmp_syst_options/test/support/options_test_case.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule OptionsTestCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  setup do
    [
      # Default options file used across tests
      default_options_path: "testing_options.toml"
    ]
  end
end
