# Source File: validators.ex
# Location:    musebms/app_server/components/system/mscmp_syst_enums/lib/impl/msdata/syst_enum_functional_types/validators.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystEnums.Impl.Msdata.SystEnumFunctionalTypes.Validators do
  @moduledoc false

  import Ecto.Changeset

  alias MscmpSystEnums.Impl.Msdata.GeneralValidators

  @doc false
  @spec changeset(Msdata.SystEnumFunctionalTypes.t(), map(), Keyword.t()) :: Ecto.Changeset.t()
  def changeset(syst_enum_functional_types, change_params, opts) do
    opts = GeneralValidators.resolve_options(opts)

    syst_enum_functional_types
    |> cast(change_params, [
      :internal_name,
      :display_name,
      :external_name,
      :enum_id,
      :user_description
    ])
    |> GeneralValidators.validate_internal_name(opts)
    |> GeneralValidators.validate_display_name(opts)
    |> GeneralValidators.validate_enum_id()
    |> GeneralValidators.validate_external_name(opts)
    |> GeneralValidators.validate_user_description(opts)
    |> optimistic_lock(:diag_row_version)
    |> unique_constraint(:internal_name, name: :syst_enum_functional_types_internal_name_udx)
    |> unique_constraint(:display_name, name: :syst_enum_functional_types_display_name_udx)
    |> foreign_key_constraint(:enum_id, name: :syst_enum_functional_types_enum_fk)
  end
end
