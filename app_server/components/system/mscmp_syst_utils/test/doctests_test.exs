# Source File: doctests_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_utils/test/doctests_test.exs
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
  @moduledoc false

  # While we're testing more than just the process doctests here, there are no
  # specialized test cases for the other modules.  This could change in the
  # future, but for now it's adequate and the non-process test cases won't be
  # affected.

  use ProcessTestCase, async: true

  import Msutils.Guards

  @moduletag :doctest
  @moduletag :capture_log

  doctest Msutils.String
  doctest Msutils.Guards
  doctest Msutils.Process
end
