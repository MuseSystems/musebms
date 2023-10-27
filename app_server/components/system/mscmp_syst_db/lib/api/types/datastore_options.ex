# Source File: datastore_options.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/api/types/datastore_options.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.Types.DatastoreOptions do
  @moduledoc """
  A struct defining the connection parameters to use to connect to a Datastore
  backing database.
  """

  @enforce_keys [:database_name, :contexts, :db_server]
  defstruct [:database_name, :datastore_code, :datastore_name, :contexts, :db_server]

  @typedoc """
  A struct defining the connection parameters to use to connect to a Datastore
  backing database.

  ## Attributes

    * `:database_name` - The name of the database in the database server to
      which the connection will be made.  Often times this value will be the
      same as the String.t() form of the `:datastore_name` value.

    * `:datastore_code` - Defines a Datastore specific salting value for use in
      certain security and cryptographic related functions.

    * `:datastore_name` - A name for use by the application to identify a given
      Datastore.  This value will often time be the same as the `:database_name`
      value, except as an atom() rather than a String.t().

    * `:contexts` - A list of available Datastore Context values defining which
      contexts are available for this Datastore.  See
      `t:MscmpSystDb.Types.DatastoreContext.t/0` for more information concerning
      the values of each entry in the list.

    * `:db_server` - The database server information for the server where the
      Datastore database resides.  See 't:MscmpSystDb.Types.DbServer.t/0' for
      additional details.
  """

  @type t :: %__MODULE__{
          database_name: String.t(),
          datastore_code: String.t() | nil,
          datastore_name: atom() | nil,
          contexts: [MscmpSystDb.Types.DatastoreContext.t()] | [],
          db_server: MscmpSystDb.Types.DbServer.t()
        }
end
