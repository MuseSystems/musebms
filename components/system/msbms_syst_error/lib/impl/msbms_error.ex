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

  @moduledoc false

  @spec get_root_cause(any()) :: any()
  def get_root_cause(%MsbmsSystError{cause: next_error = %MsbmsSystError{}}) do
     next_error
     |> get_root_cause()
  end

  def get_root_cause(last_error), do: last_error

end
