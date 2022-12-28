# Source File: syst_perm_roles.ex
# Location:    musebms/components/system/mscmp_syst_perms/lib/msdata/validators/syst_perm_roles.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystPerms.Msdata.Validators.SystPermRoles do
  import Ecto.Changeset

  alias MscmpSystPerms.Msdata.Helpers
  alias MscmpSystPerms.Msdata.Validators
  alias MscmpSystPerms.Types

  @moduledoc false

  @spec insert_changeset(Types.perm_role_params(), Keyword.t()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params, opts) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.OptionDefaults.defaults())

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
    opts = MscmpSystUtils.resolve_options(opts, Helpers.OptionDefaults.defaults())

    perm_role
    |> cast(update_params, [
      :internal_name,
      :display_name,
      :user_description
    ])
    |> Validators.General.validate_syst_defined_changes([:internal_name])
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
    |> Validators.General.validate_internal_name(opts)
    |> Validators.General.validate_display_name(opts)
    |> unique_constraint(:internal_name, name: :syst_perm_roles_internal_name_udx)
    |> unique_constraint(:display_name, name: :syst_perm_roles_display_name_udx)
    |> foreign_key_constraint(:perm_functional_type_id,
      name: :syst_perm_roles_perm_functional_type_fk
    )
  end
end
