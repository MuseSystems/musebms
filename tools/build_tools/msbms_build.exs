#! /usr/bin/env elixir

# Source File: msbms_build.exs
# Location:    musebms/tools/build_tools/msbms_build.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsBuild do
  @moduledoc """
  Build script for Muse Systems Business Management System.

  This script provides tools for building, cleaning, and managing
  components of the MSBMS Elixir project.
  """

  require Logger

  script_dir = Path.dirname(__ENV__.file)

  build_lib_path = Path.join(script_dir, "msbms_build_lib")

  Mix.install([
    {:msbms_build_lib, path: build_lib_path}
  ])

  Application.put_env(:logger, :default_formatter,
    format: "$date $time [$level] $message $metadata\n",
    metadata: [:error_code, :file]
  )

  @doc """
  Main entry point for the build script.
  Parses command-line arguments and executes the appropriate actions.
  """
  def main(args) do
    args
    |> parse_args()
    |> process_args()
    |> process_jobs()
  end

  defp parse_args(args) do
    {parsed, remaining, invalid} =
      OptionParser.parse(args,
        strict: [
          # General Options
          help: :boolean,
          base_dir: :string,
          component: :keep,

          # Elixir Options
          elixir_env: :string,
          log_level: :string,

          # Database Options
          db_host: :string,
          db_port: :integer,
          db_user: :string,
          dbadmin_password: :string,

          # Global Actions
          all: :boolean,
          all_update: :boolean,

          # Clean Actions
          clean_all: :boolean,
          clean_elixir_ls: :boolean,
          clean_elixir_plt: :boolean,
          clean_elixir_build: :boolean,
          clean_elixir_deps: :boolean,
          clean_db: :boolean,
          clean_db_migrations: :boolean,

          # Dependency Actions
          install_elixir_deps: :boolean,
          update_elixir_deps: :boolean,

          # Build Actions
          build_all: :boolean,
          build_elixir: :boolean,
          build_db_migrations: :boolean,

          # Test Actions
          test_all: :boolean,
          test_elixir_unit: :boolean,
          test_elixir_integration: :boolean,
          test_elixir_doctest: :boolean,
          test_elixir_credo: :boolean,
          test_elixir_dialyzer: :boolean,

          # Documentation Actions
          build_all_docs: :boolean,
          build_elixir_docs: :boolean,
          build_db_docs: :boolean
        ],
        aliases: [
          c: :component,
          t: :test_all
        ]
      )

    {parsed, remaining, invalid}
  end

  defp process_args({opts, _remaining, _invalid}) do
    base_dir = Keyword.get(opts, :base_dir, File.cwd!())
    components = Keyword.get_values(opts, :component)
    elixir_env = Keyword.get(opts, :elixir_env, "dev")

    :ok =
      String.to_atom(Keyword.get(opts, :log_level, "info"))
      |> MsbmsBuildLib.set_log_level()

    actions_list =
      cond do
        Keyword.get(opts, :help, false) ->
          [:do_help]

        true ->
          do_all_update = Keyword.get(opts, :all_update, false)
          do_all = do_all_update or Keyword.get(opts, :all, false)

          list = [:do_validate_base_dir]

          list
          |> process_clean_actions(opts, do_all)
          |> process_dependency_actions(opts, do_all, do_all_update)
          |> process_build_actions(opts, do_all)
          |> process_test_actions(opts, do_all)
          |> process_doc_actions(opts, do_all)
          |> maybe_add_help
      end

    %{
      config: %{
        base_dir: base_dir,
        components: components,
        db_opts: db_opts(opts),
        elixir_env: elixir_env
      },
      actions: actions_list
    }
  end

  defp process_clean_actions(list, opts, do_all) do
    do_clean_all = do_all or Keyword.get(opts, :clean_all, false)

    list
    |> maybe_add_action(
      :do_clean_elixir_ls,
      do_clean_all or Keyword.get(opts, :clean_elixir_ls, false)
    )
    |> maybe_add_action(
      :do_clean_elixir_plt,
      do_clean_all or Keyword.get(opts, :clean_elixir_plt, false)
    )
    |> maybe_add_action(
      :do_clean_elixir_build,
      do_clean_all or Keyword.get(opts, :clean_elixir_build, false)
    )
    |> maybe_add_action(
      :do_clean_elixir_deps,
      do_clean_all or Keyword.get(opts, :clean_elixir_deps, false)
    )
    |> maybe_add_action(:do_clean_db, do_clean_all or Keyword.get(opts, :clean_db, false))
    |> maybe_add_action(:do_clean_db_migrations, Keyword.get(opts, :clean_db_migrations, false))
  end

  defp process_dependency_actions(list, opts, do_all, do_all_update) do
    list
    |> maybe_add_action(
      :do_update_elixir_deps,
      do_all_update or Keyword.get(opts, :update_elixir_deps, false)
    )
    |> maybe_add_action(
      :do_install_elixir_deps,
      do_all or Keyword.get(opts, :install_elixir_deps, false)
    )
  end

  defp process_build_actions(list, opts, do_all) do
    do_build_all = do_all or Keyword.get(opts, :build_all, false)

    list
    |> maybe_add_action(:do_build_elixir, do_build_all or Keyword.get(opts, :build_elixir, false))
    |> maybe_add_action(
      :do_build_db_migrations,
      do_build_all or Keyword.get(opts, :build_db_migrations, false)
    )
  end

  defp process_test_actions(list, opts, do_all) do
    do_test_all = do_all or Keyword.get(opts, :test_all, false)

    list
    |> maybe_add_action(
      :do_test_elixir_unit,
      do_test_all or Keyword.get(opts, :test_elixir_unit, false)
    )
    |> maybe_add_action(
      :do_test_elixir_integration,
      do_test_all or Keyword.get(opts, :test_elixir_integration, false)
    )
    |> maybe_add_action(
      :do_test_elixir_doctest,
      do_test_all or Keyword.get(opts, :test_elixir_doctest, false)
    )
    |> maybe_add_action(
      :do_test_elixir_credo,
      do_test_all or Keyword.get(opts, :test_elixir_credo, false)
    )
    |> maybe_add_action(
      :do_test_elixir_dialyzer,
      do_test_all or Keyword.get(opts, :test_elixir_dialyzer, false)
    )
  end

  defp process_doc_actions(list, opts, do_all) do
    do_build_all_docs = do_all or Keyword.get(opts, :build_all_docs, false)

    list
    |> maybe_add_action(
      :do_build_elixir_docs,
      do_build_all_docs or Keyword.get(opts, :build_elixir_docs, false)
    )
    |> maybe_add_action(
      :do_build_db_docs,
      do_build_all_docs or Keyword.get(opts, :build_db_docs, false)
    )
  end

  defp maybe_add_action(list, action, true), do: [action | list]
  defp maybe_add_action(list, _action, false), do: list

  defp maybe_add_help([:do_validate_base_dir]), do: [:do_help]
  defp maybe_add_help(list), do: list

  defp db_opts(opts) do
    [
      host: Keyword.get(opts, :db_host, "localhost"),
      port: Keyword.get(opts, :db_port, 5432),
      user: Keyword.get(opts, :db_user, "postgres"),
      database: Keyword.get(opts, :db_name, "postgres"),
      dbadmin_password:
        Keyword.get(opts, :dbadmin_password, "musesystems-insecure-publicly-known-password")
    ]
  end

  defp process_jobs(params) do
    actions = params.actions
    base_dir = params.config.base_dir
    components = params.config.components
    db_opts = params.config.db_opts
    elixir_env = params.config.elixir_env || System.get_env("MIX_ENV") || "dev"

    with :ok <- maybe_print_help(actions),
         :ok <- maybe_validate_base_dir(actions, base_dir),
         :ok <- maybe_clean_ls(actions, base_dir, components),
         :ok <- maybe_clean_plt(actions, base_dir, components),
         :ok <- maybe_clean_build(actions, base_dir, components),
         :ok <- maybe_clean_deps(actions, base_dir, components),
         :ok <- maybe_install_deps(actions, base_dir, components),
         :ok <- maybe_update_deps(actions, base_dir, components),
         :ok <- maybe_clean_db(actions, base_dir, db_opts),
         :ok <- maybe_clean_db_migrations(actions, base_dir, components),
         :ok <- maybe_build_elixir(actions, base_dir, components, elixir_env),
         :ok <- maybe_build_db_migrations(actions, base_dir, components),
         :ok <- maybe_run_tests(actions, base_dir, components),
         :ok <- maybe_build_docs_elixir(actions, base_dir, components),
         :ok <- maybe_build_docs_db(actions, base_dir, components, db_opts) do
      Logger.flush()
      System.halt(0)
    else
      {:error, msg} ->
        Logger.error("==msbms_build==::process_jobs::ERROR #{msg}")
        Logger.flush()
        System.halt(1)
    end
  end

  defp maybe_validate_base_dir(actions, base_dir) do
    if :do_validate_base_dir in actions do
      Enum.all?(MsbmsBuildLib.project_markers(), fn marker ->
        path = Path.join(base_dir, marker)
        File.exists?(path) and validate_marker_content(marker, path)
      end)
      |> case do
        true -> :ok
        false -> {:error, "Invalid base directory: #{base_dir}"}
      end
    else
      :ok
    end
  end

  defp validate_marker_content("LICENSE.md", path) do
    case File.read(path) do
      {:ok, content} ->
        String.contains?(content, "Muse Systems Business Management System License Agreement")

      _ ->
        false
    end
  end

  defp validate_marker_content(_, _), do: true

  defp maybe_clean_ls(actions, base_dir, components) do
    if :do_clean_elixir_ls in actions do
      MsbmsBuildLib.clean_ls(base_dir, components)
    else
      :ok
    end
  end

  defp maybe_clean_plt(actions, base_dir, components) do
    if :do_clean_elixir_plt in actions do
      MsbmsBuildLib.clean_plt(base_dir, components)
    else
      :ok
    end
  end

  defp maybe_clean_build(actions, base_dir, components) do
    if :do_clean_elixir_build in actions do
      MsbmsBuildLib.clean_build(base_dir, components)
    else
      :ok
    end
  end

  defp maybe_clean_deps(actions, base_dir, components) do
    if :do_clean_elixir_deps in actions do
      MsbmsBuildLib.clean_deps(base_dir, components)
    else
      :ok
    end
  end

  defp maybe_clean_db(actions, base_dir, db_opts) do
    if :do_clean_db in actions do
      MsbmsBuildLib.clean_db(base_dir, db_opts)
    else
      :ok
    end
  end

  defp maybe_clean_db_migrations(actions, base_dir, components) do
    if :do_clean_db_migrations in actions do
      MsbmsBuildLib.clean_db_migrations(base_dir, components)
    else
      :ok
    end
  end

  defp maybe_build_elixir(actions, base_dir, components, elixir_env) do
    if :do_build_elixir in actions do
      MsbmsBuildLib.build_elixir(base_dir, components, elixir_env)
    else
      :ok
    end
  end

  defp maybe_build_db_migrations(actions, base_dir, components) do
    if :do_build_db_migrations in actions do
      MsbmsBuildLib.build_migrations(base_dir, components)
    else
      :ok
    end
  end

  defp maybe_build_docs_elixir(actions, base_dir, components) do
    if :do_build_elixir_docs in actions do
      MsbmsBuildLib.build_docs_elixir(base_dir, components)
    else
      :ok
    end
  end

  defp maybe_build_docs_db(actions, base_dir, components, db_opts) do
    if :do_build_db_docs in actions do
      MsbmsBuildLib.build_docs_db(base_dir, components, db_opts)
    else
      :ok
    end
  end

  defp maybe_install_deps(actions, base_dir, components) do
    if :do_install_elixir_deps in actions do
      MsbmsBuildLib.install_elixir_deps(base_dir, components)
    else
      :ok
    end
  end

  defp maybe_update_deps(actions, base_dir, components) do
    if :do_update_elixir_deps in actions do
      MsbmsBuildLib.update_elixir_deps(base_dir, components)
    else
      :ok
    end
  end

  defp maybe_run_tests(actions, base_dir, components) do
    test_opts = [
      test_unit: :do_test_elixir_unit in actions,
      test_integration: :do_test_elixir_integration in actions,
      test_doctest: :do_test_elixir_doctest in actions,
      run_credo: :do_test_elixir_credo in actions,
      run_dialyzer: :do_test_elixir_dialyzer in actions
    ]

    if Enum.any?(test_opts, fn {_key, value} -> value end) do
      MsbmsBuildLib.run_tests(base_dir, components, test_opts)
    else
      :ok
    end
  end

  defp maybe_print_help(actions) do
    if :do_help in actions do
      IO.puts("""
      MSBMS Build Script
      ==================

      This script provides tools for building, cleaning, testing, and managing
      components of the Muse Systems Business Management System Elixir project.
      It handles various tasks related to Elixir code, dependencies, and database operations.

      Usage: ./msbms_build.exs [OPTIONS]

      OPTIONS:
      --help                  Display this help information
      --base-dir PATH         Specify the base directory of the MSBMS project
                              (defaults to current working directory)
      --component, -c NAME    Specify a component to operate on
                              (can be specified multiple times)
                              (defaults to all components if not specified)
      --elixir-env ENV        Specify the Elixir environment (defaults to "dev")
      --log-level LEVEL       Set the logging level (defaults to "info")
      --dbadmin-password PASS When cleaning the development database (see --clean-db),
                              sets the password which will be set for the
                              `ms_syst_privileged` role created by the bootstrap
                              script.  If not provided, the default password:
                              `musesystems-insecure-publicly-known-password`
                              will be used.

      ACTIONS:
      --all                   Perform all actions
      --all-update            Perform all actions with dependency updates

      Clean Actions:
      --clean-all             Remove all file types except for database migrations
      --clean-elixir-ls       Remove Elixir Language Server files
      --clean-elixir-plt      Remove Dialyzer PLT files
      --clean-elixir-build    Remove build artifacts
      --clean-elixir-deps     Remove dependency files
      --clean-db              Resets the database dropping all objects and running the
                              bootstrap script.  After reset, the specified database
                              user will be granted the `ms_syst_documentation` role.
                              (Use --dbadmin-password to override the default password)
      --clean-db-migrations   Remove database migration files.  Note that cleaning
                              database migrations is considered a sensitive
                              operation when dealing with subsystems as migrations
                              in those context aren't meant to be regularly
                              rebuilt.  As such, this operation is not performed
                              when the `clean-all` action is specified and must
                              be explicitly requested.

      Build Actions:
      --build-all             Build all components
      --build-elixir          Build Elixir components and refresh Dialyzer PLT files
      --build-db-migrations   Build database migrations

      Documentation Actions:
      --build-elixir-docs     Generate Elixir documentation
      --build-db-docs         Generate database documentation
      --build-all-docs        Generate all documentation types

      Dependency Actions:
      --install-elixir-deps   Install Elixir dependencies
      --update-elixir-deps    Update Elixir dependencies

      Test Actions:
      --test-all              Run all tests (unit, integration, doctest, credo, dialyzer)
      --test-elixir-unit      Run only unit tests
      --test-elixir-integration Run only integration tests
      --test-elixir-doctest   Run only doctests
      --test-elixir-credo     Run only credo tests
      --test-elixir-dialyzer  Run only dialyzer tests

      DATABASE CONNECTION OPTIONS:

      Building database documentation and cleaning the database both require an
      active database connection.  The database role used to generate documentation
      must be a member of the `ms_syst_documentation` group role prior to using
      this build script.  Database cleaning functions require a superuser role as
      the clean process will both drop and create roles and databases.

      Note that we do not accept possibly sensitive credentials as command line
      arguments; specifically this is true for the database password of the
      database user specified by the `--db-user` option.  Instead, we expect
      either a correctly configured `.pgpass` file or the use of environment
      variables to pass credentials to the build script.  See the PostgreSQL
      documentation for more information on the either configuration option.

      --db-host HOST         Database host (default: 127.0.0.1)
      --db-port PORT         Database port (default: 5432)
      --db-user USER         Database user (required for DB documentation)

      EXAMPLES:
      ./msbms_build.exs --clean-elixir-ls
      ./msbms_build.exs -c component1 -c component2 --clean-elixir-ls
      ./msbms_build.exs --component=component1 --clean-elixir-deps
      ./msbms_build.exs --build-elixir-docs
      ./msbms_build.exs -c component1 --build-all-docs --db-user postgres
      ./msbms_build.exs --install-elixir-deps
      ./msbms_build.exs -c component1 --update-elixir-deps
      ./msbms_build.exs --test-all
      ./msbms_build.exs -c component1 -c component2 --test-elixir-unit

      """)
    end

    :ok
  end
end

MsbmsBuild.main(System.argv())
