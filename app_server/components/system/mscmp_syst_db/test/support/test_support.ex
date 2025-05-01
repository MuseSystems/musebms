# Source File: test_support.ex
# Location:    musebms/components/system/mscmp_syst_db/test/support/test_support.ex
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

  @spec get_test_migrations_root_dir() :: String.t()
  def get_test_migrations_root_dir, do: "priv/database/migration_test"

  @spec cleanup_test_migrations() :: :ok
  def cleanup_test_migrations do
    File.rm_rf!(get_test_migrations_root_dir())
    :ok
  end
end
