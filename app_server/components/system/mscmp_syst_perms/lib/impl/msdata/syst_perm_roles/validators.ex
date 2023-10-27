# Source File: validators.ex
# Location:    musebms/app_server/components/system/mscmp_syst_perms/lib/impl/msdata/syst_perm_roles/validators.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems
defmodule MscmpSystPerms.Impl.Msdata.SystPermRoles.Validators do
  @moduledoc false

  import Ecto.Changeset

  alias MscmpSystPerms.Impl.Msdata.GeneralValidators
  alias MscmpSystPerms.Impl.Msdata.Helpers
  alias MscmpSystPerms.Types

  @spec insert_changeset(Types.perm_role_params(), Keyword.t()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params, opts) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.option_defaults())

    %Msdata.SystPermRoles{}
    |> cast(insert_params, [
      :internal_name,
      :display_name,
      :perm_functional_type_id,
      :user_description
    ])
    |> validate_required([
      :internal_name,
      :display_name,
      :perm_functional_type_id,
      :user_description
    ])
    |> validate_common(opts)
  end

  @spec update_changeset(Msdata.SystPermRoles.t(), Types.perm_role_params(), Keyword.t()) ::
          Ecto.Changeset.t()
  def update_changeset(perm_role, update_params, opts) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.option_defaults())

    perm_role
    |> cast(update_params, [
      :internal_name,
      :display_name,
      :user_description
    ])
    |> GeneralValidators.validate_syst_defined_changes([:internal_name])
    |> validate_required([
      :internal_name,
      :display_name,
      :perm_functional_type_id
    ])
    |> optimistic_lock(:diag_row_version)
    |> validate_common(opts)
  end

  defp validate_common(changeset, opts) do
    changeset
    |> GeneralValidators.validate_internal_name(opts)
    |> GeneralValidators.validate_display_name(opts)
    |> unique_constraint(:internal_name, name: :syst_perm_roles_internal_name_udx)
    |> unique_constraint(:display_name, name: :syst_perm_roles_display_name_udx)
    |> foreign_key_constraint(:perm_functional_type_id,
      name: :syst_perm_roles_perm_functional_type_fk
    )
  end
end
