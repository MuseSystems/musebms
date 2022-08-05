# Source File: syst_instances.ex
# Location:    musebms/components/system/msbms_syst_instance_mgr/lib/data/validators/syst_instances.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystInstanceMgr.Data.Validators.SystInstances do
  import Ecto.Changeset
  import MsbmsSystUtils
  import MsbmsSystInstanceMgr.Data.Validators.General

  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Data.Helpers
  alias MsbmsSystInstanceMgr.Types

  @moduledoc false

  # The expected behavior of instance name resolution is to favor the name over
  # the ID if both are provided and they conflict.  On insert, this is likely
  # wrong, but on update, where this situation is more likely to appear, it is
  # more correct to assume the name represents a new value and the ID an old
  # value.

  @spec insert_changeset(Types.instance_params(), Keyword.t()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params, opts) do
    opts = resolve_options(opts, Helpers.OptionDefaults.defaults())

    resolved_insert_params = Helpers.SystInstances.resolve_name_params(insert_params, :insert)

    %Data.SystInstances{}
    |> cast(resolved_insert_params, [
      :internal_name,
      :display_name,
      :application_id,
      :instance_type_id,
      :instance_state_id,
      :owner_id,
      :owning_instance_id,
      :dbserver_name,
      :instance_code,
      :instance_options
    ])
    |> validate_internal_name(opts)
    |> validate_display_name(opts)
    |> validate_instance_code(opts)
    |> validate_required([
      :application_id,
      :instance_type_id,
      :instance_state_id
    ])
  end

  @spec update_changeset(Data.SystInstances.t(), Types.instance_params(), Keyword.t()) ::
          Ecto.Changeset.t()
  def update_changeset(instance, update_params, opts) do
    opts = resolve_options(opts, Helpers.OptionDefaults.defaults())

    resolved_update_params = Helpers.SystInstances.resolve_name_params(update_params, :update)

    instance
    |> cast(resolved_update_params, [
      :internal_name,
      :display_name,
      :instance_type_id,
      :instance_state_id,
      :dbserver_name,
      :instance_code,
      :instance_options
    ])
    |> validate_internal_name(opts)
    |> validate_display_name(opts)
    |> validate_instance_code(opts)
    |> validate_required([
      :application_id,
      :instance_type_id,
      :instance_state_id
    ])
    |> optimistic_lock(:diag_row_version)
  end

  defp validate_instance_code(changeset, opts) do
    changeset
    |> validate_required(:instance_code)
    |> validate_length(:instance_code,
      min: opts[:min_instance_code_length],
      max: opts[:max_instance_code_length]
    )
  end
end
