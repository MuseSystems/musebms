# Source File: global.ex
# Location:    musebms/lib/msbms/system/actions/global.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems
defmodule Msbms.System.Actions.Global do
  alias Msbms.System.Constants
  alias Msbms.System.Data.GlobalDatastore
  alias Msbms.System.Data.Privileged
  alias Msbms.System.Data.PrivilegedDatastore
  alias Msbms.System.Data.StartupOptions
  alias Msbms.System.Types.DatastoreOptions

  @spec bootstrap :: {:ok} | {:error, binary()}
  def bootstrap do
    with(
      {:get_global_datastore_options, datastore_options} <-
        {:get_global_datastore_options, get_datastore_options()},
      {:verify_or_create_global_database, {:ok}} <-
        {:verify_or_create_global_database, verify_or_create_database(datastore_options)},
      {:migrate_global_database, {:ok}} <-
        {:migrate_global_database, migrate_database(datastore_options)}
    ) do
      {:ok}
    else
      error -> {:error, "Failed bootstrapping the global database: #{inspect(error)}"}
    end
  end

  @spec get_datastore_options(binary()) :: Msbms.System.Types.DatastoreOptions.t()
  def get_datastore_options(startup_options_path \\ Constants.get(:startup_options_path)) do
    with(
      {:get_startup_options, {:ok, startup_options}} <-
        {:get_startup_options, StartupOptions.get_options(startup_options_path)},
      {:get_global_dbserver, {:ok, global_dbserver}} <-
        {:get_global_dbserver, StartupOptions.get_global_dbserver(startup_options)},
      {:get_global_datastore_options, global_datastore_options} <-
        {:get_global_datastore_options, GlobalDatastore.get_datastore_options(global_dbserver)}
    ) do
      global_datastore_options
    else
      error ->
        raise "Failed getting global database options for bootstrapping:\n#{inspect(error)}"
    end
  end

  @spec verify_or_create_database(Msbms.System.Types.DatastoreOptions.t()) :: {:ok}
  def verify_or_create_database(%DatastoreOptions{} = datastore_options) do
    with(
      {:start_server_priv_datastore, {:ok, db_conn_pid}} <-
        {:start_server_priv_datastore,
         PrivilegedDatastore.start_datastore(datastore_options, :server_privileged)},
      {:create_global_db_roles, {:ok}} <-
        {:create_global_db_roles,
         Privileged.create_datastore_roles(db_conn_pid, datastore_options)},
      {:create_global_db, {:ok}} <-
        {:create_global_db, Privileged.create_db(db_conn_pid, datastore_options)},
      {:stop_server_priv_datastore, :ok} <-
        {:stop_server_priv_datastore, PrivilegedDatastore.stop_datastore(db_conn_pid)}
    ) do
      {:ok}
    else
      error -> raise "Failed bootstrapping global database:\n#{inspect(error)}"
    end
  end

  @spec migrate_database(Msbms.System.Types.DatastoreOptions.t()) :: {:ok}
  def migrate_database(%DatastoreOptions{} = database_options) do
    with(
      {:start_global_priv_datastore, {:ok, db_conn_pid}} <-
        {:start_global_priv_datastore,
         PrivilegedDatastore.start_datastore(database_options, :db_privileged)},
      {:apply_global_migrations, {:ok}} <-
        {:apply_global_migrations,
         Privileged.apply_outstanding_migrations(
           db_conn_pid,
           database_options,
           Privileged.get_available_migrations(:global)
         )},
      {:stop_global_priv_datastore, :ok} <-
        {:stop_global_priv_datastore, PrivilegedDatastore.stop_datastore(db_conn_pid)}
    ) do
      {:ok}
    else
      error -> raise "Failed applying migrations to global database:\n#{inspect(error)}"
    end
  end
end
