defmodule MsbmsSystOptions do
  @moduledoc """
  API for retrieving and working with option files stored in the application server file system.
  """

  alias MsbmsSystOptions.Impl.OptionsFile
  alias MsbmsSystOptions.Impl.OptionsParser
  alias MsbmsSystOptions.Types

  @doc section: :file_handling
  @doc """
  Parses and returns the contents of a TOML file at `options_file_path` via a
  result tuple.

  If successful a tuple with a first value of `:ok` and second value containing
  a map of the options is returned.  When errors are found, a tuple with a first
  value of `:error` and second value of the relevant `MscmpSystError` exception
  is returned.

  ## Parameters

    * `options_file_path` - describes where to find the options file in the file
    system.

  ## Examples

  Typical call and return:

      iex> MsbmsSystOptions.get_options("./testing_options.toml")
      {
        :ok,
        %{
          dbserver: [
            %{
              db_host: "127.0.0.1",
              db_max_instances: 0,
              db_port: 5432,
              db_show_sensitive: true,
              dbadmin_password: "default.msbms.privileged.password",
              dbadmin_pool_size: 1,
              server_name: "global_db",
              server_salt: "sklMRkLXzMQgzqpMpJZPk31Js88su39U/mooAXALhj0=",
              start_server_instances: false,
              server_pools: []
            },
            %{
              db_host: "127.0.0.1",
              db_max_instances: 30,
              db_port: 5432,
              db_show_sensitive: true,
              dbadmin_password: "default.msbms.privileged.password",
              dbadmin_pool_size: 1,
              server_name: "instance_db",
              server_salt: "w1OfRx630x7svid8Tk3L9rLL1eEGSm0fq8XcLdveuSs=",
              start_server_instances: true,
              server_pools: ["primary", "linked", "demo", "reserved"]
            }
          ],
          available_server_pools: ["primary", "linked", "demo", "reserved"],
          global_dbserver_name: "global_db",
          global_pepper_value: "jTtEdXRExP5YXHeARQ1W66lP6wDc9GyOvhFPvwnHhtc="
        }
      }

  Called with bad parameters:

      iex> {:error, %MscmpSystError{}} =
      ...>   MsbmsSystOptions.get_options("./bad_file_name.toml")
  """
  @spec get_options(String.t()) :: {:ok, map()} | {:error, MscmpSystError.t()}
  defdelegate get_options(options_file_path), to: OptionsFile

  @doc section: :file_handling
  @doc """
  Parses and returns the contents of a TOML file at `options_file_path` or
  raises.

  The returned options will be in a map equivalent to the TOML file's structure.

  ## Examples

  Typical call and return:

      iex> MsbmsSystOptions.get_options!("./testing_options.toml")
      %{
        dbserver: [
          %{
            db_host: "127.0.0.1",
            db_max_instances: 0,
            db_port: 5432,
            db_show_sensitive: true,
            dbadmin_password: "default.msbms.privileged.password",
            dbadmin_pool_size: 1,
            server_name: "global_db",
            server_salt: "sklMRkLXzMQgzqpMpJZPk31Js88su39U/mooAXALhj0=",
            start_server_instances: false,
            server_pools: []
          },
          %{
            db_host: "127.0.0.1",
            db_max_instances: 30,
            db_port: 5432,
            db_show_sensitive: true,
            dbadmin_password: "default.msbms.privileged.password",
            dbadmin_pool_size: 1,
            server_name: "instance_db",
            server_salt: "w1OfRx630x7svid8Tk3L9rLL1eEGSm0fq8XcLdveuSs=",
            start_server_instances: true,
            server_pools: ["primary", "linked", "demo", "reserved"]
          }
        ],
        available_server_pools: ["primary", "linked", "demo", "reserved"],
        global_dbserver_name: "global_db",
        global_pepper_value: "jTtEdXRExP5YXHeARQ1W66lP6wDc9GyOvhFPvwnHhtc="
      }

  Called with bad parameters:

      iex> MsbmsSystOptions.get_options!("./bad_file_name.toml")
      ** (MscmpSystError) Problem reading options file './bad_file_name.toml'.
  """
  @spec get_options!(String.t()) :: map()
  defdelegate get_options!(options_file_path), to: OptionsFile

  @doc section: :options_parsing
  @doc """
  Returns the name of the database server which hosts the global database.

  ## Parameters

    * `options` - the options file data as read by `get_options/1`.

  ## Examples

      iex> config_options = MsbmsSystOptions.get_options!("./testing_options.toml")
      iex> MsbmsSystOptions.get_global_dbserver_name(config_options)
      "global_db"
  """
  @spec get_global_dbserver_name(map()) :: String.t()
  defdelegate get_global_dbserver_name(options), to: OptionsParser

  @doc section: :options_parsing
  @doc """
  Returns the `t:MscmpSystDb.Types.db_server/0` data for the database
  server designated as hosting the global database.

  ## Parameters

    * `options` - the options file data as read by `get_options/1`.

  ## Examples
      iex> config_options = MsbmsSystOptions.get_options!("./testing_options.toml")
      iex> %{server_name: "global_db"} = MsbmsSystOptions.get_global_dbserver(config_options)

  """
  @spec get_global_dbserver(map()) :: MscmpSystDb.Types.db_server()
  defdelegate get_global_dbserver(options), to: OptionsParser

  @doc section: :options_parsing
  @doc """
  Returns the configured global server "pepper" value for use in some automatic
  account creation scenarios.

  > #### Note {: .warning}
  >
  > While this is the way the system is built today, the suspicion is that the
  > approach we're currently taking with automatic account creation is better
  > than no effort for security, but probably not by much.  In other words, this
  > is not an example for how to build a robust security system, but should do
  > until there's actual public deployment of the application.

  ## Parameters

    * `options` - the options file data as read by `get_options/1`.

  ## Examples
      iex> config_options = MsbmsSystOptions.get_options!("./testing_options.toml")
      iex> MsbmsSystOptions.get_global_pepper_value(config_options)
      "jTtEdXRExP5YXHeARQ1W66lP6wDc9GyOvhFPvwnHhtc="
  """
  @spec get_global_pepper_value(map()) :: binary()
  defdelegate get_global_pepper_value(options), to: OptionsParser

  @doc section: :options_parsing
  @doc """
  Returns the list of available server pools configured in the options file.

  ## Parameters

    * `options` - the options file data as read by `get_options/1`.

  ## Examples
      iex> config_options = MsbmsSystOptions.get_options!("./testing_options.toml")
      iex> MsbmsSystOptions.list_available_server_pools(config_options)
      ["primary", "linked", "demo", "reserved"]
  """
  @spec list_available_server_pools(map()) :: list(Types.server_pool())
  defdelegate list_available_server_pools(options), to: OptionsParser

  @doc section: :options_parsing
  @doc """
  Extracts the list of configured dbservers in the options file, optionally
  filtered by the server's supported instance classes.

  ## Parameters

    * `options` - the options file data as read by `get_options/1`.

    * `filters` - a list one or more instance class values with with to filter
    the database servers list.  The valid instance classes are: "primary",
    "linked", "demo", and "reserved".  An empty list of filter values returns
    all database servers, including those that have no supported instance
    classes (this is common for global database host servers).  The `filters`
    values defaults to the empty list if not explicitly provided.

  ## Examples

  Calling without filters:

      iex> config_options = MsbmsSystOptions.get_options!("./testing_options.toml")
      iex> [_ | _] = MsbmsSystOptions.list_dbservers(config_options)
      [
        %{
          db_host: "127.0.0.1",
          db_max_instances: 0,
          db_port: 5432,
          db_show_sensitive: true,
          dbadmin_password: "default.msbms.privileged.password",
          dbadmin_pool_size: 1,
          server_name: "global_db",
          server_salt: "sklMRkLXzMQgzqpMpJZPk31Js88su39U/mooAXALhj0=",
          start_server_instances: false,
          server_pools: []
        },
        %{
          db_host: "127.0.0.1",
          db_max_instances: 30,
          db_port: 5432,
          db_show_sensitive: true,
          dbadmin_password: "default.msbms.privileged.password",
          dbadmin_pool_size: 1,
          server_name: "instance_db",
          server_salt: "w1OfRx630x7svid8Tk3L9rLL1eEGSm0fq8XcLdveuSs=",
          start_server_instances: true,
          server_pools: ["primary", "linked", "demo", "reserved"]
        }
      ]

  Calling with filters:

      iex> config_options = MsbmsSystOptions.get_options!("./testing_options.toml")
      iex> [_ | _] = MsbmsSystOptions.list_dbservers(config_options, ["primary"])
      [
        %{
          db_host: "127.0.0.1",
          db_max_instances: 30,
          db_port: 5432,
          db_show_sensitive: true,
          dbadmin_password: "default.msbms.privileged.password",
          dbadmin_pool_size: 1,
          server_name: "instance_db",
          server_salt: "w1OfRx630x7svid8Tk3L9rLL1eEGSm0fq8XcLdveuSs=",
          start_server_instances: true,
          server_pools: ["primary", "linked", "demo", "reserved"]
        }
      ]

  """
  @spec list_dbservers(map(), list(Types.server_pool())) ::
          list(MscmpSystDb.Types.db_server())
  defdelegate list_dbservers(options, filters \\ []), to: OptionsParser

  @doc section: :options_parsing
  @doc """
  Returns the database server definition which corresponds to the provided name.

  ## Parameters

    * `options` - the options file data as read by `get_options/1`.

    * `dbserver_name` - the name of the database server to look up.

  ## Examples

  Typical call for database server:

      iex> config_options = MsbmsSystOptions.get_options!("./testing_options.toml")
      iex> MsbmsSystOptions.get_dbserver_by_name(config_options, "instance_db")
      %{
        db_host: "127.0.0.1",
        db_max_instances: 30,
        db_port: 5432,
        db_show_sensitive: true,
        dbadmin_password: "default.msbms.privileged.password",
        dbadmin_pool_size: 1,
        server_name: "instance_db",
        server_salt: "w1OfRx630x7svid8Tk3L9rLL1eEGSm0fq8XcLdveuSs=",
        start_server_instances: true,
        server_pools: ["primary", "linked", "demo", "reserved"]
      }

  Result in case of bad server name:

      iex> config_options = MsbmsSystOptions.get_options!("./testing_options.toml")
      iex> MsbmsSystOptions.get_dbserver_by_name(config_options, "non_existent_db")
      nil
  """
  @spec get_dbserver_by_name(map(), String.t()) :: MscmpSystDb.Types.db_server()
  defdelegate get_dbserver_by_name(options, dbserver_name), to: OptionsParser
end
