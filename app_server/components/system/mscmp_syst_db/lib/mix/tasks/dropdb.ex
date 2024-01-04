# Source File: dropdb.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/mix/tasks/dropdb.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mix.Tasks.Dropdb do
  @shortdoc """
  Drops the identified database schema type into a testing/development oriented
  database server.
  """

  @moduledoc """
  Drops a previously loaded development supporting Datastore.

  This command takes a number of options many of which match `Mix.Tasks.Loaddb`.
  Insofar as they have corresponding options, the options used with this Mix
  task should have values which match the command used to create the Datastore;
  failing to do this could cause the drop operation to fail or fail partially.

  >#### Usage Note {: .warning}
  >
  > There is nothing stopping you from using this command from dropping any
  > Datastore in the system and technically it should work.  But the only
  > supported use of this command is for dropping development supporting
  > databases originally loaded with the `Mix.Tasks.Loaddb` task.  Any other use
  > is at your own risk.

  Note that all options other than `--type` have default values which match the
  corresponding default values in `Mix.Task.Loaddb`.

  ## Options

    * `--ds-name` - The Datastore Name used to identify the Datastore in the
      application.  Specifically references parts of the supervisory system
      which manage the Datastore Contexts.  This is an optional string
      value which defaults to "ms_devsupport_database".

    * `--db-host` - The IP address or resolvable host name of the database
      server which hosts the Datastore to drop.  This is an optional string
      value which defaults to "127.0.0.1".

    * `--db-port` - The TCP port on which the database server is listening for
      connections.  This is an optional integer value which defaults to `5432`.

    * `--db-name` - The name of the database which backs the Datastore on the
      database server.  Often times this will be the same as the Datastore
      Name, but not necessarily so.  This is an optional string value which
      defaults to "ms_devsupport_database".

    * `--db-role-prefix`- a string value which is used to prefix the owner and
      login Context database role names created by the `Mix.Tasks.Loaddb` mix
      task.  This value is optional and defaults to "ms_devsupport".

    * `--context-name` - the name by which the login Context can be found
      withing the application.  This is an optional string value which defaults
      to "ms_devsupport_context".

    * `--dbadmin-pwd` - the password of the `ms_syst_privileged` database role
      on the target database.  This is an optional string value which defaults
      to "musesystems.publicly.known.insecure.devsupport.password".

    * `--clean-all` - if this switch is set, this task will delete all Datastore
      migration files created for the Component, including those that might not
      be related to the Datastore being dropped.  This is done by simply
      deleting the path directory provided in the `--destination` option.  This
      switch will supersede the `--clean` option if both switches are set.

    * `--clean` or `-c` - deletes any Datastore migrations built for the
      Datastore type identified by the `--type` switch.  This switch is
      superseded by the `--clean-all` option.

    * `--type` or `-t` - identifies the type of Datastore to clean when using
      the `--clean` option.  This option becomes required if the `--clean`
      switch is set.

    * `--destination` or `-d` - establishes the path in which Datastore
      migrations were built.  This option is only used if either the
      `--clean-all` or `--clean` options are also set.  This is an optional
      value which defaults to "priv/database".
  """

  use Mix.Task

  alias MscmpSystDb.Runtime.DevSupport

  @requirements ["app.start"]

  @switches [
    ds_name: :string,
    db_host: :string,
    db_port: :integer,
    db_name: :string,
    db_role_prefix: :string,
    context_name: :string,
    dbadmin_pwd: :string,
    clean_all: :boolean,
    clean: :boolean,
    type: :string,
    destination: :string
  ]

  @aliases [
    d: :destination,
    t: :type,
    c: :clean
  ]

  @spec run([binary()]) :: :ok
  def run(args) do
    {opts_cli, _, _} = OptionParser.parse(args, aliases: @aliases, strict: @switches)

    cond do
      Keyword.get(opts_cli, :clean_all, false) === true ->
        File.rm_rf!(opts_cli[:destination] || Path.join(["priv", "database"]))

      Keyword.get(opts_cli, :clean, false) === true ->
        ["priv", "database", opts_cli[:type]]
        |> Path.join()
        |> File.rm_rf!()
    end

    datastore_options = get_datastore_options(opts_cli)

    :ok = DevSupport.drop_database(datastore_options)
  end

  defp get_datastore_options(opts_cli) do
    opts = [
      database_name: opts_cli[:db_name],
      datastore_name: opts_cli[:ds_name],
      database_role_prefix: opts_cli[:db_role_prefix],
      context_name: opts_cli[:context_name],
      db_host: opts_cli[:db_host],
      db_port: opts_cli[:db_port],
      dbadmin_password: opts_cli[:dbadmin_pwd]
    ]

    DevSupport.get_datastore_options(opts)
  end
end
