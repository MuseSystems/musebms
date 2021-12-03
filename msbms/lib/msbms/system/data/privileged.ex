# Source File: privileged.ex
# Location:    msbms/lib/msbms/system/data/privileged.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems
defmodule Msbms.System.Data.Privileged do

  alias Msbms.System.Data.PrivilegedDatastore
  alias Msbms.System.Types.DbServer

  @spec db_roles_exist?(DbServer.t(), list()) :: boolean()
  def db_roles_exist?(%DbServer{} = dbserver, db_roles) when is_list(db_roles) do
    PrivilegedDatastore.put_dynamic_repo(PrivilegedDatastore.get_datastore_id(dbserver))

    role_qry_result =
      PrivilegedDatastore.query(
        """
        SELECT
          bool_and(myrole = coalesce(rolname, '***role not found***')) AS all_roles_found
        FROM unnest($1::text[]) myrole
          LEFT JOIN pg_catalog.pg_roles pr ON pr.rolname = myrole
        """,
        [db_roles]
      )

    case role_qry_result do
      {:ok, %{num_rows: 1, rows: [[final_result | _] | _]}} ->
        final_result

      {:ok, %{num_rows: row_count}} when row_count != 1 ->
        raise "Unexpected result testing if database roles exist: row count != 1 (#{row_count})"

      {:error, exception} ->
        raise "Unexpected result testing if database roles exist: #{exception.postgres.code}"
    end
  end

  @spec db_role_exists?(DbServer.t(), binary()) :: boolean()
  def db_role_exists?(%DbServer{} = dbserver, rolename) when is_binary(rolename) do
    PrivilegedDatastore.put_dynamic_repo(PrivilegedDatastore.get_datastore_id(dbserver))

    role_qry_result =
      PrivilegedDatastore.query(
        """
        SELECT exists(
          SELECT true FROM pg_roles WHERE rolname = $1
        ) AS role_found
        """,
        [rolename]
      )

    case role_qry_result do
      {:ok, %{num_rows: 1, rows: [[final_result | _] | _]}} ->
        final_result

      {:ok, %{num_rows: row_count}} when row_count != 1 ->
        raise "Unexpected result testing if a database role exists: row count != 1 (#{row_count})"

      {:error, exception} ->
        raise "Unexpected result testing if a database role exists: #{exception.postgres.code}"
    end
  end

  # @spec verify_and_create_global_db_roles() :: {:ok} | {:error, reason}
end
