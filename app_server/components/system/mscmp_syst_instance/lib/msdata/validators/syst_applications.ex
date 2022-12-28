# Source File: syst_applications.ex
# Location:    musebms/components/system/mscmp_syst_instance/lib/msdata/validators/syst_applications.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Msdata.Validators.SystApplications do
  import Ecto.Changeset

  alias MscmpSystInstance.Msdata.Helpers
  alias MscmpSystInstance.Msdata.Validators
  alias MscmpSystInstance.Types

  @moduledoc false

  @spec insert_changeset(Types.application_params(), Keyword.t()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params, opts) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.OptionDefaults.defaults())

    %Msdata.SystApplications{}
    |> cast(insert_params, [
      :internal_name,
      :display_name,
      :syst_description
    ])
    |> validate_common(opts)
  end

  @spec update_changeset(Msdata.SystApplications.t(), Types.application_params(), Keyword.t()) ::
          Ecto.Changeset.t()
  def update_changeset(application, update_params, opts) do
    opts = MscmpSystUtils.resolve_options(opts, Helpers.OptionDefaults.defaults())

    application
    |> cast(update_params, [
      :display_name,
      :syst_description
    ])
    |> validate_common(opts)
    |> optimistic_lock(:diag_row_version)
  end

  defp validate_common(changeset, opts) do
    changeset
    |> Validators.General.validate_internal_name(opts)
    |> Validators.General.validate_display_name(opts)
    |> validate_required([:internal_name, :display_name, :syst_description])
    |> unique_constraint(:internal_name, name: :syst_applications_internal_name_udx)
    |> unique_constraint(:display_name, name: :syst_applications_display_name_udx)
  end
end
