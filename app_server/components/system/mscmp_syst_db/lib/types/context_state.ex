# Source File: context_state.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/types/context_state.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.Types.ContextState do
  @moduledoc """
  A struct for reporting the runtime state of Datastore Contexts.
  """

  @enforce_keys [:context, :state]
  defstruct [:context, :state]

  @typedoc """
  A struct for reporting the runtime state of Datastore Contexts.

  ## Attributes

    * `:context` - identifies the name of the Datastore Context for which
    runtime state is being reported.

    * `:state` - indicates the current runtime state of the named Datastore
    Context.  See `t:MscmpSystDb.Types.context_state_values/0` for more.
  """

  @type t :: %__MODULE__{
          context: MscmpSystDb.Types.context_name(),
          state: MscmpSystDb.Types.context_state_values()
        }
end
