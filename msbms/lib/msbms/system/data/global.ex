# Source File: global.ex
# Location:    musebms/lib/msbms/system/data/global.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule Msbms.System.Data.Global do
  use Ecto.Repo,
    otp_app: :msbms,
    adapter: Ecto.Adapters.Postgres

  @spec migrations_exist?(atom | pid) :: boolean
  def migrations_exist?(repo) do
    put_dynamic_repo(repo)

    query_result =
      query!("""
      SELECT true AS migrations_exist
        FROM information_schema.tables
       WHERE table_schema = 'msbms_syst_data'
         AND table_name = 'database_migrations';
      """)

    query_result.num_rows > 0
  end

  # @spec start_privileged_repo() :: {:error, any} | {:ok, pid}
  def start_privileged_repo(db_host, db_port, db_name, db_user, db_pass) do
    global_db_name = Application.fetch_env!(:msbms, :db_name)
    global_privileged_login = Application.fetch_env!(:msbms, :db_login)

    startup_options =
      File.read!("msbms_startup_options.toml")
      |> Toml.decode!()

    if String.length(startup_options["db_pass"]) < 20 do
      raise(
        ArgumentError,
        "The db_pass value in msbms_startup_options.toml must be at least 20 charaters long."
      )
    end

    start_link(
      name: global_db_name,
      database: Atom.to_string(global_db_name),
      hostname: startup_options["global_admin"]["db_host"],
      port: startup_options["global_admin"]["db_port"],
      username: global_privileged_login,
      password: startup_options["global_admin"]["db_pass"],
      show_sensitive_data_on_connection_error:
        startup_options["global_admin"]["db_show_sensitive"],
      pool_size: startup_options["global_admin"]["db_pool_size"]
    )

    get_database_version(global_db_name)
  end

  def get_database_version(repo) do
    put_dynamic_repo(repo)

    {_} =
      transaction(fn ->
        query("SET SESSION ROLE msbms_sys_owner;")

        query("""
        SELECT
             migration_release
            ,migration_version
            ,migration_update
            ,migration_custom
        FROM msbms_syst_data.database_migrations
        ORDER BY
             migration_release DESC
            ,migration_version DESC
            ,migration_update DESC
        LIMIT 1
        """)
      end)

    # IO.inspect(query_result)
    # process_version_query_result(query_result)
  end

  defp process_version_query_result({:ok, result}) do
    cond do
      [version_row | _] = result.rows ->
        %{
          release: Enum.at(version_row, 0),
          version: Enum.at(version_row, 1),
          update: Enum.at(version_row, 2),
          custom: Enum.at(version_row, 3)
        }

      true ->
        %{release: 0, version: 0, update: 0}
    end
  end

  defp process_version_query_result({:error, exception}) do
    IO.inspect(exception)
    %{release: 0, version: 0, update: 0, custom: 0}
  end
end
