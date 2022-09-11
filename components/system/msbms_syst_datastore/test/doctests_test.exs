# Source File: doctests_test.exs
# Location:    musebms/components/system/msbms_syst_datastore/test/doctests_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule DoctestsTest do
  use ExUnit.Case, async: true

  doctest MsbmsSystDatastore.DbTypes.Range
  doctest MsbmsSystDatastore.Types
end
