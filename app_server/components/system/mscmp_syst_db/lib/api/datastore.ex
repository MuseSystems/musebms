# Source File: datastore.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/api/datastore.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.Datastore do
  @moduledoc """
  Provides basic OTP related features for Datastores.

  Functions in this module support running Datastores under supervision and
  creates a Datastore supervisor for managing Datastore Context worker
  processes.
  """

  alias MscmpSystDb.Runtime
  alias MscmpSystDb.Types.DatastoreOptions

  ##############################################################################
  #
  # Options Definition
  #

  option_defs = [
    datastore_name: [
      type:
        {:or,
         [nil, :atom, {:tuple, [{:in, [:via]}, :atom, :any]}, {:tuple, [{:in, [:global]}, :any]}]},
      type_doc: "`t:GenServer.name/0` or `nil`",
      doc: """
      Specifies the name for the Datastore Supervisor. If this option is not
      provided, the `datastore_options.datastore_name` value will be used as
      the default name for the Datastore Supervisor.  If this value identifies a
      process registry (e.g. `{:via, Registry, {MyApp.Registry, :my_registry}}`),
      this registry will become the default registry for all Datastore Contexts;
      a valid `context_registry` value overrides this default.
      """
    ],
    context_registry: [
      type: {:or, [:atom, nil]},
      type_doc: "`t:module/0` or `nil`",
      doc: """
      Specifies the name of a registry to use for registering named Datastore
      Contexts.
      """
    ],
    strategy: [
      type: :atom,
      default: :one_for_one,
      doc: """
      Specifies the restart strategy for the Datastore Supervisor.
      """
    ],
    restart: [
      type: :atom,
      default: :transient,
      doc: """
      Specifies the restart strategy for the Datastore Supervisor.
      """
    ],
    timeout: [
      type: :timeout,
      default: 60_000,
      doc: """
      Specifies the timeout value for the Datastore Supervisor.
      """
    ]
  ]

  ##############################################################################
  #
  # child_spec
  #
  #

  @child_spec_opts NimbleOptions.new!(
                     Keyword.take(option_defs, [
                       :datastore_name,
                       :strategy,
                       :restart,
                       :timeout,
                       :context_registry
                     ])
                   )

  @doc """
  Provides a Datastore child specification for use with supervisors.

  Note that this function is not `child_spec/1` as expected when a Supervisor
  attempts to start a process based on the module name alone.  This is because
  there is a required parameter which renders that method of starting a process
  invalid as there's no default value for the parameter (`datastore_options`).

  ## Parameters

    * `datastore_options` - a required Map of values which describe the
    Datastore and Datastore Context related connection options.  See
    `t:MscmpSystDb.Types.DatastoreOptions.t/0` for more.

    * `opts` - a Keyword list of options.  See the "Options" section for
      details.

  ## Options

    #{NimbleOptions.docs(@child_spec_opts)}
  """
  @spec child_spec(DatastoreOptions.t()) :: Supervisor.child_spec()
  @spec child_spec(DatastoreOptions.t(), Keyword.t()) :: Supervisor.child_spec()
  def child_spec(datastore_options, opts \\ []) do
    opts = NimbleOptions.validate!(opts, @child_spec_opts)
    Runtime.Datastore.get_datastore_child_spec(datastore_options, opts)
  end

  ##############################################################################
  #
  # start_link
  #
  #

  @start_link_opts NimbleOptions.new!(
                     Keyword.take(option_defs, [
                       :datastore_name,
                       :strategy,
                       :restart,
                       :timeout,
                       :context_registry
                     ])
                   )

  @doc """
  Starts the Datastore Supervisor and its requested child Datastore Contexts.

  When this function is called, a new `DynamicSupervisor` for the datastore is
  started and any Datastore Contexts which are identified in the
  `datastore_options` are also started and places under the Datastore
  Supervisor.

  ## Parameters

    * `datastore_options` - a required Map of values which describe the
    Datastore and Datastore Context related connection options.  See
    `t:MscmpSystDb.Types.DatastoreOptions.t/0` for more.

    * `opts` - See the "Options" section for
      details.

  ## Options

    #{NimbleOptions.docs(@start_link_opts)}

  """
  @spec start_link(DatastoreOptions.t()) :: Supervisor.on_start()
  @spec start_link(DatastoreOptions.t(), Keyword.t()) :: Supervisor.on_start()
  def start_link(datastore_options, opts \\ []) do
    opts = NimbleOptions.validate!(opts, @start_link_opts)
    Runtime.Datastore.start_link_datastore(datastore_options, opts)
  end
end
