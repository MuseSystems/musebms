# Source File: msbms_error.ex
# Location:    components/system/msbms_syst_error/lib/impl/msbms_error.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystError.Impl.MsbmsError do

  import MsbmsSystError.Impl.Gettext

  @moduledoc false

  @type t :: %__MODULE__{
    code:     atom(),
    tech_msg: String.t(),
    module:   atom(),
    function: atom(),
    cause:    any(),
  }

  defstruct code:     :S0X01,
            tech_msg: "undefined error",
            module:   nil,
            function: nil,
            cause:    nil

  @spec get_errors_list :: Keyword.t()
  def get_errors_list do
    [
      # System Module Error Codes (S), No topic, special cases (X)
      S0X01: gettext("Unknown error."),
      S0X02: gettext("Error description example."),

      # System Module Error Codes (S), Datastore Topic (S)
      S0S01: gettext("Startup options file could not be read."),
      S0S02: gettext("Startup options file could not be parsed."),
      S0S10: gettext("Global database name not found."),
      S0S11: gettext("Global database not found."),
      S0S12: gettext("Global database not initialized."),
      S0S20: gettext("Instance database not found."),
      S0S21: gettext("Instance database not initialized."),
    ]
  end

  @spec get_error_code_description(atom()) :: String.t()
  def get_error_code_description(error_code) when is_atom(error_code) do
    get_errors_list()
    |> Keyword.get(error_code)
  end

  @spec get_root_cause(any) :: any
  def get_root_cause(%__MODULE__{cause: next_error = %__MODULE__{}}), do: next_error |> get_root_cause()
  def get_root_cause(last_error), do: last_error

end
