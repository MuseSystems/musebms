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
    global_db_login: "msbms_syst_dba",
    db_name: "msbms_##dbtype##_##dbident##",
    db_owner: "msbms_##dbident##_owner",
    db_app_user: "msbms_##dbident##_appusr",
    db_app_admin: "msbms_##dbident##_appadm",
    db_api_user: "msbms_##dbident##_apiusr",
    db_api_admin: "msbms_##dbident##_apiadm",
    salt_min_bytes: 32,
    dba_pass_min_bytes: 32
  ]

  for {const, value} <- constants do
    def get(unquote(const)), do: unquote(value)
  end
end
