# Source File: perm_grant_value.ex
# Location:    musebms/app_server/components/system/mscmp_syst_perms/lib/api/types/perm_grant_value.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystPerms.Types.PermGrantValue do
  @moduledoc """
  A data structure describing what Scope is granted for each Right of a
  Permission.
  """

  alias MscmpSystPerms.Types

  defstruct view_scope: :deny, maint_scope: :deny, admin_scope: :deny, ops_scope: :deny

  @typedoc """
  A data structure describing what Scope is granted for each Right of a
  Permission.

  See the conceptual documentation at `MscmpSystPerms` for more about the
  available Rights and Scopes.
  """
  @type t :: %__MODULE__{
          view_scope: Types.rights_scope(),
          maint_scope: Types.rights_scope(),
          admin_scope: Types.rights_scope(),
          ops_scope: Types.rights_scope()
        }
end
