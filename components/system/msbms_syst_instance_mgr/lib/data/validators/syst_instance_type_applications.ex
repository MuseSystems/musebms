# Source File: syst_instance_type_applications.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/data/validators/syst_instance_type_applications.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Data.Validators.SystInstanceTypeApplications do
  import Ecto.Changeset

  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Types

  @moduledoc false

  @spec insert_changeset(Types.instance_type_application_params()) :: Ecto.Changeset.t()
  def insert_changeset(instance_type_application_params) do
    %Data.SystInstanceTypeApplications{}
    |> cast(instance_type_application_params, [:instance_type_id, :application_id])
    |> validate_required([:instance_type_id, :application_id])
  end
end