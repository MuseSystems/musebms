# Source File: validators.ex
# Location:    musebms/app_server/components/system/mscmp_syst_enums/lib/impl/msdata/syst_enums/validators.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystEnums.Impl.Msdata.SystEnums.Validators do
  @moduledoc false

  import Ecto.Changeset

  alias MscmpSystEnums.Impl.Msdata.GeneralValidators

  @spec changeset(Msdata.SystEnums.t(), map(), Keyword.t()) :: Ecto.Changeset.t()
  def changeset(syst_enums, change_params, opts) do
    opts = GeneralValidators.resolve_options(opts)

    syst_enums
    |> cast(change_params, [
      :internal_name,
      :display_name,
      :user_description,
      :default_user_options
    ])
    |> GeneralValidators.validate_internal_name(opts)
    |> GeneralValidators.validate_display_name(opts)
    |> GeneralValidators.validate_user_description(opts)
    |> GeneralValidators.maybe_put_syst_defined()
    |> GeneralValidators.maybe_put_user_maintainable()
    |> optimistic_lock(:diag_row_version)
    |> unique_constraint(:internal_name, name: :syst_enums_internal_name_udx)
    |> unique_constraint(:display_name, name: :syst_enums_display_name_udx)
  end
end
