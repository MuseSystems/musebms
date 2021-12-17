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
defmodule Msbms.System.Actions.Privileged do
  alias Msbms.System.Data.GlobalDatastore
  alias Msbms.System.Data.Privileged
  alias Msbms.System.Data.PrivilegedDatastore
  alias Msbms.System.Data.StartupOptions

  def start_system do
    with {:get_startup_options, {:ok, startup_options}} <-
           {:get_startup_options, StartupOptions.get_options()},
         {:get_global_dbserver, {:ok, global_dbserver}} <-
           {:get_global_dbserver, StartupOptions.get_global_dbserver(startup_options)},
         {:start_priv_datastore, {:ok, priv_db_pid}} <-
           {:start_priv_datastore, PrivilegedDatastore.start_datastore(global_dbserver)},
         {:get_global_datastore_options, global_datastore_options} <-
           {:get_global_datastore_options, GlobalDatastore.get_datastore_options(global_dbserver)},
         {:create_global_datastore_roles, {:ok}} <-
           {:create_global_datastore_roles,
            Privileged.create_datastore_roles(
              priv_db_pid,
              global_dbserver,
              global_datastore_options
            )},
         {:create_global_database, {:ok}} <-
           {:create_global_database, Privileged.create_db(priv_db_pid, global_datastore_options)},
         {:stop_priv_datastore, :ok} <-
           {:stop_priv_datastore, PrivilegedDatastore.stop_datastore(priv_db_pid)},
         {:start_global_priv_datastore, {:ok, global_priv_db_pid}} <-
           {:start_global_priv_datastore,
            PrivilegedDatastore.start_datastore(
              global_dbserver,
              global_datastore_options.database_name
            )},
         {:apply_global_migrations, {:ok}} <-
           {:apply_global_migrations,
            Privileged.apply_outstanding_migrations(
              global_priv_db_pid,
              global_datastore_options,
              Privileged.get_available_migrations(:global)
            )},
         {:stop_global_priv_datastore, :ok} <-
           {:stop_global_priv_datastore, PrivilegedDatastore.stop_datastore(global_priv_db_pid)} do
      {:ok}
    else
      {:get_startup_options, _} -> {:error, "get_startup_options"}
      {:get_global_dbserver, _} -> {:error, "get_global_dbserver"}
      {:start_priv_datastore, _} -> {:error, "start_priv_datastore"}
      {:get_global_datastore_options, _} -> {:error, "get_global_datastore_options"}
      {:create_global_datastore_roles, _} -> {:error, "create_global_datastore_roles"}
      {:create_global_database, _} -> {:error, "create_global_database"}
      {:stop_priv_datastore, _} -> {:error, "stop_priv_datastore"}
      {:start_global_priv_datastore, _} -> {:error, "start_global_priv_datastore"}
      {:apply_global_migrations, _} -> {:error, "apply_global_migrations"}
      {:stop_global_priv_datastore, _} -> {:error, "stop_global_priv_datastore"}
    end
  end
end
