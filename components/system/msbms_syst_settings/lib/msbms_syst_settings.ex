defmodule MsbmsSystSettings do
  alias MsbmsSystSettings.Impl.Settings
  alias MsbmsSystSettings.Runtime.Server

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
          {MsbmsSystSettings.Types.service_name(), MsbmsSystDatastore.Types.context_id()}
        ) ::
          {:ok, pid()} | {:error, MsbmsSystError.t()}
  def start_link({_service_name, _datastore_context_name} = params) do
    Server.start_link(params)
  end

  @doc """
  Refreshes the cached settings values from the database.

  Calling this function causes the existing cached settings to be purged from
  the cache and the cache to be repopulated from the database using the
  datastore context provided to `start_link/1`.

  The `service_name` argument identifies which settings service instance should
  be used by the function.  See `start_link/1` and type documentation
  for `MsbmsSystSettings.Types.service_name()` for more.
  """
  @spec refresh_from_database(MsbmsSystSettings.Types.service_name()) :: :ok
  def refresh_from_database(service_name) do
    GenServer.call(service_name, :refresh)
  end

  @doc """
  Creates a new user defined setting.

  This function creates a setting which is automatically marked as being user
  defined.  User created settings such as those created by this function are the
  only kind of settings which may be deleted via `delete_setting/2`.

  The `service_name` argument identifies which settings service instance should
  be used by the function.  See `start_link/1` and type documentation
  for `MsbmsSystSettings.Types.service_name()` for more.

  The `creation_params` argument is a map defining the new settings record.  The
  map must contain the following keys:

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
  """
  @spec create_setting(
          MsbmsSystSettings.Types.service_name(),
          MsbmsSystSettings.Types.setting_params()
        ) ::
          :ok | {:error, MsbmsSystError.t()}
  def create_setting(service_name, creation_params) do
    GenServer.call(service_name, {:create, creation_params})
  end

  @doc """
  Sets the value of any one setting type for the named setting.

  The `service_name` argument identifies which settings service instance should
  be used by the function.  See `start_link/1` and type documentation
  for `MsbmsSystSettings.Types.service_name()` for more.

  The `setting_name` argument indicates the name of the setting to update with
  the new value.

  `setting_type` is the argument which tells the function which of the different
  available value types is being updated.

  The last argument, `setting_value` is the new value to set on the setting.
  Note that the setting value must be appropriate for the `setting_type`
  argument or an error will be raised.
  """
  @spec set_setting_value(
          MsbmsSystSettings.Types.service_name(),
          MsbmsSystSettings.Types.setting_name(),
          MsbmsSystSettings.Types.setting_types(),
          any()
        ) :: :ok | {:error, MsbmsSystError.t()}
  def set_setting_value(service_name, setting_name, setting_type, setting_value) do
    update_params = Map.put_new(%{}, setting_type, setting_value)
    GenServer.call(service_name, {:update, setting_name, update_params})
  end

  @doc """
  Sets one or more of the available setting types for the named setting.

  This function is similar to `set_setting_values/4`, except that multiple
  setting types can have their values set at the same time.  In addition to the
  typed setting values, the setting display name and/or user description values
  may also be set.

  The `service_name` argument identifies which settings service instance should
  be used by the function.  See `start_link/1` and type documentation
  for `MsbmsSystSettings.Types.service_name()` for more.

  The `setting_name` argument indicates the name of the setting to update with
  the new values.

  `update_params` is a map argument that complies with the
  `MsbmsSystSettings.Types.setting_service_params()` type specification and
  includes the updates to setting type values, updates to the `display_name`
  value, and/or updates to the `user_description` value.
  """
  @spec set_setting_values(
          MsbmsSystSettings.Types.service_name(),
          MsbmsSystSettings.Types.setting_name(),
          MsbmsSystSettings.Types.setting_service_params()
        ) :: :ok | {:error, MsbmsSystError.t()}
  def set_setting_values(service_name, setting_name, update_params) do
    GenServer.call(service_name, {:update, setting_name, update_params})
  end

  @doc """
  Retrieves the value of the given type for the requested setting.

  The `service_name` argument identifies which settings service instance should
  be used by the function.  See `start_link/1` and type documentation
  for `MsbmsSystSettings.Types.service_name()` for more.

  The `setting_name` argument indicates the name of the setting for which to
  retrieve a value.

  Argument `setting_type` indicates which of the various typed values to return.
  """
  @spec get_setting_value(
          MsbmsSystSettings.Types.service_name(),
          MsbmsSystSettings.Types.setting_name(),
          MsbmsSystSettings.Types.setting_types()
        ) :: any()
  defdelegate get_setting_value(service_name, setting_name, setting_type),
    to: Settings

  @doc """
  Retrieves all values associated with the requested setting.

  The `service_name` argument identifies which settings service instance should
  be used by the function.  See `start_link/1` and type documentation
  for `MsbmsSystSettings.Types.service_name()` for more.

  The `setting_name` argument indicates the name of the setting for which to
  retrieve values.

  The successful return of this function is an instance of the
  `MsbmsSystSettings.Data.SystSettings` struct containing the values requested.
  """
  @spec get_setting_values(
          MsbmsSystSettings.Types.service_name(),
          MsbmsSystSettings.Types.setting_name()
        ) :: MsbmsSystSettings.Data.SystSettings.t()
  defdelegate get_setting_values(service_name, setting_name), to: Settings

  @doc """
  Retrieves all values for all settings.

  This function returns all other setting metadata, such as the records' IDs,
  descriptions, etc.

  The `service_name` argument identifies which settings service instance should
  be used by the function.  See `start_link/1` and type documentation
  for `MsbmsSystSettings.Types.service_name()` for more.
  """
  @spec get_all_settings_values(MsbmsSystSettings.Types.service_name()) ::
          list(MsbmsSystSettings.Data.SystSettings)
  defdelegate get_all_settings_values(service_name), to: Settings

  @doc """
  Deletes the named user defined setting from the system.

  Note that this function cannot be used to delete a system defined setting.
  Trying to do so will result in a error being raised.

  The `service_name` argument identifies which settings service instance should
  be used by the function.  See `start_link/1` and type documentation
  for `MsbmsSystSettings.Types.service_name()` for more.

  The `setting_name` argument indicates the name of the setting should be
  deleted.
  """
  @spec delete_setting(
          MsbmsSystSettings.Types.service_name(),
          MsbmsSystSettings.Types.setting_name()
        ) :: :ok | {:error, MsbmsSystError.t()}
  def delete_setting(service_name, setting_name) do
    GenServer.call(service_name, {:delete, setting_name})
  end

  @doc """
  Terminates a running instance of the settings service.

  The `service_name` argument identifies which settings service instance should
  be used by the function.  See `start_link/1` and type documentation
  for `MsbmsSystSettings.Types.service_name()` for more.
  """
  @spec terminate_settings_service(MsbmsSystSettings.Types.service_name()) :: :ok
  def terminate_settings_service(service_name) do
    GenServer.stop(service_name, :normal)
  end
end
