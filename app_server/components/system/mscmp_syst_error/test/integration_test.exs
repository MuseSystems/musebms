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
  @moduledoc false

  use ExUnit.Case

  alias MscmpSystError

  @moduletag :integration
  @moduletag :capture_log

  test "default implementation of new/2 function" do
    error = TestError.new(:test_error, "Test error message")
    assert %TestError{} = error
    assert error.__mserror__ == true
    assert error.__mscomponent__ == TestError
    assert error.kind == :test_error
    assert error.message == "Test error message"
    assert error.context == nil
    assert error.cause == nil
  end

  test "default implementation of new/3 function with additional options" do
    context = %MscmpSystError.Types.Context{
      parameters: %{param1: "value1"},
      origin: {TestError, :some_function, 2},
      supporting_data: "Additional info"
    }

    cause = RuntimeError.exception("Cause error")

    error_with_opts =
      TestError.new(:test_error, "Test error with options", context: context, cause: cause)

    assert %TestError{} = error_with_opts
    assert error_with_opts.__mserror__ == true
    assert error_with_opts.__mscomponent__ == TestError
    assert error_with_opts.kind == :test_error
    assert error_with_opts.message == "Test error with options"
    assert error_with_opts.context == context
    assert error_with_opts.cause == cause
  end

  test "new/2 function with invalid kind" do
    assert_raise FunctionClauseError, fn ->
      TestError.new(:invalid_kind, "Invalid error")
    end
  end

  test "get_root_cause/1 returns the root cause of nested errors" do
    error_source = {:error, "Error source"}
    root_cause = TestError.new(:test_error, "Inner error", cause: error_source)
    middle_error = TestError.new(:test_error, "Middle error", cause: root_cause)
    outer_error = TestError.new(:test_error, "Outer error", cause: middle_error)

    assert MscmpSystError.get_root_cause(outer_error) == root_cause
  end

  test "get_root_cause/1 returns the error itself when there's no nested cause" do
    error = TestError.new(:test_error, "Single error")
    assert MscmpSystError.get_root_cause(error) == error
  end

  test "get_root_cause/1 returns non-MscmpSystError values as-is" do
    assert MscmpSystError.get_root_cause({:error, "Simple tuple"}) == {:error, "Simple tuple"}

    standard_exception = RuntimeError.exception("Standard exception")
    assert MscmpSystError.get_root_cause(standard_exception) == standard_exception

    assert MscmpSystError.get_root_cause("Some random value") == "Some random value"

    assert MscmpSystError.get_root_cause(nil) == nil
  end
end
