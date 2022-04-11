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
  require Logger

  @moduledoc false

  ######
  #
  # The application logic which is accessed via either the public API defined in
  # MsbmsSystSettings or which may be accessed via the
  # MsbmsSystSettings.Runtime.Server module.
  #
  ######

  @spec refresh_from_database(MsbmsSystSettings.Types.service_name()) :: :ok
  def refresh_from_database(service_name) do
    ets_table_name = get_ets_table_from_service_name(service_name)

    :ets.delete_all_objects(ets_table_name)

    MsbmsSystDatastore.all(SystSettings)
    |> Enum.each(&:ets.insert(ets_table_name, {&1.internal_name, &1}))
  end

  @spec get_setting_values(
          MsbmsSystSettings.Types.service_name(),
          MsbmsSystSettings.Types.setting_name()
        ) :: MsbmsSystSettings.Data.SystSettings.t()
  def get_setting_values(service_name, setting_name) do
    :ets.lookup_element(service_name, setting_name, 2)
  end

  @spec get_setting_value(
          MsbmsSystSettings.Types.service_name(),
          MsbmsSystSettings.Types.setting_name(),
          MsbmsSystSettings.Types.setting_types()
        ) :: any()
  def get_setting_value(service_name, setting_name, setting_type)
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
    get_setting_values(service_name, setting_name)
    |> Map.get(setting_type)
  end

  @spec get_all_settings_values(MsbmsSystSettings.Types.service_name()) ::
          list(MsbmsSystSettings.Data.SystSettings)
  def get_all_settings_values(service_name) do
    # Select query :ets.fun2ms(fn {_, setting_values} -> setting_values end)
    service_name
    |> get_ets_table_from_service_name()
    |> :ets.select([{{:_, :"$1"}, [], [:"$1"]}])
  end

  @spec create_setting(
          MsbmsSystSettings.Types.service_name(),
          MsbmsSystSettings.Types.setting_params()
        ) ::
          :ok | {:error, MsbmsSystError.t()}
  def create_setting(service_name, creation_params) when is_map(creation_params) do
    ets_table_name = get_ets_table_from_service_name(service_name)

    creation_params
    |> SystSettings.create_changeset()
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
          MsbmsSystSettings.Types.service_name(),
          MsbmsSystSettings.Types.setting_name(),
          MsbmsSystSettings.Types.setting_params()
        ) :: :ok | {:error, MsbmsSystError.t()}
  def update_setting(service_name, setting_name, update_params)
      when is_binary(setting_name) and is_map(update_params) do
    ets_table_name = get_ets_table_from_service_name(service_name)

    :ets.lookup_element(ets_table_name, setting_name, 2)
    |> SystSettings.update_changeset(update_params)
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

  @spec delete_setting(
          MsbmsSystSettings.Types.service_name(),
          MsbmsSystSettings.Types.setting_name()
        ) :: :ok | {:error, MsbmsSystError.t()}
  def delete_setting(service_name, setting_name) when is_binary(setting_name) do
    ets_table_name = get_ets_table_from_service_name(service_name)

    :ets.lookup_element(ets_table_name, setting_name, 2)
    |> MsbmsSystDatastore.update!()
    |> then(&:ets.delete(ets_table_name, &1.internal_name))

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
