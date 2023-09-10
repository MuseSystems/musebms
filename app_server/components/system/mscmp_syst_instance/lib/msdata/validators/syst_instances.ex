# Source File: syst_instances.ex
# Location:    musebms/components/system/mscmp_syst_instance/lib/msdata/validators/syst_instances.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Msdata.Validators.SystInstances do
  @moduledoc false

  import Ecto.Changeset

  alias MscmpSystInstance.Msdata.Helpers
  alias MscmpSystInstance.Msdata.Validators
  alias MscmpSystInstance.Types

  # The expected behavior of instance name resolution is to favor the name over
  # the ID if both are provided and they conflict.  On insert, this is likely
  # wrong, but on update, where this situation is more likely to appear, it is
  # more correct to assume the name represents a new value and the ID an old
  # value.

  @spec insert_changeset(Types.instance_params(), Keyword.t()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params, opts) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.OptionDefaults.defaults())

    resolved_insert_params = Helpers.SystInstances.resolve_name_params(insert_params, :insert)

    %Msdata.SystInstances{}
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
    |> validate_common(opts)
  end

  @spec update_changeset(Msdata.SystInstances.t(), Types.instance_params(), Keyword.t()) ::
          Ecto.Changeset.t()
  def update_changeset(instance, update_params, opts) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.OptionDefaults.defaults())

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
    |> validate_common(opts)
    |> optimistic_lock(:diag_row_version)
  end

  defp validate_common(changeset, opts) do
    changeset
    |> Validators.General.validate_internal_name(opts)
    |> Validators.General.validate_display_name(opts)
    |> validate_instance_code(opts)
    |> validate_required([
      :application_id,
      :instance_type_id,
      :instance_state_id
    ])
    |> unique_constraint(:internal_name, name: :syst_instances_internal_name_udx)
    |> unique_constraint(:display_name, name: :syst_instances_display_name_udx)
    |> foreign_key_constraint(:application_id, name: :syst_instances_applications_fk)
    |> foreign_key_constraint(:instance_type_id, name: :syst_instances_enum_instance_type_fk)
    |> foreign_key_constraint(:instance_state_id, name: :syst_instances_enum_instance_state_fk)
    |> foreign_key_constraint(:owner_id, name: :syst_instances_owners_fk)
    |> foreign_key_constraint(:owning_instance_id, name: :syst_instances_owning_instance_fk)
    |> check_constraint(:owning_instance_id, name: :syst_instances_self_ownership_chk)
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
