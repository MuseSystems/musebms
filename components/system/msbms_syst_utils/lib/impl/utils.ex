# Source File: utils.ex
# Location:    musebms/components/system/msbms_syst_utils/lib/impl/utils.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystUtils.Impl.Utils do
  @moduledoc false

  @spec resolve_options(Keyword.t(), Keyword.t()) :: Keyword.t()
  def resolve_options(opts_given, opts_default) do
    Keyword.merge(opts_given || [], opts_default, fn _k, given, default -> given || default end)
  end
end
