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

  defdelegate child_spec(context_name, opts \\ []),
    to: Runtime.Datastore,
    as: :get_context_child_spec

  defdelegate start_link(opts \\ []), to: Runtime.Datastore, as: :start_link_context
end
