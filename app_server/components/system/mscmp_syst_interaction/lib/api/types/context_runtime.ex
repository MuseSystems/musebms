# Source File: context_runtime.ex
# Location:    musebms/app_server/components/system/mscmp_syst_interaction/lib/api/types/context_runtime.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInteraction.Types.ContextRuntime do
  @moduledoc """
  """

  alias MscmpSystInteraction.Types

  @typedoc """
  """
  @type t() :: %__MODULE__{
          context_name: Types.context_name(),
          change_mode: Types.change_modes(),
          batch_agent: pid() | nil,
          batch_agent_id: Ecto.UUID.t() | nil,
          batch_agent_display_name: String.t() | nil
        }

  defstruct [
    :context_name,
    :change_mode,
    :batch_agent,
    :batch_agent_id,
    :batch_agent_display_name
  ]
end
