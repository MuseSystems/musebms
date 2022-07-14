# Source File: config.exs
# Location:    application/msbms/config/config.exs
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

config :msbms_syst_datastore,
  ecto_repos: [MsbmsSystDatastore.Runtime.Datastore]

import_config "#{Mix.env()}.exs"
