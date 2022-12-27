# Source File: mscmp_error.ex
# Location:    musebms/components/system/mscmp_syst_error/lib/impl/mscmp_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystError.Impl.MscmpError do
  @moduledoc false

  @spec get_root_cause(any()) :: any()
  def get_root_cause(%MscmpSystError{cause: next_error = %MscmpSystError{}}) do
    next_error
    |> get_root_cause()
  end

  def get_root_cause(last_error), do: last_error
end
