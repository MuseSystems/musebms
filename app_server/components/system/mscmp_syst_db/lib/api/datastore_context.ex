# Source File: datastore_context.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/api/datastore_context.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.DatastoreContext do
  @moduledoc """
  Provides basic OTP related features for Datastore Contexts.

  Usually functions in this API are called when processing
  `MscmpSystDb.Datastore` module functions.  However, there are times
  when direct Datastore Context manipulation is appropriate, such as stopping
  and then restarting a specific Context for maintenance reasons.
  """

  alias MscmpSystDb.Runtime
  alias MscmpSystDb.Types
  alias MscmpSystDb.Types.DatastoreContext
  alias MscmpSystDb.Types.DatastoreOptions

  @doc """
  Returns the Child Specification used to start the DatastoreContext service.

  ## Parameters

    * `datastore_options` - a required Map of values which describe the
      Datastore and Datastore Context related connection options.  See
      `t:MscmpSystDb.Types.DatastoreOptions.t/0` for more.

    * `context` - the identity of the context as understood by the system.
      The context name is both the identity of the context as an Ecto Repo and
      is also used for the child specification ID value as there is the
      possibility of multiple contexts to start under the Datastore Supervisor
      process.

    * `opts` - a Keyword List of additional key/value call configurations.  See
      the "Options" section for details.

  ## Options

    #{Runtime.Datastore.get_get_context_child_spec_opts_docs()}

  ## Returns

  * `t:Supervisor.child_spec/0` - The Child Specification for the Datastore
    Context to be started.
  """
  @spec child_spec(DatastoreOptions.t(), Types.context_name() | DatastoreContext.t()) ::
          Supervisor.child_spec()
  @spec child_spec(DatastoreOptions.t(), Types.context_name() | DatastoreContext.t(), Keyword.t()) ::
          Supervisor.child_spec()
  defdelegate child_spec(datastore_options, context, opts \\ []),
    to: Runtime.Datastore,
    as: :get_context_child_spec

  @doc """
  Starts a Datastore Context as a linked process to the caller.

  Typically this function is called once for each Context defined for a
  Datastore by the `MscmpSystDb.Datastore.start_link/1` function.
  However there are some cases where starting a Datastore Context independently
  can be desirable, such as the Context was earlier stopped for some reason and
  needs to be started under it's original Datastore Supervisor.

  ## Parameters

    * `datastore_options` - see the `datastore_options` parameter for
      `MscmpSystDb.DatastoreContext.child_spec/3`.  This option is
      required.

    * `datastore_context` - a required map describing the Context to be started.
      See `t:MscmpSystDb.Types.datastore_context()` for more information.

    * `opts` - a Keyword List of additional key/value call configurations.  See
      the "Options" section for details.

  ## Options

    #{Runtime.Datastore.get_start_link_context_opts_docs()}
  """
  @spec start_link(DatastoreOptions.t(), DatastoreContext.t()) ::
          Supervisor.on_start()
  @spec start_link(DatastoreOptions.t(), DatastoreContext.t(), Keyword.t()) ::
          Supervisor.on_start()
  defdelegate start_link(datastore_options, datastore_context, opts \\ []),
    to: Runtime.Datastore,
    as: :start_link_context
end
