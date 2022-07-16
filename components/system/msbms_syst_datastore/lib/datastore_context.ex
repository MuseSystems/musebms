# Source File: datastore_context.ex
# Location:    components/system/msbms_syst_datastore/lib/datastore_context.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystDatastore.DatastoreContext do
  alias MsbmsSystDatastore.Runtime
  alias MsbmsSystDatastore.Types

  @moduledoc """
  Provides basic OTP related features for Datastore Contexts.

  Usually functions in this API are called when processing
  `MsbmsSystDatastore.Datastore` module functions.  However, there are times
  when direct Datastore Context manipulation is appropriate, such as stopping
  and then restarting a specific Context for maintenance reasons.

  ## Parameters

    * `datastore_options` - a required Map of values which describe the
    Datastore and Datastore Context related connection options.  See
    `t:MsbmsSystDatastore.Types.datastore_options/0` for more.

    * `context_name` - the identity of the context as understood by the system.
    The context name is both the identity of the context as an Ecto Repo and is
    also used for the child specification ID value as there is the possibility
    of multiple contexts to start under the Datastore Supervisor process.

    * `options` - a Keyword List of optional values.  Currently there are no
    attributes which are expected in this list and it is safe to omit.
  """
  @spec child_spec(Types.datastore_options(), Types.context_name(), Keyword.t()) ::
          Supervisor.child_spec()
  defdelegate child_spec(datastore_options, context_name, opts \\ []),
    to: Runtime.Datastore,
    as: :get_context_child_spec

  @doc """
  Starts a Datastore Context as a linked process to the caller.

  Typically this function is called once for each Context defined for a
  Datastore by the `MsbmsSystDatastore.Datastore.start_link/1` function.
  However there are some cases where starting a Datastore Context independently
  can be desirable, such as the Context was earlier stopped for some reason and
  needs to be started under it's original Datastore Supervisor.

  ## Options

    * `name` - see the `context_name` parameter for
    `MsbmsSystDatastore.DatastoreContext.child_spec/3`.

    * `datastore_options` - see the `datastore_options` parameter for
    `MsbmsSystDatastore.DatastoreContext.child_spec/3`.  This option is
    required.

    * `context` - a required map describing the Context to be started.  See
    `t:MsbmsSystDatastore.Types.datastore_context()` for more information.
  """
  @spec start_link(Keyword.t()) :: Supervisor.on_start_child()
  defdelegate start_link(opts \\ []), to: Runtime.Datastore, as: :start_link_context
end
