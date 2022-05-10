# Source File: settings.ex
# Location:    components/system/msbms_syst_settings/lib/impl/settings.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystSettings.Impl.Settings do
  alias MsbmsSystSettings.Data.SystSettings
  alias MsbmsSystSettings.Runtime.ProcessUtils

  import Ecto.Query

  require Logger

  @moduledoc false

  ######
  #
  # The application logic which is accessed via either the public API defined in
  # MsbmsSystSettings or which may be accessed via the
  # MsbmsSystSettings.Runtime.Server module.
  #
  ######

  # Note that all data changing functions must be called from the GenServer
  # since we need to change data in the ets tables which are owned by the
  # GenServer and are in "protected" mode.

  @spec refresh_from_database() :: :ok
  def refresh_from_database do
    ets_table_name = get_ets_table_from_service_name(ProcessUtils.get_settings_service())

    :ets.delete_all_objects(ets_table_name)

    MsbmsSystDatastore.all(SystSettings)
    |> Enum.each(&:ets.insert(ets_table_name, {&1.internal_name, &1}))
  end

  @spec get_setting_values(MsbmsSystSettings.Types.setting_name()) ::
          MsbmsSystSettings.Data.SystSettings.t()
  def get_setting_values(setting_name) do
    ProcessUtils.get_settings_service()
    |> get_ets_table_from_service_name()
    |> :ets.lookup_element(setting_name, 2)
  end

  @spec get_setting_value(
          MsbmsSystSettings.Types.setting_name(),
          MsbmsSystSettings.Types.setting_types()
        ) :: any()
  def get_setting_value(setting_name, setting_type)
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
    get_setting_values(setting_name)
    |> Map.get(setting_type)
  end

  @spec get_all_settings_values() ::
          list(MsbmsSystSettings.Data.SystSettings)
  def get_all_settings_values do
    # Select query :ets.fun2ms(fn {_, setting_values} -> setting_values end)
    ProcessUtils.get_settings_service()
    |> get_ets_table_from_service_name()
    |> :ets.select([{{:_, :"$1"}, [], [:"$1"]}])
  end

  @spec create_setting(MsbmsSystSettings.Types.setting_params()) ::
          :ok | {:error, MsbmsSystError.t()}
  def create_setting(creation_params) when is_map(creation_params) do
    ets_table_name = get_ets_table_from_service_name(ProcessUtils.get_settings_service())

    creation_params
    |> then(&SystSettings.changeset(%SystSettings{}, &1))
    |> MsbmsSystDatastore.insert!(returning: true)
    |> then(&:ets.insert(ets_table_name, {&1.internal_name, &1}))

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure creating new setting.",
          cause: error
        }
      }
  end

  @spec update_setting(
          MsbmsSystSettings.Types.setting_name(),
          MsbmsSystSettings.Types.setting_params()
        ) :: :ok | {:error, MsbmsSystError.t()}
  def update_setting(setting_name, update_params)
      when is_binary(setting_name) and is_map(update_params) do
    ets_table_name = get_ets_table_from_service_name(ProcessUtils.get_settings_service())

    :ets.lookup_element(ets_table_name, setting_name, 2)
    |> SystSettings.changeset(update_params)
    |> MsbmsSystDatastore.update!(returning: true)
    |> then(&:ets.update_element(ets_table_name, setting_name, {2, &1}))

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure updating setting.",
          cause: error
        }
      }
  end

  @spec delete_setting(MsbmsSystSettings.Types.setting_name()) ::
          :ok | {:error, MsbmsSystError.t()}
  def delete_setting(setting_name) when is_binary(setting_name) do
    ets_table_name = get_ets_table_from_service_name(ProcessUtils.get_settings_service())

    delete_qry =
      from(s in MsbmsSystSettings.Data.SystSettings, where: s.internal_name == ^setting_name)

    {1, _rows} = MsbmsSystDatastore.delete_all(delete_qry)

    true = :ets.delete(ets_table_name, setting_name)

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting setting.",
          cause: error
        }
      }
  end

  @spec get_ets_table_from_service_name(MsbmsSystSettings.Types.service_name()) :: atom()
  def get_ets_table_from_service_name(service_name) when is_atom(service_name), do: service_name

  def get_ets_table_from_service_name({:via, _module, service_name})
      when is_atom(service_name),
      do: service_name

  def get_ets_table_from_service_name({:via, _module, {_reg, service_name}})
      when is_atom(service_name),
      do: service_name
end
