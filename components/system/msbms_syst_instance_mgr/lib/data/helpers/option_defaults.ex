# Source File: option_defaults.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/data/helpers/option_defaults.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Data.Helpers.OptionDefaults do
  @moduledoc false

  # Resolve user provided options to a complete set of options by filling gaps
  # with pre-defined defaults.
  #
  # Allows the changeset function to resolve defaults that are used to
  # parameterize other validations.   We do that resolution in the changeset
  # function directly so we're only doing the user/default resolution once for
  # a changeset.
  @spec resolve_options(Keyword.t()) :: Keyword.t()
  def resolve_options(opts_given) do
    opts_default = [
      min_internal_name_length: 6,
      max_internal_name_length: 64,
      min_display_name_length: 6,
      max_display_name_length: 64,
      min_context_code_length: 8,
      max_context_code_length: 64,
      min_instance_code_length: 8,
      max_instance_code_length: 64
    ]

    Keyword.merge(opts_given, opts_default, fn _k, v1, _v2 -> v1 end)
  end
end