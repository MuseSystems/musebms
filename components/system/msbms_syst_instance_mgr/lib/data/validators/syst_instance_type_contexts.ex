# Source File: syst_instance_type_contexts.ex
# Location:    musebms/components/system/msbms_syst_instance_mgr/lib/data/validators/syst_instance_type_contexts.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystInstanceMgr.Data.Validators.SystInstanceTypeContexts do
  import Ecto.Changeset

  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Types

  @moduledoc false

  @spec insert_changeset(Types.instance_type_context_params()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params) do
    %Data.SystInstanceTypeContexts{}
    |> cast(insert_params, [
      :instance_type_application_id,
      :application_context_id,
      :default_db_pool_size
    ])
    |> validate_required([
      :instance_type_application_id,
      :application_context_id,
      :default_db_pool_size
    ])
  end

  @spec update_changeset(Data.SystInstanceTypeContexts.t(), Types.instance_type_context_params()) ::
          Ecto.Changeset.t()
  def update_changeset(instance_type_context, update_params) do
    instance_type_context
    |> cast(update_params, [
      :default_db_pool_size
    ])
    |> validate_required([
      :instance_type_application_id,
      :application_context_id,
      :default_db_pool_size
    ])
    |> optimistic_lock(:diag_row_version)
  end
end
