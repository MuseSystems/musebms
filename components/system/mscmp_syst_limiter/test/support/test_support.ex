# Source File: test_support.ex
# Location:    musebms/components/system/mscmp_syst_limiter/test/support/test_support.ex
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

  @mnesia_database_location Path.join([".mnesia"])

  #######################
  #
  # Testing Support
  #
  # This module provides functions used to create, migrate, and clean up the
  # testing database for the individual tests in the suite that require the
  # database.
  #
  ########################

  def setup_testing_database(:integration_testing) do
    File.mkdir_p!(@mnesia_database_location)
    Application.put_env(:mnesia, :dir, @mnesia_database_location)

    :mnesia.stop()
    :mnesia.create_schema([node()])
    :mnesia.start()
  end

  def setup_testing_database(:unit_testing), do: MscmpSystLimiter.init_rate_limiter()

  def cleanup_testing_database(:integration_testing) do
    File.rm_rf!(@mnesia_database_location)
  end

  def cleanup_testing_database(_), do: nil
end
