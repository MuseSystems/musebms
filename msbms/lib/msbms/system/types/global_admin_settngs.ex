# Source File: global_admin_settngs.ex
# Location:    musebms/lib/msbms/system/types/global_admin_settngs.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems
defmodule Msbms.System.Types.GlobalAdminSettings do
  @type t() :: %__MODULE__{
          dbadmin_password: binary(),
          dbadmin_pool_size: integer(),
          global_dbserver_name: binary()
        }
  defstruct dbadmin_password: nil,
            dbadmin_pool_size: nil,
            global_dbserver_name: nil
end
