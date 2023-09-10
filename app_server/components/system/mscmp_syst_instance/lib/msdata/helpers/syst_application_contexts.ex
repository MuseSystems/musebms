# Source File: syst_application_contexts.ex
# Location:    musebms/components/system/mscmp_syst_instance/lib/msdata/helpers/syst_application_contexts.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Msdata.Helpers.SystApplicationContexts do
  @moduledoc false

  import Ecto.Query

  # Currently the operation parameter has no real use and is maintained here for
  # consistency with helper functions found elsewhere in the code base.  We'll
  # go ahead and ensure that the only operation expected (:insert) is checked
  # just as an extra check on correct usage.

  def resolve_name_params(application_context_params, :insert = _operation),
    do: resolve_application_id(application_context_params)

  def resolve_application_id(%{application_name: application_name} = application_context_params)
      when is_binary(application_name) do
    from(a in Msdata.SystApplications, where: a.internal_name == ^application_name, select: a.id)
    |> MscmpSystDb.one!()
    |> then(&Map.put(application_context_params, :application_id, &1))
  end

  def resolve_application_id(application_context_params), do: application_context_params
end
