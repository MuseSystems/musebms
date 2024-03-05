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

  defstruct [
    :change_agent,
    :mode,
    :orig_data
  ]

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
          change_agent: pid(),
          mode: Types.state_modes(),
          orig_data: struct()
        }
end
