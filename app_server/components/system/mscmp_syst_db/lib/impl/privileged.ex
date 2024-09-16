# Source File: privileged.ex
# Location:    musebms/components/system/mscmp_syst_db/lib/impl/privileged.ex
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

  require Logger

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
          {:ok, String.t()} | {:error, MscmpSystError.t()}
  def get_datastore_version(datastore_options, opts) do
    starting_datastore_context = Datastore.get_dynamic_repo()

    :ok = start_priv_connection(datastore_options)

    datastore_version = Migrations.get_datastore_version(opts)

    stop_priv_connection(opts[:db_shutdown_timeout])

    _ = Datastore.put_datastore_context(starting_datastore_context)

    datastore_version
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :database_error,
          message: "Failure retrieving datastore version.",
          cause: error
        }
      }
  end

  ##############################################################################
  #
  # initialize_datastore
  #
  #

  @spec initialize_datastore(DatastoreOptions.t(), Keyword.t()) ::
          :ok | {:error, MscmpSystError.t()}
  def initialize_datastore(datastore_options, opts) do
    database_owner = Enum.find(datastore_options.contexts, &(&1.database_owner_context == true))

    :ok = start_priv_connection(datastore_options)

    init_opts = Keyword.take(opts, [:migrations_schema, :migrations_table])

    :ok = Migrations.initialize_datastore(database_owner.database_role, init_opts)

    stop_priv_connection(opts[:db_shutdown_timeout])
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :database_error,
          message: "Failure initializing datastore.",
          cause: error
        }
      }
  end

  ##############################################################################
  #
  # upgrade_datastore
  #

  @spec upgrade_datastore(DatastoreOptions.t(), String.t(), Keyword.t(), Keyword.t()) ::
          {:ok, [String.t()]} | {:error, MscmpSystError.t()}
  def upgrade_datastore(datastore_options, datastore_type, migration_bindings, opts) do
    starting_datastore_context = Datastore.current_datastore_context()

    :ok = start_priv_connection(datastore_options)

    upgrade_opts =
      Keyword.take(opts, [:migrations_root_dir, :migrations_schema, :migrations_table])

    apply_migrations_result =
      Migrations.apply_outstanding_migrations(
        datastore_type,
        migration_bindings,
        upgrade_opts
      )

    stop_priv_connection(opts[:db_shutdown_timeout])

    _ = Datastore.put_datastore_context(starting_datastore_context)

    apply_migrations_result
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :database_error,
          message: "Failure upgrading datastore.",
          cause: error
        }
      }
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

    case Datastore.start_datastore_context(priv_options, priv_context, []) do
      {:ok, priv_pid} ->
        _ = Datastore.put_datastore_context(priv_pid)

        Datastore.query_for_none!("SET ROLE #{database_owner.database_role};", [], [])

        Datastore.query_for_none!("SET application_name = '#{priv_context.description}';", [], [])

        :ok

      error ->
        {
          :error,
          %MscmpSystError{
            code: :database_error,
            message: "Failure starting privileged dataastore.",
            cause: error
          }
        }
    end
  end

  defp stop_priv_connection(db_shutdown_timeout) do
    _context_action_result =
      Datastore.stop_datastore_context(Datastore.current_datastore_context(),
        db_shutdown_timeout: db_shutdown_timeout
      )

    :ok
  end
end
