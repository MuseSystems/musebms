# Source File: integration_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_enums/test/integration_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule IntegrationTest do
  use EnumsTestCase, async: false

  @moduletag :integration
  @moduletag :capture_log

  # TODO: Write some real integration tests.  Currently the unit tests look like
  #       our integration tests.  This is all historical since MscmpSystEnums
  #       was written very early compared to our standards development.

  test "placeholder" do
    assert true
  end
end
