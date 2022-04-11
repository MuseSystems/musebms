# Source File: privileged.ex
# Location:    components/system/msbms_syst_datastore/lib/impl/privileged.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystDatastore.Impl.Privileged do
  @moduledoc false

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

  alias MsbmsSystDatastore.Impl.Migrations
  alias MsbmsSystDatastore.Runtime.Datastore
  alias MsbmsSystDatastore.Types

  require Logger

  @default_db_shutdown_timeout 60_000
  @priv_connection_role "msbms_syst_dba"
  @priv_application_name "MSBMS Datastore Privileged Access"

  @spec get_datastore_version(Types.datastore_options(), Keyword.t()) ::
          {:ok, String.t()} | {:error, MsbmsSystError.t()}
  def get_datastore_version(datastore_options, opts) do
    opts_default = [db_shutdown_timeout: @default_db_shutdown_timeout]
    opts_final = Keyword.merge(opts, opts_default, fn _k, v1, _v2 -> v1 end)
    :ok = start_priv_connection(datastore_options)

    datastore_version = Migrations.get_datastore_version(opts_final)

    stop_priv_connection(opts_final[:db_shutdown_timeout])

    datastore_version
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :database_error,
          message: "Failure retrieving datastore version.",
          cause: error
        }
      }
  end

  @spec initialize_datastore(Types.datastore_options(), Keyword.t()) ::
          :ok | {:error, MsbmsSystError.t()}
  def initialize_datastore(datastore_options, opts \\ []) do
    opts_default = [db_shutdown_timeout: @default_db_shutdown_timeout]
    opts_final = Keyword.merge(opts, opts_default, fn _k, v1, _v2 -> v1 end)

    :ok = start_priv_connection(datastore_options)

    :ok = Migrations.initialize_datastore(datastore_options.database_owner, opts_final)

    stop_priv_connection(opts_final[:db_shutdown_timeout])
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :database_error,
          message: "Failure initializing datastore.",
          cause: error
        }
      }
  end

  @spec upgrade_datastore(Types.datastore_options(), String.t(), Keyword.t(), Keyword.t()) ::
          {:ok, [String.t()]} | {:error, MsbmsSystError.t()}
  def upgrade_datastore(datastore_options, datastore_type, migration_bindings, opts \\ []) do
    opts_default = [db_shutdown_timeout: @default_db_shutdown_timeout]
    opts_final = Keyword.merge(opts, opts_default, fn _k, v1, _v2 -> v1 end)

    :ok = start_priv_connection(datastore_options)

    apply_migrations_result =
      Migrations.apply_outstanding_migrations(
        datastore_type,
        migration_bindings,
        opts_final
      )

    stop_priv_connection(opts_final[:db_shutdown_timeout])

    apply_migrations_result
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :database_error,
          message: "Failure upgrading datastore.",
          cause: error
        }
      }
  end

  defp get_priv_connection_options(
         %{db_server: db_server, database_name: database_name} = options
       )
       when is_map(options) do
    %{
      database_name: database_name,
      contexts: [
        %{
          id: nil,
          description: @priv_application_name,
          database_role: @priv_connection_role,
          database_password: db_server.dbadmin_password,
          starting_pool_size: db_server.dbadmin_pool_size,
          start_context: true
        }
      ],
      db_server: %{
        server_name: db_server.server_name,
        db_host: db_server.db_host,
        db_port: db_server.db_port,
        db_show_sensitive: db_server.db_show_sensitive,
        db_log_level: db_server.db_log_level,
        db_max_databases: db_server.db_max_databases,
        context_defaults: db_server.context_defaults,
        server_salt: db_server.server_salt,
        dbadmin_password: db_server.dbadmin_password,
        dbadmin_pool_size: db_server.dbadmin_pool_size
      }
    }
  end

  defp start_priv_connection(datastore_options) do
    priv_options = get_priv_connection_options(datastore_options)
    priv_context = hd(priv_options.contexts)

    case Datastore.start_datastore_context(priv_options, priv_context) do
      {:ok, priv_pid} ->
        Datastore.set_datastore_context(priv_pid)

        Datastore.query_for_none!("SET ROLE #{datastore_options.database_owner};")

        Datastore.query_for_none!("SET application_name = '#{priv_context.description}';")

        :ok

      error ->
        {
          :error,
          %MsbmsSystError{
            code: :database_error,
            message: "Failure starting privileged dataastore.",
            cause: error
          }
        }
    end
  end

  defp stop_priv_connection(db_shutdown_timeout) do
    _context_action_result =
      Datastore.stop_datastore_context(Datastore.current_datastore_context(), db_shutdown_timeout)

    :ok
  end
end
