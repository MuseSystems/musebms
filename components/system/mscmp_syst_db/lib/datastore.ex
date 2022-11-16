# Source File: datastore.ex
# Location:    musebms/components/system/mscmp_syst_db/lib/datastore.ex
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
  alias MscmpSystDb.Runtime
  alias MscmpSystDb.Types

  @moduledoc """
  Provides basic OTP related features for Datastores.

  Functions in this module support running Datastores under supervision and
  creates a Datastore supervisor for managing Datastore Context worker
  processes.
  """

  @doc """
  Provides a Datastore child specification for use with supervisors.

  Note that this function is not `child_spec/1` as expected when a Supervisor
  attempts to start a process based on the module name alone.  This is because
  there is a required parameter which renders that method of starting a process
  invalid as there's no default value for the parameter (`datastore_options`).

  ## Parameters

    * `datastore_options` - a required Map of values which describe the
    Datastore and Datastore Context related connection options.  See
    `t:MscmpSystDb.Types.datastore_options/0` for more.

    * `opts` - a Keyword list of various options accepted or required by the
    `DynamicSupervisor.start_link/1` function.  Note that we provide some
    default values: `strategy: :one_for_one`, `restart: :transient`,
    `timeout: 60_000`, and the `:name` option is defaulted to the
    `datastore_options.datastore_name` value.
  """
  @spec child_spec(Types.datastore_options(), Keyword.t()) :: Supervisor.child_spec()
  defdelegate child_spec(datastore_options, opts \\ []),
    to: Runtime.Datastore,
    as: :get_datastore_child_spec

  @doc """
  Starts the Datastore Supervisor and its requested child Datastore Contexts.

  When this function is called, a new `DynamicSupervisor` for the datastore is
  started and any Datastore Contexts which are identified in the
  `datastore_options` are also started and places under the Datastore
  Supervisor.

  ## Options

    * `name` - establishes the name of the Datastore Supervisor and accepts any
    name which is valid according to the documentation for `GenServer`.  The
    default value for this parameter is the `datastore_name` value found in the
    `datastore_options` attribute which configures the Datastore.

    * `datastore_options` - a required Map of values which describe the
    Datastore and Datastore Context related connection options.  See
    `t:MscmpSystDb.Types.datastore_options/0` for more.
  """
  @spec start_link(Keyword.t()) :: Supervisor.on_start_child()
  defdelegate start_link(opts \\ []), to: Runtime.Datastore, as: :start_link_datastore
end
