# Source File: msbms_syst_settings.ex
# Location:    musebms/components/system/msbms_syst_settings/lib/msbms_syst_settings.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystSettings do
  alias MsbmsSystSettings.Impl.Settings
  alias MsbmsSystSettings.Runtime.ProcessUtils

  @moduledoc """
  A user options configuration management service.

  The Settings Service provides caching and management functions for user
  configurable options which govern how the application operates.  Multiple
  Settings Service instances may be in operation depending on the needs of the
  application; for example, in the case of multi-tenancy, each tenant will have
  its own instance of the Setting Service running since each tenant's needs of
  the application may unique.

  On startup, the Settings Service creates an in memory cache and populates the
  cache from the database.  Enquiries for settings are then served from the
  cache rather than the database as needed.  Operations which change the
  Settings data are written to the database and then updated in the cache.

  Settings maintained by this service may be changed by users at any time while
  the application is running.  Therefore, any logic depending on the Settings
  from this service should be written as to be insensitive to such changes.
  Logic should avoid multiple retrievals of the same setting during any one
  transaction.
  """

  @doc """
  Starts an instance of the Settings Service.

  Starting the service establishes the required processes and pre-populates the
  service cache with data from the database.  Most other functions in this
  module require that the service is started prior to use and will fail if the
  service is not started.

  The `service_name` argument provides a unique name under which the service can
  be found.  This argument is a subset of those that allowed for registering
  GenServers; the allowed forms for service name are simple atoms for basic
  local name registry or a "via tuple", such as might be used with the
  `Registry` module.

  The `datastore_context_name` is an atom which represents a started
  `MsbmsSystDatastore` context.  This context will be used for accessing and
  modifying database data.
  """
  @spec start_link(
          {MsbmsSystSettings.Types.service_name(), MsbmsSystDatastore.Types.context_name()}
        ) ::
          {:ok, pid()} | {:error, MsbmsSystError.t()}
  defdelegate start_link(params), to: MsbmsSystSettings.Runtime.Server

  @doc """
  Establishes the current Settings Service instance for the process.

  A running system is likely to have more than one instance of the Settings
  Service running.  For example, in multi-tenant applications each tenant may
  have its own instance of the Setting Service, caching data unique to the
  tenant.

  Calling `MsbmsSystSettings.put_settings_service/1` will set the reference to
  the desired Settings Service instance for any subsequent MsbmsSystSettings
  calls.  The service name is set in the Process Dictionary of the process from
  which the calls are being made.  As such, you must call put_settings_service
  at least once for any process from which you wish to access the Settings
  Service.

  Because we're just thinly wrapping `Process.put/2` here, the return value will
  be the previous value set here, or nil if no previous value was set.

  ## Parameters
    * `service_name` - The name of the service which is to be set as servicing
      the process.

  ## Examples

      iex> MsbmsSystSettings.put_settings_service(:settings_instance)
  """
  @spec put_settings_service(MsbmsSystSettings.Types.service_name() | nil) ::
          MsbmsSystSettings.Types.service_name() | nil
  defdelegate put_settings_service(service_name), to: ProcessUtils

  @doc """
  Retrieves the currently set Settings Service name or `nil` if none has been
  set.

  ## Examples
      iex> MsbmsSystSettings.get_settings_service()
      :settings_instance
  """
  @spec get_settings_service() :: MsbmsSystSettings.Types.service_name() | nil
  defdelegate get_settings_service(), to: ProcessUtils

  @doc """
  Refreshes the cached settings values from the database.

  Calling this function causes the existing cached settings to be purged from
  the cache and the cache to be repopulated from the database using the
  datastore context provided to `start_link/1`.

  ## Examples

    iex> MsbmsSystSettings.refresh_from_database()
    :ok

  """
  @spec refresh_from_database() :: :ok
  def refresh_from_database do
    GenServer.call(ProcessUtils.get_settings_service(), :refresh)
  end

  @doc """
  Creates a new user defined setting.

  This function creates a setting which is automatically marked as being user
  defined.  User created settings such as those created by this function are the
  only kind of settings which may be deleted via `delete_setting/2`.

  ## Parameters
    * `creation_params`a map defining the new settings record.  The map must
      contain the following keys:

      * `internal_name` - This is the unique value which represents the name of
        the setting and is used for latter lookup of setting values.  This key
        should be suitable for programmatic references to the setting.

      * `display_name` - A unique value used to display the setting name in user
        interface contexts.

      * `user_description` - A user visible description of the setting including
        information describing how the setting is used in the application and
        directions for correct usage.  Currently, the description must be at least
        6 characters long.

      other allowed values, such as the setting values themselves, are also
      permitted here, but not required.

  ## Examples

    iex> new_setting = %{
    ...>   internal_name: "create_example_setting",
    ...>   display_name: "Create Example Setting",
    ...>   user_description: "An example of setting creation.",
    ...>   setting_integer: 9876
    ...> }
    iex> MsbmsSystSettings.create_setting(new_setting)
    :ok
  """
  @spec create_setting(MsbmsSystSettings.Types.setting_params()) ::
          :ok | {:error, MsbmsSystError.t()}
  def create_setting(creation_params) do
    GenServer.call(ProcessUtils.get_settings_service(), {:create, creation_params})
  end

  @doc """
  Sets the value of any one setting type for the named setting.

  ## Parameters

    * `setting_name` - the name of the setting to update with the new value.

    * `setting_type` - sets which of the different available value types is
      being updated.

    * `setting_value` - is the new value to set on the setting. Note that the
      setting value must be appropriate for the `setting_type` argument or an
      error will be raised.

  ## Examples

    iex> MsbmsSystSettings.set_setting_value(
    ...>   "set_example_setting",
    ...>   :setting_decimal,
    ...>   Decimal.new("1029.3847"))
    :ok
  """
  @spec set_setting_value(
          MsbmsSystSettings.Types.setting_name(),
          MsbmsSystSettings.Types.setting_types(),
          any()
        ) :: :ok | {:error, MsbmsSystError.t()}
  def set_setting_value(setting_name, setting_type, setting_value) do
    update_params = Map.put_new(%{}, setting_type, setting_value)
    GenServer.call(ProcessUtils.get_settings_service(), {:update, setting_name, update_params})
  end

  @doc """
  Sets one or more of the available setting types for the named setting.

  This function is similar to `set_setting_values/4`, except that multiple
  setting types can have their values set at the same time.  In addition to the
  typed setting values, the setting display name and/or user description values
  may also be set.

  ## Parameters

    * `setting_name` - the name of the setting to update with the new values.

    * `update_params` - is a map that complies with the
      `MsbmsSystSettings.Types.setting_service_params()` type specification and
      includes the updates to setting type values, updates to the `display_name`
      value, and/or updates to the `user_description` value.

  ## Examples

    iex> update_values = %{
    ...>   user_description: "An example of updating the user description.",
    ...>   setting_integer: 6758,
    ...>   setting_date_range:
    ...>      %MsbmsSystDatastore.DbTypes.DateRange{
    ...>        lower: ~D[2022-04-01],
    ...>        upper: ~D[2022-04-12],
    ...>        upper_inclusive: true
    ...>      }
    ...> }
    iex> MsbmsSystSettings.set_setting_values(
    ...>   "set_example_setting",
    ...>   update_values)
    :ok
  """
  @spec set_setting_values(
          MsbmsSystSettings.Types.setting_name(),
          MsbmsSystSettings.Types.setting_service_params()
        ) :: :ok | {:error, MsbmsSystError.t()}
  def set_setting_values(setting_name, update_params) do
    GenServer.call(ProcessUtils.get_settings_service(), {:update, setting_name, update_params})
  end

  @doc """
  Retrieves the value of the given type for the requested setting.

  ## Parameters
  * `setting_name` - the name of the setting for which to retrieve a value.

  * `setting_type` - the type of value which to return.

  ## Examples

    iex> MsbmsSystSettings.get_setting_value(
    ...>   "get_example_setting",
    ...>   :setting_decimal_range)
    %MsbmsSystDatastore.DbTypes.DecimalRange{
      lower: Decimal.new("1.1"),
      upper: Decimal.new("99.99"),
      lower_inclusive: true,
      upper_inclusive: false
    }
  """
  @spec get_setting_value(
          MsbmsSystSettings.Types.setting_name(),
          MsbmsSystSettings.Types.setting_types()
        ) :: any()
  defdelegate get_setting_value(setting_name, setting_type),
    to: Settings

  @doc """
  Retrieves all values associated with the requested setting.

  ## Parameters

    * `setting_name` - the name of the setting for which to retrieve values.

  The successful return of this function is an instance of the
  `MsbmsSystSettings.Data.SystSettings` struct containing the values requested.

  ## Examples

    iex> MsbmsSystSettings.get_setting_values("get_example_setting")
  """
  @spec get_setting_values(MsbmsSystSettings.Types.setting_name()) ::
          MsbmsSystSettings.Data.SystSettings.t()
  defdelegate get_setting_values(setting_name), to: Settings

  @doc """
  Retrieves all values for all settings.

  This function returns all other setting metadata, such as the records' IDs,
  descriptions, etc.

  ## Examples

    iex> MsbmsSystSettings.list_all_settings()
  """
  @spec list_all_settings() ::
          list(MsbmsSystSettings.Data.SystSettings)
  defdelegate list_all_settings(), to: Settings

  @doc """
  Deletes the named user defined setting from the system.

  Note that this function cannot be used to delete a system defined setting.
  Trying to do so will result in a error being raised.

  ## Parameters

    * `setting_name` - the name of the setting should be deleted.

  ## Examples

    iex> MsbmsSystSettings.delete_setting("delete_example_setting")
    :ok
  """
  @spec delete_setting(MsbmsSystSettings.Types.setting_name()) ::
          :ok | {:error, MsbmsSystError.t()}
  def delete_setting(setting_name) do
    GenServer.call(ProcessUtils.get_settings_service(), {:delete, setting_name})
  end

  @doc """
  Terminates a running instance of the settings service.

  ## Examples

    > MsbmsSystSettings.terminate_settings_service()
    :ok
  """
  @spec terminate_settings_service() :: :ok
  def terminate_settings_service do
    GenServer.stop(ProcessUtils.get_settings_service(), :normal)
  end
end
