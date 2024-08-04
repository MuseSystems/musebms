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

    #{Runtime.Datastore.get_get_context_child_spec_opts_docs()}
  """
  @spec child_spec(DatastoreOptions.t()) :: Supervisor.child_spec()
  @spec child_spec(DatastoreOptions.t(), Keyword.t()) :: Supervisor.child_spec()
  defdelegate child_spec(datastore_options, opts \\ []),
    to: Runtime.Datastore,
    as: :get_datastore_child_spec

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

    #{Runtime.Datastore.get_start_link_datastore_opts_docs()}

  """
  @spec start_link(DatastoreOptions.t()) :: Supervisor.on_start()
  @spec start_link(DatastoreOptions.t(), Keyword.t()) :: Supervisor.on_start()
  defdelegate start_link(datastore_options, opts \\ []),
    to: Runtime.Datastore,
    as: :start_link_datastore
end
