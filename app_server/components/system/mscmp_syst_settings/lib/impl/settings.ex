# Source File: settings.ex
# Location:    musebms/components/system/mscmp_syst_settings/lib/impl/settings.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystSettings.Impl.Settings do
  @moduledoc false

  import Ecto.Query

  alias MscmpSystSettings.Runtime.ProcessUtils
  alias MscmpSystSettings.Types

  require Logger

  ######
  #
  # The application logic which is accessed via either the public API defined in
  # MscmpSystSettings or which may be accessed via the
  # MscmpSystSettings.Runtime.Server module.
  #
  ######

  # Note that all data changing functions must be called from the GenServer
  # since we need to change data in the ets tables which are owned by the
  # GenServer and are in "protected" mode.

  @spec refresh_from_database() :: :ok
  def refresh_from_database, do: ProcessUtils.get_settings_table() |> refresh_from_database()

  @spec refresh_from_database(:ets.table()) :: :ok
  def refresh_from_database(settings_table)
      when is_atom(settings_table) or is_reference(settings_table) do
    :ets.delete_all_objects(settings_table)

    MscmpSystDb.all(Msdata.SystSettings)
    |> Enum.each(&:ets.insert(settings_table, {&1.internal_name, &1}))
  end

  @spec get_values(Types.setting_name()) :: Msdata.SystSettings.t()
  def get_values(setting_name),
    do: ProcessUtils.get_settings_table() |> :ets.lookup_element(setting_name, 2)

  @spec get_value(Types.setting_name(), Types.setting_types()) :: any()
  def get_value(setting_name, setting_type)
      when setting_type in [
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
           ] do
    get_values(setting_name)
    |> Map.get(setting_type)
  end

  @spec list_all() :: list(Msdata.SystSettings)
  def list_all do
    # Select query :ets.fun2ms(fn {_, setting_values} -> setting_values end)
    ProcessUtils.get_settings_table() |> :ets.select([{{:_, :"$1"}, [], [:"$1"]}])
  end

  @spec create(Types.setting_params()) :: :ok | {:error, MscmpSystError.t()}
  def create(creation_params) when is_map(creation_params),
    do: ProcessUtils.get_settings_table() |> create(creation_params)

  @spec create(:ets.table(), Types.setting_params()) :: :ok | {:error, MscmpSystError.t()}
  def create(settings_table, creation_params)
      when (is_atom(settings_table) or is_reference(settings_table)) and is_map(creation_params) do
    creation_params
    |> then(&Msdata.SystSettings.changeset(%Msdata.SystSettings{}, &1))
    |> MscmpSystDb.insert!(returning: true)
    |> then(&:ets.insert(settings_table, {&1.internal_name, &1}))

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure creating new setting.",
          cause: error
        }
      }
  end

  @spec update_setting(Types.setting_name(), Types.setting_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def update_setting(setting_name, update_params),
    do: ProcessUtils.get_settings_table() |> update_setting(setting_name, update_params)

  @spec update_setting(:ets.table(), Types.setting_name(), Types.setting_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def update_setting(settings_table, setting_name, update_params)
      when (is_atom(settings_table) or is_reference(settings_table)) and
             is_binary(setting_name) and
             is_map(update_params) do
    :ets.lookup_element(settings_table, setting_name, 2)
    |> Msdata.SystSettings.changeset(update_params)
    |> MscmpSystDb.update!(returning: true)
    |> then(&:ets.update_element(settings_table, setting_name, {2, &1}))

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure updating setting.",
          cause: error
        }
      }
  end

  @spec delete(Types.setting_name()) :: :ok | {:error, MscmpSystError.t()}
  def delete(setting_name),
    do: ProcessUtils.get_settings_table() |> delete(setting_name)

  @spec delete(:ets.table(), Types.setting_name()) :: :ok | {:error, MscmpSystError.t()}
  def delete(settings_table, setting_name)
      when (is_atom(settings_table) or is_reference(settings_table)) and is_binary(setting_name) do
    delete_qry = from(s in Msdata.SystSettings, where: s.internal_name == ^setting_name)

    {1, _rows} = MscmpSystDb.delete_all(delete_qry)

    true = :ets.delete(settings_table, setting_name)

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure deleting setting.",
          cause: error
        }
      }
  end
end
