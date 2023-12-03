# Source File: integration_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_error/test/integration_test.exs
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
  use ExUnit.Case, async: false

  @moduletag :integration
  @moduletag :capture_log

  test "Get root cause from error data" do
    test_err = %MscmpSystError{
      code: :example_error,
      message: "Outer error message",
      cause: %MscmpSystError{
        code: :example_error,
        message: "Intermediate error message",
        cause: %MscmpSystError{
          code: :example_error,
          message: "Root error message",
          cause: {:error, "Example Error"}
        }
      }
    }

    root_err = MscmpSystError.get_root_cause(test_err)

    assert %MscmpSystError{message: "Root error message"} = root_err

    assert {:error, "test error"} = MscmpSystError.get_root_cause({:error, "test error"})
  end
end
