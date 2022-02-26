# Source File: test_helper.exs
# Location:    components/system/msbms_syst_datastore/test/test_helper.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

Mix.shell(Mix.Shell.Process)
Logger.configure(level: :info)
ExUnit.start()
