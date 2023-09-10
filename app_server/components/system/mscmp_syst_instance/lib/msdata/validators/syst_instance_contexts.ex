# Source File: syst_instance_contexts.ex
# Location:    musebms/components/system/mscmp_syst_instance/lib/msdata/validators/syst_instance_contexts.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Msdata.Validators.SystInstanceContexts do
  @moduledoc false

  import Ecto.Changeset

  alias MscmpSystInstance.Msdata.Helpers
  alias MscmpSystInstance.Msdata.Validators
  alias MscmpSystInstance.Types

  @spec update_changeset(
          Msdata.SystInstanceContexts.t(),
          Types.instance_context_params(),
          Keyword.t()
        ) :: Ecto.Changeset.t()
  def update_changeset(instance_context, update_params, opts) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.OptionDefaults.defaults())

    instance_context
    |> cast(update_params, [
      :start_context,
      :db_pool_size,
      :context_code
    ])
    |> Validators.General.validate_internal_name(opts)
    |> validate_context_code(opts)
    |> validate_required([
      :instance_id,
      :application_context_id,
      :start_context
    ])
    |> validate_number(:db_pool_size, greater_than_or_equal_to: 0)
    |> optimistic_lock(:diag_row_version)
    |> unique_constraint(:internal_name, name: :syst_instance_contexts_internal_name_udx)
    |> foreign_key_constraint(:instance_id, name: :syst_instance_contexts_instances_fk)
    |> foreign_key_constraint(:application_context_id,
      name: :syst_instance_contexts_application_contexts_fk
    )
    |> check_constraint(:db_pool_size, name: :syst_instance_contexts_db_pool_size_chk)
  end

  defp validate_context_code(changeset, opts) do
    changeset
    |> validate_required(:context_code)
    |> validate_length(:context_code,
      min: opts[:min_context_code_length],
      max: opts[:max_context_code_length]
    )
  end
end
