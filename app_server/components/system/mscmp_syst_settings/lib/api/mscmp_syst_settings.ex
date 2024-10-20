# Source File: mscmp_syst_settings.ex
# Location:    musebms/app_server/components/system/mscmp_syst_settings/lib/api/mscmp_syst_settings.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystSettings do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias MscmpSystSettings.Impl.Settings
  alias MscmpSystSettings.Runtime.DevSupport
  alias MscmpSystSettings.Runtime.ProcessUtils

  @doc section: :service_management
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
  `MscmpSystDb` context.  This context will be used for accessing and
  modifying database data.
  """
  @spec start_link({MscmpSystSettings.Types.service_name(), MscmpSystDb.Types.context_name()}) ::
          {:ok, pid()} | {:error, MscmpSystError.t()}
  defdelegate start_link(params), to: MscmpSystSettings.Runtime.Server

  @doc section: :service_management
  @doc """
  Establishes the current Settings Service instance for the process.

  A running system is likely to have more than one instance of the Settings
  Service running.  For example, in multi-tenant applications each tenant may
  have its own instance of the Setting Service, caching data unique to the
  tenant.

  Calling `MscmpSystSettings.put_settings_service/1` will set the reference to
  the desired Settings Service instance for any subsequent MscmpSystSettings
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

      iex> MscmpSystSettings.put_settings_service(:settings_test_service)
  """
  @spec put_settings_service(MscmpSystSettings.Types.service_name() | nil) ::
          MscmpSystSettings.Types.service_name() | nil
  defdelegate put_settings_service(service_name), to: ProcessUtils

  @doc section: :service_management
  @doc """
  Retrieves the currently set Settings Service name or `nil` if none has been
  set.

  ## Examples

      iex> MscmpSystSettings.get_settings_service()
      :settings_test_service
  """
  @spec get_settings_service() :: MscmpSystSettings.Types.service_name() | nil
  defdelegate get_settings_service(), to: ProcessUtils

  @doc section: :service_management
  @doc """
  Refreshes the cached settings values from the database.

  Calling this function causes the existing cached settings to be purged from
  the cache and the cache to be repopulated from the database using the
  datastore context provided to `start_link/1`.

  ## Examples

      iex> MscmpSystSettings.refresh_from_database()
      :ok

  """
  @spec refresh_from_database() :: :ok
  def refresh_from_database do
    GenServer.call(ProcessUtils.get_settings_service(), :refresh)
  end

  @doc section: :settings_data
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
      iex> MscmpSystSettings.create_setting(new_setting)
      :ok
  """
  @spec create_setting(MscmpSystSettings.Types.setting_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def create_setting(creation_params) do
    GenServer.call(ProcessUtils.get_settings_service(), {:create, creation_params})
  end

  @doc section: :settings_data
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

      iex> MscmpSystSettings.set_setting_value(
      ...>   "set_example_setting",
      ...>   :setting_decimal,
      ...>   Decimal.new("1029.3847"))
      :ok
  """
  @spec set_setting_value(
          MscmpSystSettings.Types.setting_name(),
          MscmpSystSettings.Types.setting_types(),
          any()
        ) :: :ok | {:error, MscmpSystError.t()}
  def set_setting_value(setting_name, setting_type, setting_value) do
    update_params = Map.put_new(%{}, setting_type, setting_value)
    GenServer.call(ProcessUtils.get_settings_service(), {:update, setting_name, update_params})
  end

  @doc section: :settings_data
  @doc """
  Sets one or more of the available setting types for the named setting.

  This function is similar to `set_setting_values/4`, except that multiple
  setting types can have their values set at the same time.  In addition to the
  typed setting values, the setting display name and/or user description values
  may also be set.

  ## Parameters

    * `setting_name` - the name of the setting to update with the new values.

    * `update_params` - is a map that complies with the
      `MscmpSystSettings.Types.setting_service_params()` type specification and
      includes the updates to setting type values, updates to the `display_name`
      value, and/or updates to the `user_description` value.

  ## Examples

      iex> update_values = %{
      ...>   user_description: "An example of updating the user description.",
      ...>   setting_integer: 6758,
      ...>   setting_date_range:
      ...>      %MscmpSystDb.DbTypes.DateRange{
      ...>        lower: ~D[2022-04-01],
      ...>        upper: ~D[2022-04-12],
      ...>        upper_inclusive: true
      ...>      }
      ...> }
      iex> MscmpSystSettings.set_setting_values(
      ...>   "set_example_setting",
      ...>   update_values)
      :ok
  """
  @spec set_setting_values(
          MscmpSystSettings.Types.setting_name(),
          MscmpSystSettings.Types.setting_service_params()
        ) :: :ok | {:error, MscmpSystError.t()}
  def set_setting_values(setting_name, update_params) do
    GenServer.call(ProcessUtils.get_settings_service(), {:update, setting_name, update_params})
  end

  @doc section: :settings_data
  @doc """
  Retrieves the value of the given type for the requested setting.

  ## Parameters
  * `setting_name` - the name of the setting for which to retrieve a value.

  * `setting_type` - the type of value which to return.

  ## Examples

      iex> MscmpSystSettings.get_setting_value(
      ...>   "get_example_setting",
      ...>   :setting_decimal_range)
      %MscmpSystDb.DbTypes.DecimalRange{
        lower: Decimal.new("1.1"),
        upper: Decimal.new("99.99"),
        lower_inclusive: true,
        upper_inclusive: false
      }
  """
  @spec get_setting_value(
          MscmpSystSettings.Types.setting_name(),
          MscmpSystSettings.Types.setting_types()
        ) :: any()
  defdelegate get_setting_value(setting_name, setting_type),
    to: Settings

  @doc section: :settings_data
  @doc """
  Retrieves all values associated with the requested setting.

  ## Parameters

    * `setting_name` - the name of the setting for which to retrieve values.

  The successful return of this function is an instance of the
  `Msdata.SystSettings` struct containing the values requested.

  ## Examples

      iex> MscmpSystSettings.get_setting_values("get_example_setting")
  """
  @spec get_setting_values(MscmpSystSettings.Types.setting_name()) :: Msdata.SystSettings.t()
  defdelegate get_setting_values(setting_name), to: Settings

  @doc section: :settings_data
  @doc """
  Retrieves all values for all settings.

  This function returns all other setting metadata, such as the records' IDs,
  descriptions, etc.

  ## Examples

      iex> MscmpSystSettings.list_all_settings()
  """
  @spec list_all_settings() :: list(Msdata.SystSettings)
  defdelegate list_all_settings(), to: Settings

  @doc section: :settings_data
  @doc """
  Deletes the named user defined setting from the system.

  Note that this function cannot be used to delete a system defined setting.
  Trying to do so will result in a error being raised.

  ## Parameters

    * `setting_name` - the name of the setting should be deleted.

  ## Examples

      iex> MscmpSystSettings.delete_setting("delete_example_setting")
      :ok
  """
  @spec delete_setting(MscmpSystSettings.Types.setting_name()) ::
          :ok | {:error, MscmpSystError.t()}
  def delete_setting(setting_name) do
    GenServer.call(ProcessUtils.get_settings_service(), {:delete, setting_name})
  end

  @doc section: :service_management
  @doc """
  Terminates a running instance of the settings service.

  ## Examples

      > MscmpSystSettings.terminate_settings_service()
      :ok
  """
  @spec terminate_settings_service() :: :ok
  def terminate_settings_service do
    GenServer.stop(ProcessUtils.get_settings_service(), :normal)
  end

  @doc section: :development_support
  @doc """
  Starts a Settings Service instance for the purposes of supporting interactive
  development or testing activities.

  >#### Not for Production {: .warning}
  >
  > This operation is specifically intended to support development and testing
  > activities and should not be used by code which runs in production
  > environments.

  ## Parameters

    * `opts` - a `t:Keyword.t/0` list of optional parameters which can override
      default values for service parameters.  The available options are:

      * `childspec_id` - the ID value used in defining a Child Specification for
        the service. This is an atom value which defaults to
        `MscmpSystSettings`.

      * `supervisor_name` - the name of the `DynamicSupervisor` which will
        will supervise the Settings Service.  This is an atom value which
        defaults to `MscmpSystSettings.DevSupportSupervisor`.

      * `service_name` - the name of the Settings Service instance.  This is the
        value by which the specific Settings Service may be set using functions
        such as `put_settings_service/1`.  This is an atom value which defaults
        to the value returned by `get_devsupport_service_name/0`.

      * `datastore_context` - the name of the login Datastore Context which can
        access the database storage backing the Settings Service.  This is an
        atom value which defaults to the value returned by
        `MscmpSystDb.get_devsupport_context_name/0`.
  """
  @spec start_support_services(keyword()) ::
          :ignore | {:error, any()} | {:ok, pid()} | {:ok, pid(), any()}
  defdelegate start_support_services(opts \\ []), to: DevSupport

  @doc section: :development_support
  @doc """
  Starts a Settings Service instance for the purposes of supporting interactive
  development activities.

  >#### Not for Production {: .warning}
  >
  > This operation is specifically intended to support development and should
  > not be used by code which runs in production environments.

  Currently this function simply redirects to `start_support_services/1`.

  ## Parameters

    * `opts` - a `t:Keyword.t/0` list of optional parameters which can override
      default values for service parameters.  The available options and their
      defaults are the same as `start_support_services/1`.
  """
  @spec start_devsupport_services(keyword()) ::
          :ignore | {:error, any()} | {:ok, pid()} | {:ok, pid(), any()}
  defdelegate start_devsupport_services(opts \\ []), to: DevSupport, as: :start_support_services

  @doc section: :development_support
  @doc """
  Starts a Settings Service instance for the purposes of supporting testing
  activities.

  >#### Not for Production {: .warning}
  >
  > This operation is specifically intended to support testing activities and
  > should not be used by code which runs in production environments.

  ## Parameters

    * `opts` - a `t:Keyword.t/0` list of optional parameters which can override
      default values for service parameters.  The available options are:

      * `childspec_id` - the ID value used in defining a Child Specification for
        the service. This is an atom value which defaults to
        `MscmpSystSettings`.

      * `supervisor_name` - the name of the `DynamicSupervisor` which will
        will supervise the Settings Service.  This is an atom value which
        defaults to `MscmpSystSettings.TestSupportSupervisor`.

      * `service_name` - the name of the Settings Service instance.  This is the
        value by which the specific Settings Service may be set using functions
        such as `put_settings_service/1`.  This is an atom value which defaults
        to the value returned by `get_testsupport_service_name/0`.

      * `datastore_context` - the name of the login Datastore Context which can
        access the database storage backing the Settings Service.  This is an
        atom value which defaults to the value returned by
        `MscmpSystDb.get_testsupport_context_name/0`.
  """
  @spec start_testsupport_services(keyword()) ::
          :ignore | {:error, any()} | {:ok, pid()} | {:ok, pid(), any()}
  defdelegate start_testsupport_services(opts \\ []), to: DevSupport

  @doc section: :development_support
  @doc """
  Retrieves the Settings Service Name typically used to support development.

  This is a way to retrieve the standard development support name for use with
  functions such as `put_settings_service/1`
  """
  @spec get_devsupport_service_name() :: atom()
  defdelegate get_devsupport_service_name, to: DevSupport

  @doc section: :development_support
  @doc """
  Retrieves the Settings Service Name typically used to support testing.

  This is a way to retrieve the standard testing support name for use with
  functions such as `put_settings_service/1`
  """
  @spec get_testsupport_service_name() :: atom()
  defdelegate get_testsupport_service_name, to: DevSupport
end
