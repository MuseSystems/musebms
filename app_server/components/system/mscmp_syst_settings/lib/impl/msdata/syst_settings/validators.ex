# Source File: validators.ex
# Location:    musebms/app_server/components/system/mscmp_syst_settings/lib/impl/msdata/syst_settings/validators.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystSettings.Impl.Msdata.SystSettings.Validators do
  @moduledoc false

  import Ecto.Changeset

  @spec changeset(Msdata.SystSettings.t(), map(), Keyword.t()) :: Ecto.Changeset.t()
  def changeset(syst_settings, change_params, opts) do
    syst_settings
    |> cast(change_params, [
      :internal_name,
      :display_name,
      :user_description,
      :setting_flag,
      :setting_integer,
      :setting_integer_range,
      :setting_decimal,
      :setting_decimal_range,
      :setting_interval,
      :setting_date,
      :setting_date_range,
      :setting_time,
      :setting_timestamp,
      :setting_timestamp_range,
      :setting_json,
      :setting_text,
      :setting_uuid,
      :setting_blob
    ])
    |> maybe_put_syst_defined()
    |> Msutils.Data.validate_internal_name(opts)
    |> Msutils.Data.validate_display_name(opts)
    |> Msutils.Data.validate_user_description(opts)
    |> optimistic_lock(:diag_row_version)
    |> unique_constraint(:internal_name, name: :syst_settings_internal_name_udx)
    |> unique_constraint(:display_name, name: :syst_settings_display_name_udx)
  end

  # Add a change for syst_defined set to false.
  #
  # Applications that create system defined settings should not use this module
  # to create them, but should instead create them directly via database
  # migrations.  This function will ensure that the syst_defined value is
  # set to false for new records.
  #
  # A record is considered new if the :id field is nil.

  defp maybe_put_syst_defined(changeset) do
    changeset
    |> get_field(:id, nil)
    |> is_nil()
    |> maybe_put_syst_defined(changeset)
  end

  defp maybe_put_syst_defined(true, changeset), do: put_change(changeset, :syst_defined, false)
  defp maybe_put_syst_defined(false, changeset), do: changeset
end
