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
  analaysis.

  The basic form of a reportable application error is: {:error, %MsbmsSystError.Impl.MsbmsError{}}
  where %MsbmsSystError.Impl.MsbmsError{} contains basic fields to identify the kind of error, the
  source of the error.  Functions in this API are used to work with the returned struct.

  Error code formatting should be compatible with database returned error codes; these are ISO SQL
  Standard error codes. The basic rules are:
      1) The code will be in format -> MMCEE
      2) MM identifies the application module/area where the error originated and starts with any
         number from 5 to 9 or any letter I to Z
      3) C identifies the subject/topic/sub-module and starts with any number from
         5 to 9 or any letter I to Z
      4) EE identifies the specific error in the Module/Topic being raised and may be any
         alpha-numeric code
      5) All alphas should be upper case to match the database.
  Note that standard PostgreSQL error codes may appear here to get the benefit of our application
  specific error descriptions.  Formatting based on the advice at:
  https://dba.stackexchange.com/questions/258328/custom-error-code-class-and-numbers-for-postgres-stored-functions/258336#258336
  """
  alias MsbmsSystError.Impl.MsbmsError

  @doc """
  For a given error code atom, returns the corresponding user displayable description.

  ## Examples
      iex> MsbmsSystError.get_error_code_description(:S0X02)
      "Error description example."

  Note that the descriptions are returned translated into the appropriate locale.
  """
  @spec get_error_code_description(atom()) :: String.t()
  defdelegate get_error_code_description(error_code), to: MsbmsError

  @doc """
  The %MsbmsSystError.Impl.MsbmsError{} struct (the Error Struct) may rerpesent arbitrarily nested
  Error Structs in the  `cause:` attribute of the Error Struct. This function will traverse the
  nesting and return the bottom most Error Struct.  If some other object, such as a standard error
  tuple is passed to the function, the function will simply return the value.

  ## Examples
      iex> my_err = %MsbmsSystError.Impl.MsbmsError{
      ...>            code:     :S0X02,
      ...>            tech_msg: "Outer error message",
      ...>            module:   MsbmsSystError,
      ...>            function: :get_root_cause,
      ...>            cause:    %MsbmsSystError.Impl.MsbmsError{
      ...>                        code:     :S0X02,
      ...>                        tech_msg: "Intermediate error message",
      ...>                        module:   MsbmsSystError,
      ...>                        function: :get_root_cause,
      ...>                        cause:    %MsbmsSystError.Impl.MsbmsError{
      ...>                                    code:     :S0X02,
      ...>                                    tech_msg: "Root error message",
      ...>                                    module:   MsbmsSystError,
      ...>                                    function: :get_root_cause,
      ...>                                    cause:    {:error, "Example Error"},
      ...>                                  },
      ...>                      },
      ...>          }
      iex> MsbmsSystError.get_root_cause(my_err)
      %MsbmsSystError.Impl.MsbmsError{
        code:     :S0X02,
        tech_msg: "Root error message",
        module:   MsbmsSystError,
        function: :get_root_cause,
        cause:    {:error, "Example Error"},
      }

      iex> MsbmsSystError.get_root_cause({:error, "Example Error"})
      {:error, "Example Error"}
  """
  @spec get_root_cause(any()) :: any()
  defdelegate get_root_cause(error), to: MsbmsError
end
