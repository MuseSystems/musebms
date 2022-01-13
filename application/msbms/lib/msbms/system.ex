
# Source File: core.ex
# Location:    musebms/lib/msbms/system.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule Msbms.System do
  # defdelegate start_system, to: Msbms.System.Actions.start_system
  # defdelegate start_global, to:
  # defdelegate get_global_state, to:
  # defdelegate update_global, to:
  # defdelegate stop_global, to:

  # defdelegate start_instance, to:
  # defdelegate get_instance_state, to:
  # defdelegate update_instance, to:
  # defdelegate stop_instance, to:
  defdelegate get_const(param), to: Msbms.System.Constants, as: :get
end
