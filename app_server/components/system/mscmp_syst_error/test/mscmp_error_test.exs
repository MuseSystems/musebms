# Source File: mscmp_error_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_error/test/mscmp_error_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystError.MscmpErrorTest do
  use ExUnit.Case, async: true

  alias MscmpSystError.Impl.MscmpError

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

    root_err = MscmpError.get_root_cause(test_err)

    assert %MscmpSystError{message: "Root error message"} = root_err

    assert {:error, "test error"} = MscmpError.get_root_cause({:error, "test error"})
  end
end
