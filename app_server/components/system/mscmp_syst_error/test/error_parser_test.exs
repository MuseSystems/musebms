# Source File: error_parser_test.exs
# Location:    musebms/components/system/mscmp_syst_error/test/error_parser_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule ErrorParserTest do
  @moduledoc false
  use ExUnit.Case

  alias MscmpSystError.Impl

  @moduletag :unit
  @moduletag :capture_log

  test "Get root cause from error data" do
    test_err = %ExampleError{
      kind: :example_error,
      message: "Outer error message",
      cause: %ExampleError{
        kind: :example_error,
        message: "Intermediate error message",
        cause: %ExampleError{
          kind: :example_error,
          message: "Root error message",
          cause: {:error, "Example Error"}
        }
      }
    }

    root_err = Impl.ErrorParser.get_root_cause(test_err)

    assert %ExampleError{
             kind: :example_error,
             message: "Root error message",
             cause: {:error, "Example Error"}
           } = root_err

    assert {:error, "test error"} = Impl.ErrorParser.get_root_cause({:error, "test error"})
  end

  test "get_root_cause/1 returns the root cause of nested errors" do
    error_source = {:error, "Error source"}
    root_cause = TestError.new(:test_error, "Inner error", cause: error_source)
    middle_error = TestError.new(:test_error, "Middle error", cause: root_cause)
    outer_error = TestError.new(:test_error, "Outer error", cause: middle_error)

    assert Impl.ErrorParser.get_root_cause(outer_error) == root_cause
  end

  test "get_root_cause/1 returns the error itself when there's no nested cause" do
    error = TestError.new(:test_error, "Single error")
    assert Impl.ErrorParser.get_root_cause(error) == error
  end

  test "get_root_cause/1 returns non-MscmpSystError values as-is" do
    assert Impl.ErrorParser.get_root_cause({:error, "Simple tuple"}) == {:error, "Simple tuple"}

    standard_exception = RuntimeError.exception("Standard exception")
    assert Impl.ErrorParser.get_root_cause(standard_exception) == standard_exception

    assert Impl.ErrorParser.get_root_cause("Some random value") == "Some random value"

    assert Impl.ErrorParser.get_root_cause(nil) == nil
  end
end
