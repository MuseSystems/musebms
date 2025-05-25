# Source File: clean.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/mix/tasks/msbms/db/clean.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mix.Tasks.Msbms.Db.Clean do
  @shortdoc "Cleans database artifacts (reset database, clean migrations)."

  @moduledoc """
  Cleans database artifacts for MSBMS components.

  This task allows you to:
  - Reset the database (drops all objects and runs bootstrap script)

  Note: Database migration cleaning is handled by `mix msbms.elixir.clean --migrations`
  since migrations are part of the Elixir project structure.

  It calls functions from `MsbmsBuildLib` to perform the actual operations.

  ## Command line options

    * `--reset` - Resets the database, dropping all objects and running the
      bootstrap script. After reset, the specified database user will be
      granted the `ms_syst_documentation` role.
    * `--base-dir PATH` - Specifies the base directory of the MSBMS project.
      Defaults to the current working directory.
    * `--log-level LEVEL` - Sets the logging level (e.g., debug, info, warn, error).
      Defaults to "info".
    * `--db-host HOST` - Database host (default: localhost).
    * `--db-port PORT` - Database port (default: 5432).
    * `--db-user USER` - Database user (default: postgres).
    * `--db-name DATABASE` - Database name (default: postgres).
    * `--dbadmin-password PASS` - Password for the `ms_syst_privileged` role
      created by the bootstrap script. If not provided, defaults to
      "musesystems-insecure-publicly-known-password".

  ## Database Requirements

  Database cleaning functions require a superuser role as the clean process
  will both drop and create roles and databases.

  For security reasons, the main database password is not accepted as a command
  line argument. Instead, use either a correctly configured `.pgpass` file or
  environment variables. See the PostgreSQL documentation for more information.

  ## Examples

      mix msbms.db.clean --reset --db-user postgres
      mix msbms.db.clean --reset --dbadmin-password mypassword
      mix msbms.db.clean --reset --db-host myhost --db-user postgres

  The `--reset` option is required.
  """

  use Mix.Task

  @options [
    reset: :boolean,
    base_dir: :string,
    log_level: :string,
    db_host: :string,
    db_port: :integer,
    db_user: :string,
    db_name: :string,
    dbadmin_password: :string
  ]

  def run(args) do
    {opts, _parsed_args, _invalid_opts} =
      OptionParser.parse(args, strict: @options)

    # Set log level early
    log_level_str = Keyword.get(opts, :log_level, "info")
    :ok = MsbmsBuildLib.set_log_level(String.to_atom(log_level_str))

    base_dir = Keyword.get(opts, :base_dir, File.cwd!())
    do_reset = Keyword.get(opts, :reset, false)
    db_opts = build_db_opts(opts)

    if not do_reset do
      Mix.raise(
        "No action specified. Please use --reset. " <>
          "Run 'mix help msbms.db.clean' for more information."
      )
    end

    clean_db_action(base_dir, db_opts)
  end

  defp build_db_opts(opts) do
    [
      host: Keyword.get(opts, :db_host, "localhost"),
      port: Keyword.get(opts, :db_port, 5432),
      user: Keyword.get(opts, :db_user, "postgres"),
      database: Keyword.get(opts, :db_name, "postgres"),
      dbadmin_password:
        Keyword.get(opts, :dbadmin_password, "musesystems-insecure-publicly-known-password")
    ]
  end

  defp clean_db_action(base_dir, db_opts) do
    Mix.shell().info(
      "Resetting database with connection: #{db_opts[:user]}@#{db_opts[:host]}:#{db_opts[:port]}/#{db_opts[:database]}..."
    )

    case MsbmsBuildLib.clean_db(base_dir, db_opts) do
      :ok ->
        Mix.shell().info("Successfully reset database.")

      {:error, reason} ->
        Mix.raise("Database cleaning failed: Failed to reset database: #{reason}")
    end
  end
end
