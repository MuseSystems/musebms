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

  ##############################################################################
  #
  # refresh_from_database
  #
  #

  @spec refresh_from_database() :: :ok
  def refresh_from_database, do: ProcessUtils.get_settings_table() |> refresh_from_database()

  @spec refresh_from_database(:ets.table()) :: :ok
  def refresh_from_database(settings_table)
      when is_atom(settings_table) or is_reference(settings_table) do
    :ets.delete_all_objects(settings_table)

    MscmpSystDb.all(Msdata.SystSettings)
    |> Enum.each(&:ets.insert(settings_table, {&1.internal_name, &1}))
  end

  ##############################################################################
  #
  # get_values
  #
  #

  @spec get_values(Types.setting_name()) :: Msdata.SystSettings.t()
  def get_values(setting_name),
    do: ProcessUtils.get_settings_table() |> :ets.lookup_element(setting_name, 2)

  ##############################################################################
  #
  # get_value
  #
  #

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

  ##############################################################################
  #
  # list_all
  #
  #

  @spec list_all() :: list(Msdata.SystSettings)
  def list_all do
    # Select query :ets.fun2ms(fn {_, setting_values} -> setting_values end)
    ProcessUtils.get_settings_table() |> :ets.select([{{:_, :"$1"}, [], [:"$1"]}])
  end

  ##############################################################################
  #
  # create
  #
  #

  @spec create(Types.setting_params()) :: :ok | {:error, term()}
  def create(creation_params) when is_map(creation_params),
    do: ProcessUtils.get_settings_table() |> create(creation_params)

  @spec create(:ets.table(), Types.setting_params()) :: :ok | {:error, term()}
  def create(settings_table, creation_params)
      when (is_atom(settings_table) or is_reference(settings_table)) and is_map(creation_params) do
    validated_changeset = Msdata.SystSettings.changeset(%Msdata.SystSettings{}, creation_params)

    with {:ok, updated_data} <- MscmpSystDb.insert(validated_changeset, returning: true),
         true <-
           :ets.insert(settings_table, {updated_data.internal_name, updated_data}) do
      :ok
    else
      error when error === false ->
        {:error, {:ets_insert_error, {settings_table, validated_changeset}}}

      error ->
        {:error, {:unknown_error, error}}
    end
  end

  ##############################################################################
  #
  # update_setting
  #
  #

  @spec update_setting(Types.setting_name(), Types.setting_params()) ::
          :ok | {:error, term()}
  def update_setting(setting_name, update_params),
    do: ProcessUtils.get_settings_table() |> update_setting(setting_name, update_params)

  @spec update_setting(:ets.table(), Types.setting_name(), Types.setting_params()) ::
          :ok | {:error, term()}
  def update_setting(settings_table, setting_name, update_params)
      when (is_atom(settings_table) or is_reference(settings_table)) and
             is_binary(setting_name) and
             is_map(update_params) do
    with existing_data <- :ets.lookup_element(settings_table, setting_name, 2),
         changeset <- Msdata.SystSettings.changeset(existing_data, update_params),
         {:ok, updated_data} <- MscmpSystDb.update(changeset, returning: true),
         true <- :ets.update_element(settings_table, setting_name, {2, updated_data}) do
      :ok
    else
      error -> {:error, {:database_error, error}}
    end
  rescue
    error ->
      {:error, {:ets_error, error}}
  end

  ##############################################################################
  #
  # delete
  #
  #

  @spec delete(Types.setting_name()) :: :ok | {:error, term()}
  def delete(setting_name),
    do: ProcessUtils.get_settings_table() |> delete(setting_name)

  @spec delete(:ets.table(), Types.setting_name()) :: :ok | {:error, term()}
  def delete(settings_table, setting_name)
      when (is_atom(settings_table) or is_reference(settings_table)) and is_binary(setting_name) do
    delete_qry = from(s in Msdata.SystSettings, where: s.internal_name == ^setting_name)

    try do
      with {1, _rows} <- MscmpSystDb.delete_all(delete_qry),
           true <- :ets.delete(settings_table, setting_name) do
        :ok
      else
        {0, _} ->
          {:error, {:not_found, setting_name}}
      end
    rescue
      error ->
        {:error, {:database_error, error}}
    end
  end
end
