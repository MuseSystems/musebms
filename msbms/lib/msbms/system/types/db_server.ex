# Source File: db_server.ex
# Location:    musebms/lib/msbms/system/types/db_server.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems
defmodule Msbms.System.Types.DbServer do
  @type t() :: %__MODULE__{
          server_name: binary(),
          start_server_instances: boolean(),
          instance_production_dbserver: boolean(),
          instance_sandbox_dbserver: boolean(),
          db_host: binary(),
          db_port: integer(),
          db_show_sensitive: boolean(),
          db_log_level:
            :emergency | :alert | :critical | :error | :warning | :notice | :info | :debug,
          db_max_instances: integer(),
          db_default_app_user_pool_size: integer(),
          db_default_api_user_pool_size: integer(),
          db_default_app_admin_pool_size: integer(),
          db_default_api_admin_pool_size: integer(),
          instance_salt: binary(),
          dbadmin_password: binary(),
          dbadmin_pool_size: integer()
        }
  defstruct server_name: nil,
            start_server_instances: nil,
            instance_production_dbserver: nil,
            instance_sandbox_dbserver: nil,
            db_host: nil,
            db_port: nil,
            db_show_sensitive: nil,
            db_log_level: nil,
            db_max_instances: nil,
            db_default_app_user_pool_size: nil,
            db_default_api_user_pool_size: nil,
            db_default_app_admin_pool_size: nil,
            db_default_api_admin_pool_size: nil,
            instance_salt: nil,
            dbadmin_password: nil,
            dbadmin_pool_size: nil
end
