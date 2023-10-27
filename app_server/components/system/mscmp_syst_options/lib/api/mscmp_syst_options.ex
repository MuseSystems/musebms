# Source File: mscmp_syst_options.ex
# Location:    musebms/app_server/components/system/mscmp_syst_options/lib/api/mscmp_syst_options.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystOptions do
  @external_resource "README.md"
  @moduledoc File.read!(Path.join([__DIR__, "..", "..", "README.md"]))

  alias MscmpSystOptions.Impl.OptionsFile
  alias MscmpSystOptions.Impl.OptionsParser
  alias MscmpSystOptions.Types

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

      iex> MscmpSystOptions.get_options("./testing_options.toml")
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
          global_db_password: "(eXI0BU&elq1(mvw",
          global_db_pool_size: 10,
          global_pepper_value: "jTtEdXRExP5YXHeARQ1W66lP6wDc9GyOvhFPvwnHhtc="
        }
      }

  Called with bad parameters:

      iex> {:error, %MscmpSystError{}} =
      ...>   MscmpSystOptions.get_options("./bad_file_name.toml")
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

      iex> MscmpSystOptions.get_options!("./testing_options.toml")
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
        global_db_password: "(eXI0BU&elq1(mvw",
        global_db_pool_size: 10,
        global_pepper_value: "jTtEdXRExP5YXHeARQ1W66lP6wDc9GyOvhFPvwnHhtc="
      }

  Called with bad parameters:

      iex> MscmpSystOptions.get_options!("./bad_file_name.toml")
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

      iex> config_options = MscmpSystOptions.get_options!("./testing_options.toml")
      iex> MscmpSystOptions.get_global_dbserver_name(config_options)
      "global_db"
  """
  @spec get_global_dbserver_name(map()) :: String.t()
  defdelegate get_global_dbserver_name(options), to: OptionsParser

  @doc section: :options_parsing
  @doc """
  Returns the `t:MscmpSystDb.Types.DbServer.t/0` data for the database
  server designated as hosting the global database.

  ## Parameters

    * `options` - the options file data as read by `get_options/1`.

  ## Examples
      iex> config_options = MscmpSystOptions.get_options!("./testing_options.toml")
      iex> %MscmpSystDb.Types.DbServer{server_name: "global_db"} =
      iex>   MscmpSystOptions.get_global_dbserver(config_options)

  """
  @spec get_global_dbserver(map()) :: MscmpSystDb.Types.DbServer.t()
  defdelegate get_global_dbserver(options), to: OptionsParser

  @doc section: :options_parsing
  @doc """
  Returns a password fragment which is used to establish connections to the
  global database.

  > #### Note {: .warning}
  >
  > While this value doesn't represent the complete password used to connect
  > global database roles to the database server, it nonetheless should be
  > treated with care inside of the application as should the underlying options
  > file which persists this value.

  ## Parameters

    * `options` - the options file data as read by `get_options/1`.

  ## Examples

      iex> config_options = MscmpSystOptions.get_options!("./testing_options.toml")
      iex> MscmpSystOptions.get_global_db_password(config_options)
      "(eXI0BU&elq1(mvw"
  """
  @spec get_global_db_password(map()) :: String.t()
  defdelegate get_global_db_password(options), to: OptionsParser

  @doc section: :options_parsing
  @doc """
  Returns the number of connections to the global database that should be
  established on application startup.

  ## Parameters

    * `options` - the options file data as read by `get_options/1`.

  ## Examples

      iex> config_options = MscmpSystOptions.get_options!("./testing_options.toml")
      iex> MscmpSystOptions.get_global_db_pool_size(config_options)
      10
  """
  @spec get_global_db_pool_size(map()) :: non_neg_integer()
  defdelegate get_global_db_pool_size(options), to: OptionsParser

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
      iex> config_options = MscmpSystOptions.get_options!("./testing_options.toml")
      iex> MscmpSystOptions.get_global_pepper_value(config_options)
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
      iex> config_options = MscmpSystOptions.get_options!("./testing_options.toml")
      iex> MscmpSystOptions.list_available_server_pools(config_options)
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

      iex> config_options = MscmpSystOptions.get_options!("./testing_options.toml")
      iex> [_ | _] = MscmpSystOptions.list_dbservers(config_options)
      [
        %MscmpSystDb.Types.DbServer{
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
        %MscmpSystDb.Types.DbServer{
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

      iex> config_options = MscmpSystOptions.get_options!("./testing_options.toml")
      iex> [_ | _] = MscmpSystOptions.list_dbservers(config_options, ["primary"])
      [
        %MscmpSystDb.Types.DbServer{
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
          list(MscmpSystDb.Types.DbServer.t())
  defdelegate list_dbservers(options, filters \\ []), to: OptionsParser

  @doc section: :options_parsing
  @doc """
  Returns the database server definition which corresponds to the provided name.

  ## Parameters

    * `options` - the options file data as read by `get_options/1`.

    * `dbserver_name` - the name of the database server to look up.

  ## Examples

  Typical call for database server:

      iex> config_options = MscmpSystOptions.get_options!("./testing_options.toml")
      iex> MscmpSystOptions.get_dbserver_by_name(config_options, "instance_db")
      %MscmpSystDb.Types.DbServer{
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

      iex> config_options = MscmpSystOptions.get_options!("./testing_options.toml")
      iex> MscmpSystOptions.get_dbserver_by_name(config_options, "non_existent_db")
      nil
  """
  @spec get_dbserver_by_name(map(), String.t()) :: MscmpSystDb.Types.DbServer.t() | nil
  defdelegate get_dbserver_by_name(options, dbserver_name), to: OptionsParser
end
