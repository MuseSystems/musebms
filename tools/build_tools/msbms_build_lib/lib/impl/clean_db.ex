# Source File: clean_db.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/impl/clean_db.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsBuildLib.Impl.CleanDb do
  @moduledoc false

  alias MsbmsBuildLib.Impl.Common

  require Logger

  ##############################################################################
  #
  # clean_db
  #
  #
  @spec clean_db(Path.t(), Keyword.t()) :: :ok | {:error, message :: String.t()}
  def clean_db(base_dir, opts) do
    Logger.notice("==msbms_build_lib==::clean_db::clean_db::START")

    db_scripts_path =
      Path.join([base_dir, Common.db_build_scripts_path()])

    db_opts = %{
      user: Keyword.get(opts, :user),
      host: Keyword.get(opts, :host),
      port: Keyword.get(opts, :port),
      name: Keyword.get(opts, :database),
      dbadmin_password: Keyword.get(opts, :dbadmin_password)
    }

    with {:ok, db_scripts_path} <- validate_db_scripts_path(db_scripts_path),
         {:ok, db_reset_script_path} <- validate_db_reset_script_path(db_scripts_path),
         :ok <- run_db_reset_script(db_reset_script_path, db_opts),
         :ok <- grant_documentation_role(db_opts) do
      Logger.notice("==msbms_build_lib==::clean_db::clean_db::DONE")
      :ok
    else
      {:error, msg} ->
        Logger.error("==msbms_build_lib==::clean_db::clean_db::FAILED")
        {:error, msg}
    end
  end

  defp validate_db_scripts_path(db_scripts_path) do
    if File.dir?(db_scripts_path) do
      {:ok, db_scripts_path}
    else
      {:error, "Database build scripts path not found: #{db_scripts_path}"}
    end
  end

  defp validate_db_reset_script_path(db_scripts_path) do
    db_reset_script_path = Path.join(db_scripts_path, "reset_dev_database.psql")

    if File.exists?(db_reset_script_path) do
      {:ok, db_reset_script_path}
    else
      {:error, "Database reset script not found: #{db_reset_script_path}"}
    end
  end

  defp run_db_reset_script(db_reset_script_path, db_opts) do
    cmd = [
      "--host",
      db_opts.host,
      "--port",
      to_string(db_opts.port),
      "--username",
      db_opts.user,
      "--dbname",
      db_opts.name,
      "--no-password",
      "-v",
      "dbadmin_password=#{db_opts.dbadmin_password}",
      "-f",
      db_reset_script_path
    ]

    Logger.debug("::::Executing psql command: #{inspect(cmd)}")
    Logger.debug("::::Using script file: #{db_reset_script_path}")

    case System.cmd("psql", cmd, stderr_to_stdout: true) do
      {output, 0} ->
        Logger.info("::::Database reset script executed successfully")
        Logger.debug("::::Command output: #{output}")

      {output, exit_code} ->
        Logger.warning("::::Database reset script failed with exit code #{exit_code}")
        Logger.debug("::::Command output: #{output}")
        Logger.debug("::::Full command: #{inspect(cmd)}")
        Logger.debug("::::Script path: #{db_reset_script_path}")

        {:error,
         "Database reset script failed with exit code #{exit_code}. See logs for details."}
    end
  end

  defp grant_documentation_role(db_opts) do
    grant_cmd = [
      "--host",
      db_opts.host,
      "--port",
      to_string(db_opts.port),
      "--username",
      db_opts.user,
      "--dbname",
      db_opts.name,
      "--no-password",
      "-c",
      "GRANT ms_syst_documentation TO #{db_opts.user};"
    ]

    Logger.debug("::::Executing grant role command: #{inspect(grant_cmd)}")

    case System.cmd("psql", grant_cmd, stderr_to_stdout: true) do
      {output, 0} ->
        Logger.info("::::Successfully granted ms_syst_documentation role to #{db_opts.user}")
        Logger.debug("::::Command output: #{output}")
        :ok

      {output, exit_code} ->
        Logger.warning("::::Failed to grant role with exit code #{exit_code}")
        Logger.debug("::::Command output: #{output}")
        {:error, "Failed to grant ms_syst_documentation role to #{db_opts.user}"}
    end
  end
end
