# Source File: msbms_syst_error.ex
# Location:    musebms/components/system/msbms_syst_error/lib/msbms_syst_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystError do
  @moduledoc """
  API for working with the MuseBMS error reporting subsystem.

  This module defines a nested structure for reporting errors in contexts where a result should be
  represented by an error result.  By capturing lower level errors and reporting them in a
  standard way, various application errors, especially non-fatal errors, can be handled as
  appropriate and logged for later analysis.

  The basic form of a reportable application error is: `{:error, %MsbmsSystError{}}` where
  `%MsbmsSystError{}` contains basic fields to identify the kind of error, the source of the
  error, and other error related data.

  Functions in this API are used to work with the returned exception.
  """

  alias MsbmsSystError.Impl.MsbmsError
  alias MsbmsSystError.Types

  @typedoc """
  Defines a nestable exception format for reporting MuseBMS application exceptions.

  Fields in the exception are:
    * `code` - classifies the error into a specific kind of exception likely to be seen in
    application.  Useful for pattern matching, logging, and determining if any raised exception
    should be handled or not.

    * `message` - the text description of the error condition.  This should be meaningful to
    humans.

    * `cause` - includes information that may be helpful in understanding the cause of the error
    condition.  This could include nested `t:MsbmsSystError/0` objects, exception data created
    outside of this exception framework, or pertinent data such as parameters and data that is
    directly related to the exception.
  """
  @type t :: %__MODULE__{
          code: Types.msbms_error(),
          message: String.t(),
          cause: any()
        }

  @enforce_keys [:code, :message, :cause]
  defexception code: :undefined_error,
               message: "undefined error",
               cause: nil

  @doc section: :error_parsing
  @doc """
  Returns the root cause of an `MsbmsSystError` exception object.

  The `MsbmsSystError` exception handling framework allows for nested exceptions to be reported
  stack trace style from lower levels of the application where an exception was caused into higher
  levels of the application which enter a failure state due to the lower level root cause.

  This function will traverse the nesting and return the bottom most Error Struct.  If some other
  object, such as a standard error tuple is passed to the function, the function will simply
  return the value.

  ## Examples
      iex> my_err = %MsbmsSystError{
      ...>            code:    :example_error,
      ...>            message: "Outer error message",
      ...>            cause:    %MsbmsSystError{
      ...>                        code:    :example_error,
      ...>                        message: "Intermediate error message",
      ...>                        cause:    %MsbmsSystError{
      ...>                                    code:    :example_error,
      ...>                                    message: "Root error message",
      ...>                                    cause:    {:error, "Example Error"},
      ...>                                  },
      ...>                      },
      ...>          }
      iex> MsbmsSystError.get_root_cause(my_err)
      %MsbmsSystError{
        code:     :example_error,
        message:  "Root error message",
        cause:    {:error, "Example Error"}
      }

      iex> MsbmsSystError.get_root_cause({:error, "Example Error"})
      {:error, "Example Error"}
  """
  @spec get_root_cause(any()) :: any()
  defdelegate get_root_cause(error), to: MsbmsError
end
