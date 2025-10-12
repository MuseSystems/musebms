# Source File: state.ex
# Location:    musebms/app_server/components/system/mscmp_syst_interaction/lib/api/types/state.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInteraction.Types.State do
  @moduledoc """
  Defines the "Interaction State" which is held by the "State" GenServer.

  The Interaction State held for all users of a given Interaction Context is
  typically constituted of the Original Data and the identity of the currently
  owning/editing process.
  """

  alias MscmpSystInteraction.Types

  @typedoc """
  The typing information defining the `MscmpSystInteraction.Types.State` struct.

  ## Attributes

    * `change_agent` - the identity of the process which is currently entitled
    to perform data updates.  If no process holds this status, this value will
    be `nil`.

    * `mode` - the current mode of the data being represented by the Interaction
    State GenServer instance.

    * `orig_data` - this is the data which is considered "Original Data",
    meaning the state of the data prior to any changes.  Original Data is often
    derived from the existing database state or the defaults used for new
    records. This kind of data is used when the user wishes to discard their
    changes in a user interface or in validating that certain changes are valid
    given the original state of the data.  Users only wishing to read the data
    can be given the Original Data value as it should always represent the
    prevailing state of any records being represented.
  """

  @type t() :: %__MODULE__{
          context_name: Types.context_name(),
          state_mode: Types.state_modes(),
          base_id: Ecto.UUID.t(),
          change_agent_name: String.t() | nil,
          change_agent_id: Ecto.UUID.t() | nil,
          change_agent_pid: pid() | nil,
          original_data: struct() | nil
        }

  defstruct [
    :context_name,
    :state_mode,
    :base_id,
    :change_agent_name,
    :change_agent_id,
    :change_agent_pid,
    :original_data
  ]
end
