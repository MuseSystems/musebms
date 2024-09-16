# Source File: mscmp_syst_error.ex
# Location:    musebms/app_server/components/system/mscmp_syst_error/lib/api/mscmp_syst_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystError do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias MscmpSystError.Impl.MscmpError
  alias MscmpSystError.Types

  @enforce_keys [:code, :message, :cause]
  defexception code: :undefined_error,
               message: "undefined error",
               cause: nil

  @typedoc """
  Defines a nestable exception format for reporting MuseBMS application exceptions.

  Fields in the exception are:
    * `code` - classifies the error into a specific kind of exception likely to be seen in
    application.  Useful for pattern matching, logging, and determining if any raised exception
    should be handled or not.

    * `message` - the text description of the error condition.  This should be meaningful to
    humans.

    * `cause` - includes information that may be helpful in understanding the cause of the error
    condition.  This could include nested `t:MscmpSystError/0` objects, exception data created
    outside of this exception framework, or pertinent data such as parameters and data that is
    directly related to the exception.
  """
  @type t :: %__MODULE__{
          code: Types.mscmp_error(),
          message: String.t(),
          cause: any()
        }

  ##############################################################################
  #
  # get_root_cause
  #
  #

  @doc section: :error_parsing
  @doc """
  Returns the root cause of an `MscmpSystError` exception object.

  The `MscmpSystError` exception handling framework allows for nested exceptions to be reported
  stack trace style from lower levels of the application where an exception was caused into higher
  levels of the application which enter a failure state due to the lower level root cause.

  This function will traverse the nesting and return the bottom most Error Struct.  If some other
  object, such as a standard error tuple is passed to the function, the function will simply
  return the value.

  ## Examples
      iex> my_err = %MscmpSystError{
      ...>            code:    :example_error,
      ...>            message: "Outer error message",
      ...>            cause:    %MscmpSystError{
      ...>                        code:    :example_error,
      ...>                        message: "Intermediate error message",
      ...>                        cause:    %MscmpSystError{
      ...>                                    code:    :example_error,
      ...>                                    message: "Root error message",
      ...>                                    cause:    {:error, "Example Error"},
      ...>                                  },
      ...>                      },
      ...>          }
      iex> MscmpSystError.get_root_cause(my_err)
      %MscmpSystError{
        code:     :example_error,
        message:  "Root error message",
        cause:    {:error, "Example Error"}
      }

      iex> MscmpSystError.get_root_cause({:error, "Example Error"})
      {:error, "Example Error"}
  """
  @spec get_root_cause(any()) :: any()
  defdelegate get_root_cause(error), to: MscmpError
end
