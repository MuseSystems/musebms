# Source File: utils.ex
# Location:    musebms/lib/msbms/system/data/utils.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule Msbms.System.Data.Utils do
  @moduledoc """
  Provides some simple utility functions which may be used in different data management tasks.

  ## Scope of Usage
  These utilities are only expected to be used by Msbms.System.Data modules.
  """
  alias Msbms.System.Constants
  alias Msbms.System.Types.DatastoreOptions

  @doc """

  """
  @spec generate_password(binary, binary, binary) :: binary
  def generate_password(instance_code, dbident, dbsalt)
      when is_binary(instance_code) and is_binary(dbident) and is_binary(dbsalt) do
    :crypto.hash(:blake2b, instance_code <> dbident <> Constants.get(:dbident_salt) <> dbsalt)
    |> Base.encode64()
  end

  @spec deconstruct_migration_filename(binary()) :: {:ok, map()} | {:error, any()}
  def deconstruct_migration_filename(filename) when is_binary(filename) do
    case Regex.run(
           ~r/^(?<kind>(global|instance))\.(?<version>..\...\....\.......\....)\.eex\.sql$/,
           filename,
           capture: ["kind", "version"]
         ) do
      [kind | [version | _]] ->
        {:ok,
         %{
           migration_type: kind,
           migration_version: version |> String.upcase(),
           migration_path: Path.join(["priv", "database", kind, filename]),
           release: String.slice(version, 0..1) |> String.to_integer(36),
           version: String.slice(version, 3..4) |> String.to_integer(36),
           update: String.slice(version, 6..8) |> String.to_integer(36),
           sponsor: String.slice(version, 10..15) |> String.to_integer(36),
           sponsor_modification: String.slice(version, 17..19) |> String.to_integer(36)
         }}

      _ ->
        {:error, "Failed to parse migration version information from #{filename}"}
    end
  end

  @spec start_datastores(atom(), DatastoreOptions.t()) :: [{:ok, pid()} | {:error, term()}]
  def start_datastores(datastore_module, %DatastoreOptions{} = options)
      when is_atom(datastore_module) do
    Enum.reduce(options.contexts, [], fn context, acc ->
      [
        case datastore_module.start_link(
               name: Keyword.get(context, :context_role),
               database: options.database_name,
               hostname: options.dbserver.db_host,
               port: options.dbserver.db_port,
               username: Atom.to_string(Keyword.get(context, :context_role)),
               password:
                 generate_password(
                   options.instance_code,
                   Atom.to_string(Keyword.get(context, :context_role)),
                   options.dbserver.server_salt
                 ),
               show_sensitive_data_on_connection_error: options.dbserver.db_show_sensitive,
               pool_size: Keyword.get(context, :context_starting_pool_size, 1)
             ) do
          {:error, {:already_started, ds_pid}} ->
            {:ok, ds_pid}

          {:error, reason} ->
            {:error,
             "Failure to start database #{options.database_name} for #{Atom.to_string(Keyword.get(context, :context_role))}.\n#{inspect(reason)}"}

          return_value ->
            return_value
        end
        | acc
      ]
    end)
  end

  @spec stop_datastores(atom(), DatastoreOptions.t()) :: :ok
  def stop_datastores(datastore_module, %DatastoreOptions{contexts: contexts})
      when is_atom(datastore_module) do
    Enum.each(
      contexts,
      fn context ->
        context
        |> Keyword.get(:context_role)
        |> datastore_module.put_dynamic_repo()

        datastore_module.stop()
      end
    )

    :ok
  end
end
