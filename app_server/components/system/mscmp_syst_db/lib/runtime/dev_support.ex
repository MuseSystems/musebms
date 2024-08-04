# Source File: dev_support.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/runtime/dev_support.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.Runtime.DevSupport do
  @moduledoc false

  alias MscmpSystDb.Types.{DatastoreContext, DatastoreOptions, DbServer}

  @devsupport_context "0000mt.devspt.MscmpSystDb.ContextRole"
  @testsupport_context "0000mt.tstspt.MscmpSystDb.ContextRole"

  ##############################################################################
  #
  # Options Definition
  #

  common_opts = [
    starting_pool_size: [
      type: :integer,
      default: 5,
      doc: """
      The number of database connections the login Context will establish from
      the application.
      """
    ],
    db_host: [
      type: :string,
      default: "127.0.0.1",
      doc: """
      A string indicating the host address of the database server.  This can be
      an IP address or resolvable DNS entry.
      """
    ],
    db_port: [
      type: :integer,
      default: 5432,
      doc: """
      An integer indicating the TCP port on which to contact the database
      server.
      """
    ],
    dbadmin_pool_size: [
      type: :integer,
      default: 1,
      doc: """
      The number of database connections which will be opened to support DBA or
      Privileged operations.
      """
    ],
    dbadmin_password: [
      type: :string,
      default: "musesystems.publicly.known.insecure.devsupport.password",
      doc: """
      A string value for the standard `ms_syst_privileged` database role account
      created via the database bootstrapping script.
      """
    ],
    server_salt: [
      type: :string,
      default: "musesystems.publicly.known.insecure.devsupport.salt",
      doc: """
      A binary value providing a Datastore level salting value used in different
      hashing operations.
      """
    ]
  ]

  get_datastore_options_opts =
    [
      database_name: [
        type: :string,
        default: "ms_devsupport_database",
        doc: """
        The name of the database on the database server.
        """
      ],
      datastore_code: [
        type: :string,
        default: "musesystems.publicly.known.insecure.devsupport.code",
        doc: """
        A binary value providing a Datastore level salting value used in
        different hashing operations.
        """
      ],
      datastore_name: [
        type: :string,
        default: "ms_devsupport_database",
        doc: """
        A name for use by the application to identify a given Datastore.
        This value will often time be the same as the `database_name` value.
        """
      ],
      description_prefix: [
        type: :string,
        default: "Muse Systems DevSupport",
        doc: """
        A string value which is prefixed to the descriptions of the created
        database contexts and which appear in the database role descriptions.
        """
      ],
      database_role_prefix: [
        type: :string,
        default: "ms_devsupport",
        doc: """
        A string value which is prefixed to the names of the database roles
        created to back the Datastore Contexts.
        """
      ],
      context_name: [
        type: :string,
        default: @devsupport_context,
        doc: """
        A string value which provides a unique context name for the login
        Context identified by this function.
        """
      ],
      database_password: [
        type: :string,
        default: "musesystems.publicly.known.insecure.devsupport.apppassword",
        doc: """
        A string value which is the database password that the login Datastore
        Context uses to log into the database.
        """
      ]
    ] ++ common_opts

  get_testsupport_datastore_options_opts =
    [
      database_name: [
        type: :string,
        default: "ms_testsupport_database",
        doc: """
        The name of the database on the database server.
        """
      ],
      datastore_code: [
        type: :string,
        default: "musesystems.publicly.known.insecure.testsupport.code",
        doc: """
        A binary value providing a Datastore level salting value used in
        different hashing operations.
        """
      ],
      datastore_name: [
        type: :string,
        default: "ms_testsupport_database",
        doc: """
        A name for use by the application to identify a given Datastore. This
        value will often time be the same as the `database_name` value.
        """
      ],
      description_prefix: [
        type: :string,
        default: "Muse Systems TestSupport",
        doc: """
        A string value which is prefixed to the descriptions of the created
        database contexts and which appear in the database role descriptions.
        """
      ],
      database_role_prefix: [
        type: :string,
        default: "ms_testsupport",
        doc: """
        A string value which is prefixed to the names of the database roles
        created to back the Datastore Contexts.
        """
      ],
      context_name: [
        type: :string,
        default: @testsupport_context,
        doc: """
        A string value which provides a unique context name for the login
        Context identified by this function.
        """
      ],
      database_password: [
        type: :string,
        default: "musesystems.publicly.known.insecure.testsupport.apppassword",
        doc: """
        A string value which is the database password that the login Datastore
        Context uses to log into the database.
        """
      ]
    ] ++ common_opts

  drop_database_opts = [
    context_registry: [
      type: {:or, [{:in, [:global]}, :atom]},
      doc: """
      Identifies a process registry which will be used to register Datastore
      Context (`Ecto.Repo`) instances. A valid value for this option can be
      either `:global` to use the Erlang `:global` module or any other module
      which implements a :global compatible API.
      """
    ]
  ]

  ##############################################################################
  # :
  # get_devsupport_context_name
  #

  @spec get_devsupport_context_name() :: String.t()
  def get_devsupport_context_name, do: @devsupport_context

  ##############################################################################
  #
  # get_testsupport_context_name
  #

  @spec get_testsupport_context_name() :: String.t()
  def get_testsupport_context_name, do: @testsupport_context

  ##############################################################################
  #
  # get_datastore_options
  #

  @get_datastore_options_opts NimbleOptions.new!(get_datastore_options_opts)

  @spec get_get_datastore_options_opts_docs() :: String.t()
  def get_get_datastore_options_opts_docs, do: NimbleOptions.docs(@get_datastore_options_opts)

  @spec get_datastore_options(Keyword.t()) :: DatastoreOptions.t()
  def get_datastore_options(opts) do
    opts = NimbleOptions.validate!(opts, @get_datastore_options_opts)

    %DatastoreOptions{
      database_name: opts[:database_name],
      datastore_code: opts[:database_code],
      datastore_name: opts[:datastore_name],
      contexts: [
        %DatastoreContext{
          context_name: nil,
          description: opts[:description_prefix] <> " Owner",
          database_role: opts[:database_role_prefix] <> "_owner",
          database_password: nil,
          starting_pool_size: 0,
          start_context: false,
          login_context: false,
          database_owner_context: true
        },
        %DatastoreContext{
          context_name: opts[:context_name],
          description: opts[:description_prefix] <> " Context Role",
          database_role: opts[:database_role_prefix] <> "_context",
          database_password: opts[:database_password],
          starting_pool_size: opts[:starting_pool_size],
          start_context: true,
          login_context: true
        }
      ],
      db_server: %DbServer{
        server_name: "devsupport_server",
        start_server_instances: true,
        db_host: opts[:db_host],
        db_port: opts[:db_port],
        db_show_sensitive: true,
        db_max_instances: 1,
        server_pools: [],
        server_salt: opts[:server_salt],
        dbadmin_password: opts[:dbadmin_password],
        dbadmin_pool_size: opts[:dbadmin_pool_size]
      }
    }
  end

  ##############################################################################
  #
  # get_testsupport_datastore_options
  #

  @get_testsupport_datastore_options_opts NimbleOptions.new!(
                                            get_testsupport_datastore_options_opts
                                          )

  @spec get_get_testsupport_datastore_options_opts_docs() :: String.t()
  def get_get_testsupport_datastore_options_opts_docs,
    do: NimbleOptions.docs(@get_testsupport_datastore_options_opts)

  @spec get_testsupport_datastore_options(Keyword.t()) :: DatastoreOptions.t()
  def get_testsupport_datastore_options(opts) do
    opts = NimbleOptions.validate!(opts, @get_testsupport_datastore_options_opts)

    _ = get_datastore_options(opts)
  end

  ##############################################################################
  #
  # load_database
  #

  @spec load_database(DatastoreOptions.t(), String.t()) ::
          {:ok, [String.t()]} | {:error, MscmpSystError.t()}
  def load_database(datastore_options, datastore_type) do
    database_owner = Enum.find(datastore_options.contexts, &(&1.database_owner_context == true))

    database_context =
      Enum.find(
        datastore_options.contexts,
        &((&1.database_owner_context == false or &1.database_owner_context == nil) and
            &1.login_context == true)
      )

    {:ok, :ready, _} = MscmpSystDb.create_datastore(datastore_options)

    {:ok, _} =
      MscmpSystDb.upgrade_datastore(datastore_options, datastore_type,
        ms_owner: database_owner.database_role,
        ms_appusr: database_context.database_role
      )
  end

  ##############################################################################
  #
  # drop_database
  #

  @drop_database_opts NimbleOptions.new!(drop_database_opts)

  @spec get_drop_database_opts_docs() :: String.t()
  def get_drop_database_opts_docs, do: NimbleOptions.docs(@drop_database_opts)

  @spec drop_database(DatastoreOptions.t(), Keyword.t()) :: :ok
  def drop_database(datastore_options, opts) do
    opts = NimbleOptions.validate!(opts, @drop_database_opts)

    :ok = MscmpSystDb.stop_datastore(datastore_options, opts)
    :ok = MscmpSystDb.drop_datastore(datastore_options)
  end
end
