# Source File: prod.exs
# Location:    application/msbms/config/prod.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

import Config

config :logger,
  compile_time_purge_matching: [
    [level_lower_than: :info]
  ]
