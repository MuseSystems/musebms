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

  describe "basic error creation" do
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

    test "new/2 function with basic message" do
      error = TestError.new(:test_error, "Test error message")

      assert %TestError{} = error
      assert error.message == "Test error message"
      assert error.cause == nil
    end

    test "new/2 function with invalid kind" do
      assert_raise FunctionClauseError, fn ->
        TestError.new(:invalid_kind, "Invalid error")
      end
    end
  end

  describe "error creation with options" do
    test "default implementation with context and cause" do
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

    test "new/3 function with cause option" do
      original_error = RuntimeError.exception("Original error")
      error = TestError.new(:test_error, "Wrapped error", cause: original_error)

      assert %TestError{} = error
      assert error.message == "Wrapped error"
      assert error.cause == original_error
    end

    test "new/3 function with both message and cause" do
      cause_tuple = {:error, "Database connection failed"}
      error = TestError.new(:test_error, "Operation failed", cause: cause_tuple)

      assert %TestError{} = error
      assert error.message == "Operation failed"
      assert error.cause == cause_tuple
    end
  end

  describe "parse_error option handling" do
    test "handles nested error tuples" do
      nested_error = {:error, {:error, "root cause"}}
      error = TestError.new(:test_error, "Default message", parse_error: nested_error)

      assert %TestError{} = error
      assert error.cause == "root cause"
      assert error.message == "Default message"
    end

    test "handles error tuple with code and message" do
      error_with_message = {:error, {:invalid_input, "Invalid parameter provided"}}
      error = TestError.new(:test_error, "Default message", parse_error: error_with_message)

      assert %TestError{} = error
      assert error.cause == :invalid_input
      assert error.message == "Invalid parameter provided"
    end

    test "handles error tuple with only code" do
      error_with_code = {:error, :not_found}
      error = TestError.new(:test_error, "Default message", parse_error: error_with_code)

      assert %TestError{} = error
      assert error.cause == :not_found
      assert error.message == "Default message"
    end

    test "handles simple error tuple" do
      simple_error = {:error, "Something went wrong"}
      error = TestError.new(:test_error, "Default message", parse_error: simple_error)

      assert %TestError{} = error
      assert error.cause == "Something went wrong"
      assert error.message == "Default message"
    end

    test "handles arbitrary term (Exception)" do
      original_exception = RuntimeError.exception("Runtime error occurred")
      error = TestError.new(:test_error, "Default message", parse_error: original_exception)

      assert %TestError{} = error
      assert error.cause == original_exception
      assert error.message == "Default message"
    end
  end

  describe "root cause handling" do
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
end
