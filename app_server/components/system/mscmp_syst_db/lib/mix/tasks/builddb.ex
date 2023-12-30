# Source File: builddb.ex
# Location:    musebms/components/system/mscmp_syst_db/lib/mix/tasks/builddb.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mix.Tasks.Builddb do
  @shortdoc """
  Builds database sources into their respective migrations according to build plans.
  """

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
      {type = "sql", file = "tables/table_two.sql"},
      {type = "plan", file = "subplans/subplans.component.toml"}
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
      migration file name.  All sponsor numbers in the range 0 - 1295 are
      reserved for Muse Systems internal use and some specific values in that
      range currently have assigned meanings.  General public software releases
      from Muse Systems will have a sponsor value of `820` (`MS` in Base 36),
      software versions including sponsor number `821` (`MT` in Base 36)
      indicate software created for internal, development testing purposes which
      should never be part of a public release of the software.

    * `sponsor_modification` - This field allows for sponsored customization to
      both be versioned and sequenced in the migration process.  This is the
      fifth element of the migration name.  For non-sponsored migrations, this
      field should just be left at zero.


    * `load_files` - A list of SQL files and sub-plans to include in the build.
      Collectively, these are "Load File Items".

  Each Load File Item may take one of three forms:

    1. `"path/to/file.sql"` - A simple string is interpreted as the path to an
       SQL file to load into a migration.

    2. `{type = "sql", file = "path/to/file.sql"}` - This is the same as the
       simple file path of form 1.  Using this form could allow for a slightly
       cleaner representation if sat in a group of sub-plan Load File Items.

    3. `{type = "plan", file = "path/to/subplan.toml"}` - In this form the path
       indicates that the file is a nested build plan, or sub-plan, whose
       directives should be followed at this location.  A sub-plan is itself a
       normal build plan.  By convention, a sub-plan file name should take the
       form: `subplans.<descriptive_name>.toml`; unlike the build plan naming
       convention, following the sub-plan naming convention is not required.
       While build plans may be nested arbitrarily deep, a best practice is to
       only use a single level of nesting.

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

  use Mix.Task

  alias MscmpSystDb.Impl.Migrations

  require IEx

  @default_src "database"
  @default_dst "priv/database"

  @switches [
    source: :string,
    destination: :string,
    type: :string,
    clean: :boolean
  ]

  @aliases [
    s: :source,
    d: :destination,
    t: :type,
    c: :clean
  ]

  @spec run([binary()]) :: :ok
  def run(args) do
    with {opts_cli, _, _} <- OptionParser.parse(args, aliases: @aliases, strict: @switches),
         {:ok, migrations_created} <- call_build_migrations(opts_cli) do
      migrations_created
      |> Enum.sort()
      |> Enum.each(&IO.puts/1)

      :ok
    else
      error ->
        raise MscmpSystError,
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
    raise MscmpSystError,
      code: :invalid_parameter,
      message: "The '--type' parameter was missing or invalid but is required.",
      cause: bad_options
  end
end
