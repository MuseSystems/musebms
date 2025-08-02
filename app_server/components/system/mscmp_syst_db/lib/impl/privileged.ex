# Source File: privileged.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/impl/privileged.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.Impl.Privileged do
  @moduledoc false

  alias MscmpSystDb.Impl.Migrations
  alias MscmpSystDb.Runtime.Datastore
  alias MscmpSystDb.Types.{DatastoreContext, DatastoreOptions, DbServer}

  ######
  #
  # Privileged actions are those which require the database owner role to
  # execute correctly.  The initial connection will open with the dba role,
  # which is a login role, then quickly degrade its access rights by setting the
  # role to be the database owner.  All actions are then undertaken as the owner
  # role.
  #
  # Most actions taken under the privileged datastore are likely to be database
  # migration related.  While it is conceivable there would be other uses, most
  # non-migration actions should be made with the appropriate regular datastore
  # contexts and should not require elevated privileges.
  #
  # Once all privileged actions have taken place, the privileged datastore
  # connection should be closed.  We don't typically want long-lived/persistent
  # privileged connections.
  #
  ######

  @priv_connection_role "ms_syst_privileged"
  @priv_application_name "MscmpSystDb Datastore Privileged Access"

  ##############################################################################
  #
  # get_datastore_version
  #
  #

  @spec get_datastore_version(DatastoreOptions.t(), Keyword.t()) ::
          {:ok, String.t()} | {:error, term()}
  def get_datastore_version(datastore_options, opts) do
    starting_datastore_context = Datastore.get_dynamic_repo()

    result =
      with :ok <- start_priv_connection(datastore_options) do
        Migrations.get_datastore_version(opts)
      end

    # We want to ensure the privileged connection is closed even if there was
    # an error, to the point of crashing the process if necessary.
    :ok = stop_priv_connection(opts[:db_shutdown_timeout])

    {:ok, _} = Datastore.put_datastore_context(starting_datastore_context)

    result
  end

  ##############################################################################
  #
  # initialize_datastore
  #
  #

  @spec initialize_datastore(DatastoreOptions.t(), Keyword.t()) ::
          :ok | {:error, term()}
  def initialize_datastore(datastore_options, opts) do
    starting_datastore_context = Datastore.current_datastore_context()
    database_owner = Enum.find(datastore_options.contexts, &(&1.database_owner_context == true))
    init_opts = Keyword.take(opts, [:migrations_schema, :migrations_table])

    result =
      with :ok <- start_priv_connection(datastore_options) do
        :ok = Migrations.initialize_datastore(database_owner.database_role, init_opts)
      end

    # We want to ensure the privileged connection is closed even if there was
    # an error, to the point of crashing the process if necessary.
    :ok = stop_priv_connection(opts[:db_shutdown_timeout])

    {:ok, _} = Datastore.put_datastore_context(starting_datastore_context)

    result
  end

  ##############################################################################
  #
  # upgrade_datastore
  #

  @spec upgrade_datastore(DatastoreOptions.t(), String.t(), Keyword.t(), Keyword.t()) ::
          {:ok, [String.t()]} | {:error, term()}
  def upgrade_datastore(datastore_options, datastore_type, migration_bindings, opts) do
    starting_datastore_context = Datastore.current_datastore_context()

    upgrade_opts =
      Keyword.take(opts, [:migrations_root_dir, :migrations_schema, :migrations_table])

    result =
      with :ok <- start_priv_connection(datastore_options) do
        Migrations.apply_outstanding_migrations(datastore_type, migration_bindings, upgrade_opts)
      end

    # We want to ensure the privileged connection is closed even if there was
    # an error, to the point of crashing the process if necessary.
    :ok = stop_priv_connection(opts[:db_shutdown_timeout])

    {:ok, _} = Datastore.put_datastore_context(starting_datastore_context)

    result
  end

  defp get_priv_connection_options(%DatastoreOptions{
         db_server: db_server,
         database_name: database_name
       }) do
    %DatastoreOptions{
      database_name: database_name,
      contexts: [
        %DatastoreContext{
          context_name: nil,
          description: @priv_application_name,
          database_role: @priv_connection_role,
          database_password: db_server.dbadmin_password,
          starting_pool_size: db_server.dbadmin_pool_size,
          start_context: true
        }
      ],
      db_server: %DbServer{
        server_name: db_server.server_name,
        start_server_instances: true,
        server_pools: [],
        db_host: db_server.db_host,
        db_port: db_server.db_port,
        db_show_sensitive: db_server.db_show_sensitive,
        db_max_instances: db_server.db_max_instances,
        server_salt: db_server.server_salt,
        dbadmin_password: db_server.dbadmin_password,
        dbadmin_pool_size: db_server.dbadmin_pool_size
      }
    }
  end

  defp start_priv_connection(datastore_options) do
    priv_options = get_priv_connection_options(datastore_options)
    priv_context = hd(priv_options.contexts)

    database_owner = Enum.find(datastore_options.contexts, &(&1.database_owner_context == true))

    with {:ok, priv_pid} <- Datastore.start_datastore_context(priv_options, priv_context, []),
         {:ok, _} <- Datastore.put_datastore_context(priv_pid),
         :ok <- Datastore.query_for_none("SET ROLE #{database_owner.database_role};", [], []) do
      Datastore.query_for_none("SET application_name = '#{priv_context.description}';", [], [])
    end
  end

  defp stop_priv_connection(db_shutdown_timeout) do
    Datastore.stop_datastore_context(Datastore.current_datastore_context(),
      db_shutdown_timeout: db_shutdown_timeout
    )
  end
end
