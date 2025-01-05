# Source File: impl/guards_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_utils/test/impl/guards_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule GuardsTest do
  @moduledoc false

  use ExUnit.Case, async: true

  @moduletag :unit
  @moduletag :capture_log

  # Guards aren't unit tested.  Guards are doctested and tested via the
  # integration tests since there is no separation between API and
  # implementation.

  test "Guards aren't unit tested." do
    assert true
  end
end
