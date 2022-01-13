
# Source File: error.ex
# Location:    musebms/lib/msbms/system/types/error.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule Msbms.System.Types.Error do
  @type msbms_error() :: %__MODULE__{code: atom(), description: binary()}
  defstruct code: :S0X01, description: "Error not found"

  @spec get_error({:msbms_error, atom()}) :: msbms_error()
  def get_error({:error, msbms_error_code}) do
    get_error(msbms_error_code)
  end

  @spec get_error(atom()) :: msbms_error()
  def get_error(error_code) do
    Enum.filter(get_errors_list(), fn {curr_code, _} -> curr_code == error_code end)
    |> List.first(%Msbms.System.Types.Error{})
  end

  #
  # Error code formatting should be compatible with the database error codes; these are ISO SQL
  # Standard error codes. The basic rules are:
  #     1) The code will be in format -> MMCEE
  #     2) MM identifies the application module/area where the error originated and starts with any
  #        number from 5 to 9 or any letter I to Z
  #     3) C identifies the subject/topic/sub-module and starts with any number from
  #        5 to 9 or any letter I to Z
  #     4) EE identifies the specific error in the Module/Topic being raised and may be any
  #        alpha-numeric code
  #     5) All alphas should be upper case to match the database.
  # Note that standard PostgreSQL error codes may appear here to get the benefit of our application
  # specific error descriptions.  Formatting based on the advice at:
  # https://dba.stackexchange.com/questions/258328/custom-error-code-class-and-numbers-for-postgres-stored-functions/258336#258336
  #

  @spec get_errors_list :: [msbms_error()]
  def get_errors_list do
    [
      # System Module Error Codes (S), Database Repo Topic (R)
      %Msbms.System.Types.Error{code: :S0R01, description: "Startup otions file could not be read"},
      %Msbms.System.Types.Error{code: :S0R02, description: "Startup otions file could not be parsed"},
      %Msbms.System.Types.Error{code: :S0R10, description: "System Database not found"},
      %Msbms.System.Types.Error{code: :S0R11, description: "System Database not initialized"},
      %Msbms.System.Types.Error{code: :S0R20, description: "Instance Database not found"},
      %Msbms.System.Types.Error{code: :S0R21, description: "Instance Database not initialized"},
    ]
  end
end
