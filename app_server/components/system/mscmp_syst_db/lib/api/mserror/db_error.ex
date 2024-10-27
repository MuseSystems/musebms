# Source File: db_error.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/api/mserror/db_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mserror.DbError do
  @moduledoc """
  Defines errors and related metadata for MscmpSystDb component errors.
  """

  use MscmpSystError,
    kinds: [
      datastore: "Failure operating on a Datastore.",
      datastore_context: "Failure operating on a Datastore Context.",
      dba: "Failure operating on a Database.",
      privileged: "Failure operating on a Database with elevated permissions.",
      migrations: "Failure operating on a Database schema via migrations.",
      migration_build: "Failure working with migration files."
    ],
    component: MscmpSystDb
end
