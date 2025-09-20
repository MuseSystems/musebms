# Source File: test_support.ex
# Location:    musebms/app_server/components/system/mscmp_syst_limiter/test/support/test_support.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule TestSupport do
  @moduledoc false

  #######################
  #
  # Testing Support
  #
  # This module provides functions used to create, migrate, and clean up the
  # testing database for the individual tests in the suite that require the
  # database.
  #
  ########################

  use MscmpSystLimiter.Macros

  limiter_devsupport(:test)

  @spec get_limiter_service_name() :: atom()
  def get_limiter_service_name, do: @limiter_service_name
end
