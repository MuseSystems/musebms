# Source File: impl_msbms_error_test.exs
# Location:    musebms/components/system/msbms_syst_error/test/impl_msbms_error_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystError.ImplMsbmsErrorTest do
  use ExUnit.Case

  alias MsbmsSystError.Impl.MsbmsError

  test "Get root cause from error data" do
    test_err = %MsbmsSystError{
      code: :example_error,
      message: "Outer error message",
      cause: %MsbmsSystError{
        code: :example_error,
        message: "Intermediate error message",
        cause: %MsbmsSystError{
          code: :example_error,
          message: "Root error message",
          cause: {:error, "Example Error"}
        }
      }
    }

    root_err = MsbmsError.get_root_cause(test_err)

    assert %MsbmsSystError{message: "Root error message"} = root_err

    assert {:error, "test error"} = MsbmsError.get_root_cause({:error, "test error"})
  end
end
