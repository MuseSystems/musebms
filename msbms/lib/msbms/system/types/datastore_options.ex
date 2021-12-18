# Source File: datastore_options.ex
# Location:    musebms/lib/msbms/system/types/datastore_options.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule Msbms.System.Types.DatastoreOptions do
  @type t() :: %__MODULE__{
          database_name: binary(),
          database_owner: binary(),
          instance_code: binary(),
          instance_name: binary(),
          contexts: [Keyword.t()],
          dbserver: Msbms.System.Types.DbServer.t()
        }
  defstruct database_name: nil,
            database_owner: nil,
            instance_code: nil,
            instance_name: nil,
            contexts: nil,
            dbserver: nil
end
