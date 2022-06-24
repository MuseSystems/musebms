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
  import MsbmsSystUtils
  import MsbmsSystInstanceMgr.Data.Validators.General

  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Data.Helpers
  alias MsbmsSystInstanceMgr.Types

  @moduledoc false

  @spec update_changeset(
          Data.SystInstanceContexts.t(),
          Types.instance_context_params(),
          Keyword.t()
        ) :: Ecto.Changeset.t()
  def update_changeset(instance_context, update_params, opts) do
    opts = resolve_options(opts, Helpers.OptionDefaults.defaults())

    instance_context
    |> cast(update_params, [
      :start_context,
      :db_pool_size,
      :context_code
    ])
    |> validate_internal_name(opts)
    |> validate_context_code(opts)
    |> validate_required([
      :instance_id,
      :application_context_id,
      :start_context
    ])
    |> validate_number(:db_pool_size, greater_than_or_equal_to: 0)
    |> optimistic_lock(:diag_row_version)
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
