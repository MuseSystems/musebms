# Source File: syst_perms.ex
# Location:    musebms/components/system/mscmp_syst_perms/lib/msdata/validators/syst_perms.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystPerms.Msdata.Validators.SystPerms do
  import Ecto.Changeset

  alias MscmpSystPerms.Msdata.Helpers
  alias MscmpSystPerms.Msdata.Validators
  alias MscmpSystPerms.Types

  @moduledoc false

  # The scope options fields are not "required" in the insert_changeset function
  # because the database will default them if they aren't provided.  On update
  # however we need to be sure they're present.

  @spec insert_changeset(Types.perm_params(), Keyword.t()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params, opts) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.OptionDefaults.defaults())

    resolved_insert_params = resolve_scopes(insert_params)

    %Msdata.SystPerms{}
    |> cast(resolved_insert_params, [
      :internal_name,
      :display_name,
      :perm_functional_type_id,
      :user_description,
      :view_scope_options,
      :maint_scope_options,
      :admin_scope_options,
      :ops_scope_options
    ])
    |> validate_required([
      :internal_name,
      :display_name,
      :perm_functional_type_id,
      :user_description
    ])
    |> validate_common(opts)
  end

  @spec update_changeset(Msdata.SystPerms.t(), Types.perm_params(), Keyword.t()) ::
          Ecto.Changeset.t()
  def update_changeset(perm, update_params, opts) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.OptionDefaults.defaults())

    resolved_update_params = resolve_scopes(update_params)

    perm
    |> cast(resolved_update_params, [
      :internal_name,
      :display_name,
      :user_description,
      :view_scope_options,
      :maint_scope_options,
      :admin_scope_options,
      :ops_scope_options
    ])
    |> Validators.General.validate_syst_defined_changes([
      :internal_name,
      :view_scope_options,
      :maint_scope_options,
      :admin_scope_options,
      :ops_scope_options
    ])
    |> validate_required([
      :internal_name,
      :display_name,
      :perm_functional_type_id,
      :view_scope_options,
      :maint_scope_options,
      :admin_scope_options,
      :ops_scope_options
    ])
    |> optimistic_lock(:diag_row_version)
    |> validate_common(opts)
  end

  defp validate_common(changeset, opts) do
    changeset
    |> Validators.General.validate_internal_name(opts)
    |> Validators.General.validate_display_name(opts)
    |> unique_constraint(:internal_name, name: :syst_perms_internal_name_udx)
    |> unique_constraint(:display_name, name: :syst_perms_display_name_udx)
    |> check_constraint(:view_scope_options, name: :syst_perms_view_scope_options_chk)
    |> check_constraint(:maint_scope_options, name: :syst_perms_maint_scope_options_chk)
    |> check_constraint(:admin_scope_options, name: :syst_perms_admin_scope_options_chk)
    |> check_constraint(:ops_scope_options, name: :syst_perms_ops_scope_options_chk)
    |> foreign_key_constraint(:perm_functional_type_id, name: :syst_perms_perm_functional_type_fk)
  end

  defp resolve_scopes(params) do
    params
    |> Map.replace(:view_scope_options, convert_scope_list(params[:view_scope_options]))
    |> Map.replace(:maint_scope_options, convert_scope_list(params[:maint_scope_options]))
    |> Map.replace(:admin_scope_options, convert_scope_list(params[:admin_scope_options]))
    |> Map.replace(:ops_scope_options, convert_scope_list(params[:ops_scope_options]))
  end

  defp convert_scope_list(nil), do: nil
  defp convert_scope_list(scope_list), do: Enum.map(scope_list, &Atom.to_string/1)
end
