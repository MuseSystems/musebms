# Source File: error_parser.ex
# Location:    musebms/components/system/mscmp_syst_error/lib/impl/error_parser.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystError.Impl.ErrorParser do
  @moduledoc false

  @spec get_root_cause(any()) :: any()
  def get_root_cause(%_{mserror: true, cause: %_{mserror: true} = next_error}) do
    next_error
    |> get_root_cause()
  end

  def get_root_cause(last_error), do: last_error
end
