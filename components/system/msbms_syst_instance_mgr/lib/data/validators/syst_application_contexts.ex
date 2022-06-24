# Source File: syst_application_contexts.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/data/validators/syst_application_contexts.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Data.Validators.SystApplicationContexts do
  import Ecto.Changeset

  alias MsbmsSystInstanceMgr.Data

  @spec update_changeset(Data.SystApplicationContexts.t(), boolean()) :: Ecto.Changeset.t()
  def update_changeset(application_context, start_context) when is_boolean(start_context) do
    application_context
    |> cast(%{start_context: start_context}, [:start_context])
    |> validate_required([:start_context])
    |> optimistic_lock(:diag_row_version)
  end
end
