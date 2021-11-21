# Source File: constants.ex
# Location:    musebms/lib/msbms/system/constants.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule Msbms.System.Constants do
  constants = [
    startup_options_path: Path.join(["msbms_startup_options.toml"]),
    global_db_name: :msbms_global,
    global_db_login: "msbms_syst_dba",
    db_owner: "msbms_##dbindent##_owner",
    db_app_user: "msbms_##dbindent##_app_user",
    db_app_admin: "msbms_##dbindent##_app_admin",
    db_api_user: "msbms_##dbindent##_api_user",
    db_api_admin: "msbms_##dbindent##_api_admin",
    salt_min_bytes: 32,
    dba_pass_min_bytes: 32
  ]

  for {const, value} <- constants do
    def get(unquote(const)), do: unquote(value)
  end
end
