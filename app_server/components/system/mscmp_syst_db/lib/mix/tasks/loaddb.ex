# Source File: loaddb.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/mix/tasks/loaddb.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mix.Tasks.Loaddb do
  @shortdoc """
  Loads the identified Datastore "type" into a testing/development oriented
  database server.
  """

  @moduledoc """
  Loads the identified Datastore "type" into a testing/development oriented
  database server.

  ## Options

  Most options come with reasonable default values for most development/testing
  scenarios.  Specific circumstances may require overriding the default values
  by explicitly providing the options documented below.

    * `--type` - the Datastore "type" which to load to the database.  This is
      a required string value and for which there is no default.  If the
      `--build` option is also set, the value of this option will indicate the
      type of the Datastore migrations to build.

    * `--db-host` - a string indicating the host address of the database server.
      This can be an IP address or resolvable DNS entry.  The default value is
      `127.0.0.1`.

    * `--db-port` - an integer indicating the TCP port on which to contact the
      database server.  The default value is the standard PostgreSQL port number
      `5432`.

    * `--db-name` - a binary value indicating a name for the database to use.
      The default database name is "ms_devsupport_database".

    * `--dbadmin-pwd` - a binary value for the standard `ms_syst_privileged`
      database role account created via the database bootstrapping script.  The
      default value is
      "musesystems.publicly.known.insecure.devsupport.password".

    * `--ds-name` - The Datastore Name used to identify the Datastore in the
      application.  Specifically references parts of the supervisory system
      which manage the Datastore Contexts.  This is an optional string
      value which defaults to "ms_devsupport_database".

    * `--ds-code` - a binary value providing a Datastore level salting value
      used in different hashing operations.  The default value is
      "musesystems.publicly.known.insecure.devsupport.code"

    * `--db-salt` - a binary value providing a Datastore level salting value
      used in different hashing operations.  The default value is
      "musesystems.publicly.known.insecure.devsupport.salt"

    * `--db-role-prefix` - a binary value which is prefixed to the names of the
      database roles created to back the Datastore Contexts. The default value
      is "ms_devsupport".

    * `--dbadmin-pool` - the number of database connections which will be opened
      to support DBA or Privileged operations.  The default value is `1`.

    * `--context-name` - a binary value which provides a unique context name for
      the login Context identified by this function.  The default value is
      "ms_devsupport_context".

    * `--context-pwd` - a binary value which is the database password that the
      login Datastore Context uses to log into the database.  The default value
      is "musesystems.publicly.known.insecure.devsupport.apppassword".

    * `--context-pool` - the number of database connections the login Context
      will establish from the application.  The default value is 5.

    * `--desc-prefix` - a binary value which is prefixed to the descriptions of
      the created database contexts and which appear in the database role
      descriptions.  The default value is "Muse Systems DevSupport".

    * `--build` - a switch which, if set, indicates that the `Mix.Task.Builddb`
      process should be called to build the Datastore migrations prior to
      migrating the new Datastore.  See the documentation for
      `Mix.Tasks.Builddb` for more information about that process.  By default,
      Datastore migrations are not built.

    * `--source` - only applies if the `--build` option is set.  Establishes the
      database source code directory from which to build migrations.  See the
      documentation for `Mix.Tasks.Builddb` for more.

    * `--destination` - only applies if the `--build` option is set.  Sets the
      destination path into which Datastore migrations will be built.  See the
      documentation for `Mix.Tasks.Builddb` for more.

    * `--clean` - a switch which indicates if the Datastore migrations to be
      built should be deleted and entirely rebuilt from the database source
      code.  This switch is only used if the `--build` option is also set.  See
      the documentation for `Mix.Tasks.Builddb` for more.
  """

  use Mix.Task

  alias MscmpSystDb.Runtime.DevSupport

  @requirements ["app.start"]

  @switches [
    ds_code: :string,
    ds_name: :string,
    db_host: :string,
    db_port: :integer,
    db_name: :string,
    db_salt: :string,
    db_role_prefix: :string,
    dbadmin_pwd: :string,
    dbadmin_pool: :integer,
    context_name: :string,
    context_pwd: :string,
    context_pool: :integer,
    desc_prefix: :string,
    build: :boolean,
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
    {opts_cli, _, _} = OptionParser.parse(args, aliases: @aliases, strict: @switches)

    if Keyword.get(opts_cli, :build, false) === true, do: :ok = Mix.Tasks.Builddb.run(args)

    datastore_options = get_datastore_options(opts_cli)

    {:ok, _} = DevSupport.load_database(datastore_options, opts_cli[:type])

    :ok
  end

  defp get_datastore_options(opts_cli) do
    opts = [
      database_name: opts_cli[:db_name],
      datastore_code: opts_cli[:ds_code],
      datastore_name: string_to_atom(opts_cli[:ds_name]),
      description_prefix: opts_cli[:desc_prefix],
      database_role_prefix: opts_cli[:db_role_prefix],
      context_name: string_to_atom(opts_cli[:context_name]),
      database_password: opts_cli[:context_pwd],
      starting_pool_size: opts_cli[:context_pool],
      db_host: opts_cli[:db_host],
      db_port: opts_cli[:db_port],
      server_salt: opts_cli[:db_salt],
      dbadmin_password: opts_cli[:dbadmin_pwd],
      dbadmin_pool_size: opts_cli[:dbadmin_pool]
    ]

    DevSupport.get_datastore_options(opts)
  end

  defp string_to_atom(nil), do: nil
  defp string_to_atom(value) when is_binary(value), do: String.to_atom(value)
end
