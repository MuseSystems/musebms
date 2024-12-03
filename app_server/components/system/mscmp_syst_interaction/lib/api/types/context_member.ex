# Source File: context_member.ex
# Location:    musebms/app_server/components/system/mscmp_syst_interaction/lib/api/types/context_member.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInteraction.Types.ContextMember do
  @moduledoc """
  """

  @typedoc """
  """
  @type t() :: %__MODULE__{
          specific_perm: String.t(),
          categorical_perm: String.t()
        }

  defstruct [:specific_perm, :categorical_perm]
end
