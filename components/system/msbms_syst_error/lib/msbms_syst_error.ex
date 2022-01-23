# Source File: msbms_syst_error.ex
# Location:    components/system/msbms_syst_error/lib/msbms_syst_error.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystError do

  @moduledoc """
  API for working with the MuseBMS error reporting subsystem.

  This module defines a nested structure for reporting errors in contexts where a result type ends
  in an error state.  By capturing lower level errors and reporting them in a standard way, various
  application errors, especially non-fatal errors, can be handled appropriate and logged for later
  analysis.

  The basic form of a reportable application error is: {:error, %MsbmsSystError{}} where
  %MsbmsSystError{} contains basic fields to identify the kind of error, the source of the error.

  Functions in this API are used to work with the returned struct.
  """

  alias MsbmsSystError.Impl.MsbmsError
  alias MsbmsSystError.Types

  @typedoc """
  Defines a nestable exception format for reporting MuseBMS application exceptions.t().

  Fields in the exception are:
    * __code__

      Classifies the error into a specific kind of exception likely to be seen in application.  Useful for pattern matching, logging, and determining if any raised exception should be handled or not.

    * __message__

      The text description of the error condition.  This should be meaningful to humans.

    * __cause__

      This value may be either another %MsbmsSystError{} value representing a more fundamental cause or other metadata helpful in understanding the cause of the error. Values found here, in addition to other %MsbmsSystError{} values, could include maps of function parameters/values or lower level exceptions that originate from included dependencies or libraries like database connection libraries.
  """
  @type t :: %__MODULE__{
    code:     Types.msbms_error(),
    message:  String.t(),
    cause:    any(),
  }

  @enforce_keys [:code, :message, :cause]
  defexception code:    :undefined_error,
               message: "undefined error",
               cause:   nil

  @doc """
  The %MsbmsSystError{} struct (the Error Struct) may represent arbitrarily nested Error Structs in
  the `cause:` attribute of the Error Struct.

  This function will traverse the nesting and return the bottom most Error Struct.  If some other
  object, such as a standard error tuple is passed to the function, the function will simply return
  the value.

  ## Examples
      iex> my_err = %MsbmsSystError{
      ...>            code:    :example_exception,
      ...>            message: "Outer error message",
      ...>            cause:    %MsbmsSystError{
      ...>                        code:    :example_exception,
      ...>                        message: "Intermediate error message",
      ...>                        cause:    %MsbmsSystError{
      ...>                                    code:    :example_exception,
      ...>                                    message: "Root error message",
      ...>                                    cause:    {:error, "Example Error"},
      ...>                                  },
      ...>                      },
      ...>          }
      iex> MsbmsSystError.get_root_cause(my_err)
      %MsbmsSystError{
        code:     :example_exception,
        message:  "Root error message",
        cause:    {:error, "Example Error"}
      }

      iex> MsbmsSystError.get_root_cause({:error, "Example Error"})
      {:error, "Example Error"}
  """
  @spec get_root_cause(any()) :: any()
  defdelegate get_root_cause(error), to: MsbmsError
end
