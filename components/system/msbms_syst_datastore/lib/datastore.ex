# Source File: datastore.ex
# Location:    components/system/msbms_syst_datastore/lib/datastore.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystDatastore.Datastore do
  alias MsbmsSystDatastore.Runtime

  defdelegate child_spec(opts \\ []),
    to: Runtime.Datastore,
    as: :get_datastore_child_spec

  defdelegate start_link(opts \\ []), to: Runtime.Datastore, as: :start_link_datastore
end
