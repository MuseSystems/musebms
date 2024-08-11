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

  alias MscmpSystSettings.Impl
  alias MscmpSystSettings.Runtime
  alias MscmpSystSettings.Types

  @doc section: :service_management
  @doc """
  Returns a child specification for the Settings Service.

  ## Parameters

    * `opts` - A keyword list of options.  See the `Options` section for
      details.

  ## Options

  #{Runtime.Service.get_child_spec_opts_docs()}

  ## Examples

      iex> MscmpSystSettings.child_spec(
      ...>   service_name: MyApp.SettingsService,
      ...>   datastore_context_name: MyApp.DatastoreContext)
      %{
        id: MscmpSystSettings.Runtime.Service,
        start:
          {MscmpSystSettings,
           :start_link,
           [MyApp.SettingsService, MyApp.DatastoreContext, [timeout: :infinity]]},
      }

  """
  @spec child_spec(Keyword.t()) :: Supervisor.child_spec()
  defdelegate child_spec(opts), to: Runtime.Service

  @doc section: :service_management
  @doc """
  Starts an instance of the Settings Service.

  Starting the service establishes the required processes and pre-populates the
  service cache with data from the database.  Most other functions in this
  module require that the service is started prior to use and will fail if the
  service is not started.

  ## Parameters

    * `service_name` - The name of the Settings Service.

    * `datastore_context_name` - The name of the Datastore Context to be used by
      the Settings Service.

    * `opts` - Options for the Settings Service. See the Options section below
      for more information.

  ## Options

  #{Runtime.Service.get_start_link_opts_docs()}
  """
  @spec start_link(Types.service_name(), MscmpSystDb.Types.context_service_name()) ::
          {:ok, pid()} | {:error, MscmpSystError.t()}
  @spec start_link(Types.service_name(), MscmpSystDb.Types.context_service_name(), Keyword.t()) ::
          {:ok, pid()} | {:error, MscmpSystError.t()}
  defdelegate start_link(service_name, datastore_context_name, opts \\ []), to: Runtime.Service

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
  def refresh_from_database,
    do: Runtime.ProcessUtils.get_settings_service() |> GenServer.call(:refresh)

  @doc section: :service_management
  @doc """
  An optional method for establishing a specific, named Settings Service to
  access by the current process.

  In some cases it may be desirable to establish an instance of the Settings
  Service outside of the constraints the "Instance Name" as defined by
  `MscmpSystUtils`. In such cases, this function can be used to set a current
  Settings Service instance for the current process which will access the named
  Settings Service directly rather than the Settings Service associated with the
  prevailing named Instance.  See `MscmpSystUtils` for more about establishing
  an instance identity with a given process.

  > #### Limited Use Cases {: .tip}
  >
  > Under most circumstances the correct Settings Service instance to access
  > will be determined by the prevailing Instance Name as managed by calls to
  > `MscmpSystUtils.put_instance_name/1` and `MscmpSystUtils.get_instance_name/0`,
  > meaning that typically calls to `put_settings_service/1` are not necessary.
  >
  > The only time this function is required is when an alternative Settings
  > Service should be accessed or there is no Instance Name to set for the
  > process using `MscmpSystUtils.put_instance_name/1`.

  ## Parameters

    * `settings_service_name` - the canonical name of the specific Settings
    Service to access.  When this function is called with a non-nil argument,
    calls to Settings related functions will make use of the Settings Service
    specified here, overriding any Settings Service which may be started derived
    from the Instance Name.  Setting this value to `nil` will clear the special
    Settings Service name and revert to using the Settings Service associated
    with the Instance Name, if one has been set.

  ## Examples

    Setting a specific Settings Service name:

      iex> MscmpSystSettings.put_settings_service(:"MscmpSystSettings.TestSupportService")
      ...> MscmpSystSettings.get_settings_service()
      :"MscmpSystSettings.TestSupportService"

    Clearing a previously set specific Service Name:

      iex> MscmpSystSettings.put_settings_service(nil)
      ...> MscmpSystSettings.get_settings_service()
      nil
  """
  @spec put_settings_service(GenServer.name() | nil) :: GenServer.name() | nil
  defdelegate put_settings_service(settings_service_name), to: Runtime.ProcessUtils

  @doc section: :service_management
  @doc """
  Retrieve the current specific Settings Service name in effect for the process.

  This function returns the name of the Settings Service that has been using the
  `put_settings_service/1` function to override the default Settings Service
  associated with the Instance Name. If no specific Settings Service name has
  been set, this function will return `nil`.

  ## Examples

    Retrieving a specific Settings Service name:

      iex> MscmpSystSettings.put_settings_service(:"MscmpSystSettings.TestSupportService")
      ...> MscmpSystSettings.get_settings_service()
      :"MscmpSystSettings.TestSupportService"

    Retrieving a specific Settings Service name when no value is currently set
    for the process:

      iex> MscmpSystSettings.put_settings_service(nil)
      ...> MscmpSystSettings.get_settings_service()
      nil
  """
  @spec get_settings_service() :: atom() | nil
  defdelegate get_settings_service(), to: Runtime.ProcessUtils

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
  def create_setting(creation_params),
    do: Runtime.ProcessUtils.get_settings_service() |> GenServer.call({:create, creation_params})

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

    Runtime.ProcessUtils.get_settings_service()
    |> GenServer.call({:update, setting_name, update_params})
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
      `t:MscmpSystSettings.Types.setting_params/0` type specification and
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
          MscmpSystSettings.Types.setting_params()
        ) :: :ok | {:error, MscmpSystError.t()}
  def set_setting_values(setting_name, update_params) do
    Runtime.ProcessUtils.get_settings_service()
    |> GenServer.call({:update, setting_name, update_params})
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
    to: Impl.Settings

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
  defdelegate get_setting_values(setting_name), to: Impl.Settings

  @doc section: :settings_data
  @doc """
  Retrieves all values for all settings.

  This function returns all other setting metadata, such as the records' IDs,
  descriptions, etc.

  ## Examples

      iex> MscmpSystSettings.list_all_settings()
  """
  @spec list_all_settings() :: list(Msdata.SystSettings)
  defdelegate list_all_settings(), to: Impl.Settings

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
  def delete_setting(setting_name),
    do: Runtime.ProcessUtils.get_settings_service() |> GenServer.call({:delete, setting_name})

  @doc section: :service_management
  @doc """
  Terminates a running instance of the settings service.

  ## Examples

      > MscmpSystSettings.terminate_settings_service()
      :ok
  """
  @spec terminate_settings_service() :: :ok
  def terminate_settings_service,
    do: Runtime.ProcessUtils.get_settings_service() |> GenServer.stop(:normal)

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
      default values for service parameters.

  ## Options

    #{Runtime.DevSupport.get_devsupport_opts_docs()}
  """
  @spec start_support_services() :: :ok
  @spec start_support_services(keyword()) :: :ok
  defdelegate start_support_services(opts \\ []), to: Runtime.DevSupport

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
      default values for service parameters.

  ## Options

    #{Runtime.DevSupport.get_devsupport_opts_docs()}
  """
  @spec start_devsupport_services() :: :ok
  @spec start_devsupport_services(keyword()) :: :ok
  defdelegate start_devsupport_services(opts \\ []),
    to: Runtime.DevSupport,
    as: :start_support_services

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
      default values for service parameters.

  ## Options

    #{Runtime.DevSupport.get_testsupport_opts_docs()}
  """
  @spec start_testsupport_services() :: :ok
  @spec start_testsupport_services(keyword()) :: :ok
  defdelegate start_testsupport_services(opts \\ []), to: Runtime.DevSupport

  @doc section: :development_support
  @doc """
  Stops previously started Settings support services.

  ## Parameters

    * `opts` - a `t:Keyword.t/0` list of optional parameters.

  ## Options

    #{Runtime.DevSupport.get_devsupport_stop_opts_docs()}
  """
  @spec stop_support_services() :: :ok
  @spec stop_support_services(keyword()) :: :ok
  defdelegate stop_support_services(opts \\ []), to: Runtime.DevSupport

  @doc section: :development_support
  @doc """
  Stops previously started Settings development support services.

  ## Parameters

    * `opts` - a `t:Keyword.t/0` list of optional parameters.  See `Options` for
      details.

  ## Options

    #{Runtime.DevSupport.get_devsupport_stop_opts_docs()}
  """
  @spec stop_devsupport_services() :: :ok
  @spec stop_devsupport_services(keyword()) :: :ok
  defdelegate stop_devsupport_services(opts \\ []),
    to: Runtime.DevSupport,
    as: :stop_support_services

  @doc section: :development_support
  @doc """
  Stops previously started Settings testing support services.

  ## Parameters

    * `opts` - a `t:Keyword.t/0` list of optional parameters.

  ## Options

    #{Runtime.DevSupport.get_testsupport_stop_opts_docs()}
  """
  @spec stop_testsupport_services() :: :ok
  @spec stop_testsupport_services(keyword()) :: :ok
  defdelegate stop_testsupport_services(opts \\ []),
    to: Runtime.DevSupport

  @doc section: :development_support
  @doc """
  Returns the name of the development support service.
  """
  @spec get_devsupport_service_name() :: atom()
  defdelegate get_devsupport_service_name, to: Runtime.DevSupport

  @doc section: :development_support
  @doc """
  Returns the name of the test support service.
  """
  @spec get_testsupport_service_name() :: atom()
  defdelegate get_testsupport_service_name, to: Runtime.DevSupport
end
