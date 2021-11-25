# Source File: instance_config.ex
# Location:    musebms/lib/msbms/system/types/instance_config.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule Msbms.System.Types.InstanceConfig do
  @type t() :: %__MODULE__{
          id: binary(),
          instance_name: binary(),
          instance_display_name: binary(),
          instance_type_id: binary(),
          instance_is_production: boolean(),
          instance_state_id: binary(),
          instance_state_functional_type:
            :uninitialized | :initializing | :active | :suspended | :inactive | :purge_eligible,
          instance_dbserver: binary(),
          db_app_user_pool: integer(),
          db_app_admin_pool: integer(),
          db_api_user_pool: integer(),
          db_api_admin_pool: integer(),
          instance_salt: binary()
        }
  defstruct id: nil,
            instance_name: nil,
            instance_display_name: nil,
            instance_type_id: nil,
            instance_is_production: nil,
            instance_state_id: nil,
            instance_state_functional_type: nil,
            instance_dbserver: nil,
            db_app_user_pool: nil,
            db_app_admin_pool: nil,
            db_api_user_pool: nil,
            db_api_admin_pool: nil,
            instance_salt: nil
end
