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

  ##############################################################################
  #
  # Options Definition
  #
  #

  option_defs = [
    debug: [
      type: :boolean,
      doc: """
      If true, the GenServer backing the Settings Service will be started in
      debug mode.
      """
    ],
    timeout: [
      type: :timeout,
      default: :infinity,
      doc: "Timeout value for the start_link call."
    ],
    hibernate_after: [
      type: :timeout,
      doc: """
      If present, the GenServer process awaits any message for the specified
      time before hibernating.  The timeout value is expressed in Milliseconds.
      """
    ],
    datastore_context_name: [
      type:
        {:or,
         [nil, :atom, {:tuple, [{:in, [:via]}, :atom, :any]}, {:tuple, [{:in, [:global]}, :any]}]},
      type_doc: "`t:GenServer.name/0 or `nil`",
      doc: """
      Specifies the name of the Datastore Context to be used by the Settings
      Service.
      """
    ],
    service_name: [
      type:
        {:or,
         [nil, :atom, {:tuple, [{:in, [:via]}, :atom, :any]}, {:tuple, [{:in, [:global]}, :any]}]},
      type_doc: "`t:GenServer.name/0 or `nil`",
      doc: """
      The name to use for the GenServer backing this specific Settings Service
      instance.
      """
    ]
  ]

  ##############################################################################
  #
  # child_spec
  #
  #

  @child_spec_opts NimbleOptions.new!(
                     Keyword.take(option_defs, [
                       :service_name,
                       :datastore_context_name,
                       :debug,
                       :timeout,
                       :hibernate_after
                     ])
                   )

  @doc section: :service_management
  @doc """
  Returns a child specification for the Settings Service.

  ## Parameters

    * `opts` - A keyword list of options.  See the `Options` section for
      details.

  ## Options

  #{NimbleOptions.docs(@child_spec_opts)}

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
  def child_spec(opts) do
    opts = NimbleOptions.validate!(opts, @child_spec_opts)
    Runtime.Service.child_spec(opts)
  end

  ##############################################################################
  #
  # start_link
  #
  #

  @start_link_opts NimbleOptions.new!(
                     Keyword.take(option_defs, [:debug, :timeout, :hibernate_after])
                   )

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

  #{NimbleOptions.docs(@start_link_opts)}
  """
  @spec start_link(Types.service_name(), MscmpSystDb.Types.context_service_name()) ::
          {:ok, pid()} | {:error, MscmpSystError.t()}
  @spec start_link(Types.service_name(), MscmpSystDb.Types.context_service_name(), Keyword.t()) ::
          {:ok, pid()} | {:error, MscmpSystError.t()}
  def start_link(service_name, datastore_context_name, opts \\ []) do
    case NimbleOptions.validate(opts, @start_link_opts) do
      {:ok, validated_opts} ->
        Runtime.Service.start_link(service_name, datastore_context_name, validated_opts)

      {:error, error} ->
        {:error,
         %MscmpSystError{
           code: :parameter_error,
           message: "Option validation error",
           cause: error
         }}
    end
  end

  ##############################################################################
  #
  # refresh_from_database
  #
  #

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
    do: Runtime.ProcessUtils.get_service() |> GenServer.call(:refresh)

  ##############################################################################
  #
  # put_service
  #
  #

  @doc section: :service_management
  @doc """
  Establishes the currently active Settings Service instance for the current
  process.

  ## Parameters

    * `settings_service_name` - the canonical name of the specific Settings
    Service to access.  When this function is called with a non-nil argument,
    calls to Settings related functions will make use of the Settings Service
    specified here.  Setting this value to `nil` will clear the currently
    active Settings Service for the process.  Any calls to Settings related
    functions will fail until a new Settings Service is designated for the
    process using this function with a non-nil argument.

  ## Examples

    Setting a specific Settings Service name:

      iex> MscmpSystSettings.put_service(:"MscmpSystSettings.TestSupportService")
      ...> MscmpSystSettings.get_service()
      :"MscmpSystSettings.TestSupportService"

    Clearing a previously set specific Service Name:

      iex> MscmpSystSettings.put_service(nil)
      ...> MscmpSystSettings.get_service()
      nil
  """
  @spec put_service(GenServer.name() | nil) :: GenServer.name() | nil
  defdelegate put_service(settings_service_name), to: Runtime.ProcessUtils

  ##############################################################################
  #
  # get_service
  #
  #

  @doc section: :service_management
  @doc """
  Retrieve the current specific Settings Service name in effect for the process.

  This function returns the name of the Settings Service that has been using the
  `put_service/1` function to override the default Settings Service
  associated with the Instance Name. If no specific Settings Service name has
  been set, this function will return `nil`.

  ## Examples

    Retrieving a specific Settings Service name:

      iex> MscmpSystSettings.put_service(:"MscmpSystSettings.TestSupportService")
      ...> MscmpSystSettings.get_service()
      :"MscmpSystSettings.TestSupportService"

    Retrieving a specific Settings Service name when no value is currently set
    for the process:

      iex> MscmpSystSettings.put_service(nil)
      ...> MscmpSystSettings.get_service()
      nil
  """
  @spec get_service() :: atom() | nil
  defdelegate get_service(), to: Runtime.ProcessUtils

  ##############################################################################
  #
  # create
  #
  #

  @doc section: :settings_data
  @doc """
  Creates a new user defined setting.

  This function creates a setting which is automatically marked as being user
  defined.  User created settings such as those created by this function are the
  only kind of settings which may be deleted via `delete/2`.

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
      iex> MscmpSystSettings.create(new_setting)
      :ok
  """
  @spec create(MscmpSystSettings.Types.setting_params()) ::
          :ok | {:error, MscmpSystError.t()}
  def create(creation_params),
    do: Runtime.ProcessUtils.get_service() |> GenServer.call({:create, creation_params})

  ##############################################################################
  #
  # set_value
  #
  #

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

      iex> MscmpSystSettings.set_value(
      ...>   "set_example_setting",
      ...>   :setting_decimal,
      ...>   Decimal.new("1029.3847"))
      :ok
  """
  @spec set_value(
          MscmpSystSettings.Types.setting_name(),
          MscmpSystSettings.Types.setting_types(),
          any()
        ) :: :ok | {:error, MscmpSystError.t()}
  def set_value(setting_name, setting_type, setting_value) do
    update_params = Map.put_new(%{}, setting_type, setting_value)

    Runtime.ProcessUtils.get_service()
    |> GenServer.call({:update, setting_name, update_params})
  end

  ##############################################################################
  #
  # set_values
  #
  #

  @doc section: :settings_data
  @doc """
  Sets one or more of the available setting types for the named setting.

  This function is similar to `set_values/4`, except that multiple
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
      iex> MscmpSystSettings.set_values(
      ...>   "set_example_setting",
      ...>   update_values)
      :ok
  """
  @spec set_values(
          MscmpSystSettings.Types.setting_name(),
          MscmpSystSettings.Types.setting_params()
        ) :: :ok | {:error, MscmpSystError.t()}
  def set_values(setting_name, update_params) do
    Runtime.ProcessUtils.get_service()
    |> GenServer.call({:update, setting_name, update_params})
  end

  ##############################################################################
  #
  # get_value
  #
  #

  @doc section: :settings_data
  @doc """
  Retrieves the value of the given type for the requested setting.

  ## Parameters
  * `setting_name` - the name of the setting for which to retrieve a value.

  * `setting_type` - the type of value which to return.

  ## Examples

      iex> MscmpSystSettings.get_value(
      ...>   "get_example_setting",
      ...>   :setting_decimal_range)
      %MscmpSystDb.DbTypes.DecimalRange{
        lower: Decimal.new("1.1"),
        upper: Decimal.new("99.99"),
        lower_inclusive: true,
        upper_inclusive: false
      }
  """
  @spec get_value(
          MscmpSystSettings.Types.setting_name(),
          MscmpSystSettings.Types.setting_types()
        ) :: any()
  defdelegate get_value(setting_name, setting_type),
    to: Impl.Settings

  ##############################################################################
  #
  # get_values
  #
  #

  @doc section: :settings_data
  @doc """
  Retrieves all values associated with the requested setting.

  ## Parameters

    * `setting_name` - the name of the setting for which to retrieve values.

  The successful return of this function is an instance of the
  `Msdata.SystSettings` struct containing the values requested.

  ## Examples

      iex> MscmpSystSettings.get_values("get_example_setting")
  """
  @spec get_values(MscmpSystSettings.Types.setting_name()) :: Msdata.SystSettings.t()
  defdelegate get_values(setting_name), to: Impl.Settings

  ##############################################################################
  #
  # list_all
  #
  #

  @doc section: :settings_data
  @doc """
  Retrieves all values for all settings.

  This function returns all other setting metadata, such as the records' IDs,
  descriptions, etc.

  ## Examples

      iex> MscmpSystSettings.list_all()
  """
  @spec list_all() :: list(Msdata.SystSettings)
  defdelegate list_all(), to: Impl.Settings

  ##############################################################################
  #
  # delete
  #
  #

  @doc section: :settings_data
  @doc """
  Deletes the named user defined setting from the system.

  Note that this function cannot be used to delete a system defined setting.
  Trying to do so will result in a error being raised.

  ## Parameters

    * `setting_name` - the name of the setting should be deleted.

  ## Examples

      iex> MscmpSystSettings.delete("delete_example_setting")
      :ok
  """
  @spec delete(MscmpSystSettings.Types.setting_name()) ::
          :ok | {:error, MscmpSystError.t()}
  def delete(setting_name),
    do: Runtime.ProcessUtils.get_service() |> GenServer.call({:delete, setting_name})

  ##############################################################################
  #
  # terminate_service
  #
  #

  @doc section: :service_management
  @doc """
  Terminates a running instance of the settings service.

  ## Examples

      > MscmpSystSettings.terminate_service()
      :ok
  """
  @spec terminate_service() :: :ok
  def terminate_service,
    do: Runtime.ProcessUtils.get_service() |> GenServer.stop(:normal)
end
