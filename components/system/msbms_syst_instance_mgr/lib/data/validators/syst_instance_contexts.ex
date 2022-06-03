# Source File: syst_instance_contexts.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/data/validators/syst_instance_contexts.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Data.Validators.SystInstanceContexts do
  import Ecto.Changeset

  @moduledoc false

  @spec validate_context_code(Ecto.Changeset.t(), Keyword.t()) :: Ecto.Changeset.t()
  def validate_context_code(changeset, opts) do
    changeset
    |> validate_required(:context_code)
    |> validate_length(:context_code,
      min: opts[:min_context_code_length],
      max: opts[:max_context_code_length]
    )
  end
end
