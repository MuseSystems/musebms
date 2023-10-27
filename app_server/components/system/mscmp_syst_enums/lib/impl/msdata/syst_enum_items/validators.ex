# Source File: validators.ex
# Location:    musebms/app_server/components/system/mscmp_syst_enums/lib/impl/msdata/syst_enum_items/validators.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystEnums.Impl.Msdata.SystEnumItems.Validators do
  @moduledoc false

  import Ecto.Changeset

  alias MscmpSystEnums.Impl.Msdata.GeneralValidators

  @spec changeset(Msdata.SystEnumItems.t(), map(), Keyword.t()) :: Ecto.Changeset.t()
  def changeset(syst_enum_items, change_params, opts) do
    opts = GeneralValidators.resolve_options(opts)

    syst_enum_items
    |> cast(change_params, [
      :internal_name,
      :display_name,
      :external_name,
      :enum_default,
      :functional_type_default,
      :user_description,
      :sort_order,
      :user_options,
      :enum_id,
      :functional_type_id
    ])
    |> maybe_default_enum_default()
    |> maybe_default_functional_type_default()
    |> GeneralValidators.validate_enum_id()
    |> GeneralValidators.validate_functional_type_id()
    |> GeneralValidators.validate_internal_name(opts)
    |> GeneralValidators.validate_display_name(opts)
    |> GeneralValidators.validate_external_name(opts)
    |> GeneralValidators.validate_user_description(opts)
    |> GeneralValidators.maybe_put_syst_defined()
    |> GeneralValidators.maybe_put_user_maintainable()
    |> optimistic_lock(:diag_row_version)
    |> unique_constraint(:internal_name, name: :syst_enum_items_internal_name_udx)
    |> unique_constraint(:display_name, name: :syst_enum_items_display_name_udx)
    |> foreign_key_constraint(:enum_id, name: :syst_enum_items_enum_fk)
    |> foreign_key_constraint(:functional_type_id, name: :syst_enum_items_enum_functional_type_fk)
  end

  defp maybe_default_enum_default(changeset),
    do: put_change(changeset, :enum_default, get_field(changeset, :enum_default) || false)

  defp maybe_default_functional_type_default(changeset) do
    put_change(
      changeset,
      :functional_type_default,
      get_field(changeset, :functional_type_default) || false
    )
  end
end
