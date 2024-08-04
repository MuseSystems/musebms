# Source File: macros.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/impl/macros.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.Impl.Macros do
  @moduledoc false

  defmacro migration_constants do
    quote do
      @migrations_schema "ms_syst_db"
      @migrations_table "migrations"
      @migrations_root_dir "priv/database"
    end
  end
end
