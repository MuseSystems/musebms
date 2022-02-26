# Source File: builddb.ex
# Location:    components/system/msbms_syst_datastore/lib/mix/tasks/builddb.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule Mix.Tasks.Builddb do
  use Mix.Task

  @moduledoc """
  Builds database sources into their respective migrations according to build
  plans.

  ## Options:

    * `--type` or `-t`: The type of database to build.  This is a required switch
      and there is no default value.


    * `--source` or `-s`: Directory where the `buildplans.<type>.toml` can be
      found.  If not provided a default directory of `database`in the project
      root is assumed.


    * `--destination` or `-d`: Directory where to build the migrations.  The
      default value is `priv/database` is used if not provided.  Note that the
      migrations files will be built inside a directory built from both the
      destination directory from this switch and the database type:
      `<destination>/<type>`.

    * `--clean` or `-c`: Clean previously created migrations prior to building
      the migrations.  If this flag is not provided, migrations that already
      exist are skipped and only new migrations are built.  When the previous
      migrations are cleaned out, the build process will create all migrations.

  ## Description:

  This module implements the build process for a modified version of the common
  "migrations" database development/deployment strategy.  In the model
  implemented here, the developer creates source files in PL/pgSQL and then
  updates a build plans file which determines how the individual source files
  are copied into individual migration files which will then be deployed to the
  database.  This allows the developer to treat database source more closely to
  non-database source code, at least during initial database development.

  This migrations model allows for creation of multiple, different databases for
  applications that require more than a single database definition.  These
  multiple database definitions are referred to as _*database types*_.

  This build process expects the source files to be kept within an independent
  source directory, by default: `database` of the project root.  In addition to
  the source files, the database directory should also contain TOML files named
  `buildplans.<database type>.toml` which define what migrations will be built
  and in what order the database source files will be copied to them.  Each
  database type will have its own TOML build plans file.

  The build plan file is a TOML file with an array of tables of `[[buildplan]]`:
  ```toml
  [[build_plan]]
  release              = 1
  version              = 1
  update               = 0
  sponsor              = 820
  sponsor_modification = 0
  load_files = [
      "tables/table_one.sql",
      "tables/table_two.sql",
  ]
  ```
  The fields above are defined as:

    * `release` - The major version number of the migration.  The first element
      of the migration file name.


    * `version` - The minor version number of the migration.  The second element
      of the migration file name.


    * `update` - The patch version number of the migration.  The third element
      of the migration name.


    * `sponsor` - In cases where specific clients that use the software are able
      to sponsor client-specific customizations, this field identifies the
      client sponsoring the change.  This element is the fourth element of the
      migration file name.  For non-sponsored changes, a special sponsor value
      designated to mean 'Muse Systems' is used (`820`).


    * `sponsor_modification` - This field allows for sponsored customization to
      both be versioned and sequenced in the migration process.  This is the
      fifth element of the migration name.  For non-sponsored migrations, this
      field should just be left at zero.


    * `load_files` - A list of file paths to the individual source files listed
      in the order of which they should be applied to the database.


  Each table in the array is a specific build plan which will build a single
  migration.  The body of the migration itself is simply the files in the
  `load_files` list copied to the migration file in the order of the list.  Note
  that the migration code is wrapped in a PostgreSQL `DO` block (PL/pgSQL) so
  source files may use all the capabilities of PostgreSQL anonymous blocks as
  are they subject to its limitations.

  Later, on deployment, the migrations will be applied in migration name order.
  The migration name is constructed from the versioning information in the
  `buildplan` table with each of the versioning fields (recorded as integers)
  being added in their zero padded, base-36 representations.
  """

  alias MsbmsSystDatastore.Impl.Migrations
  require IEx
  @default_src "database"
  @default_dst "priv/database"

  @shortdoc """
  Builds database sources into their respective migrations according to build plans.
  """
  @spec run([binary()]) :: :ok
  def run(args) do
    with {opts_cli, _, _} <-
           OptionParser.parse(args,
             aliases: [s: :source, d: :destination, t: :type, c: :clean],
             strict: [source: :string, destination: :string, type: :string, clean: :boolean]
           ),
         {:ok, migrations_created} <- call_build_migrations(opts_cli) do
      migrations_created
      |> Enum.sort()
      |> Enum.each(&IO.puts/1)

      :ok
    else
      error ->
        raise MsbmsSystError,
          code: :file_error,
          message: "Failure building migrations.",
          cause: error
    end
  end

  defp call_build_migrations(opts_cli) do
    source_root_dir = Keyword.get(opts_cli, :source, @default_src)

    datastore_type =
      opts_cli
      |> Keyword.get(:type)
      |> validate_type()

    migrations_root_dir = Keyword.get(opts_cli, :destination, @default_dst)

    clean = Keyword.get(opts_cli, :clean, false)

    migration_options = [
      source_root_dir: source_root_dir,
      migrations_root_dir: migrations_root_dir,
      clean_migrations: clean
    ]

    Migrations.build_migrations(datastore_type, migration_options)
  end

  defp validate_type(type) when is_binary(type), do: type

  defp validate_type(bad_options) do
    raise MsbmsSystError,
      code: :invalid_parameter,
      message: "The '--type' parameter was missing or invalid but is required.",
      cause: bad_options
  end
end
