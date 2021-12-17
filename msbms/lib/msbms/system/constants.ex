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
    db_appusr: "msbms_##dbident##_appusr",
    db_appadm: "msbms_##dbident##_appadm",
    db_apiusr: "msbms_##dbident##_apiusr",
    db_apiadm: "msbms_##dbident##_apiadm",
    salt_min_bytes: 32,
    dba_pass_min_bytes: 32,
    dbident_salt: "FW4eTLAjwWAuqEni3R55ihR5CxHjqh7ZSm41Ns94",
    global_server_salt: "tt3YI/sTKBFjYO4gpO8cKRAbVx0="
  ]

  @spec get(
          :db_apiadm
          | :db_apiusr
          | :db_appadm
          | :db_appusr
          | :db_name
          | :db_owner
          | :dba_pass_min_bytes
          | :dbident_salt
          | :global_db_login
          | :global_server_salt
          | :salt_min_bytes
          | :startup_options_path
        ) :: binary() | integer()

  for {const, value} <- constants do
    def get(unquote(const)), do: unquote(value)
  end
end
