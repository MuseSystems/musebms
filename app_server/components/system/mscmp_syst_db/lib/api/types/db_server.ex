# Source File: db_server.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/api/types/db_server.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.Types.DbServer do
  @moduledoc """
  Provides the definition of a database server which can back application
  instances.

  The data in the struct includes fields which uniquely identifies the server,
  provides information for where on the network the server can be found, and
  connection related parameters.  Also, the full administrative credentials are
  included.
  """

  defstruct [
    :server_name,
    :start_server_instances,
    :server_pools,
    :db_host,
    :db_port,
    :db_show_sensitive,
    :db_max_instances,
    :server_salt,
    :dbadmin_password,
    :dbadmin_pool_size
  ]

  @typedoc """
  Provides the definition of a database server which can back application
  instances.

  ## Attributes

    * `:server_name` - Provides a unique identifier for a database server
    instance.

    * `:start_server_instances` - If true, indicates that databases on the
    server can be started and made available as application Datastores.

    * `:server_pools` - The server pools in which the database server
    participates.

    * `:db_host` - The hostname or IP address of the database server on the
    network.

    * `:db_port` - The TCP port on which the database server is listening for
    connections.

    * `:db_show_sensitive` - If true, various logging events may show unredacted
    "sensitive" database connectivity information.  Note that even when false,
    the application still log sensitive application data.


    * `:db_max_instances` - The total number of databases allowed to be
    established for the db_server instance.

    * `:server_salt` - For certain cryptographic operations, such as password
    derivation, allows for the assignment of specific salting value for that is
    specific to a given database server.  This value must be at least 32 bytes
    long and should be a random string.

    * `:dbadmin_password` - The ms_syst_privileged role password for privileged
    operations such as creating a new database/Datastore or new database roles
    on the database server instance.

    * `:dbadmin_pool_size` - The pool size to use for creating connections for
    privileged operations using the ms_syst_privileged role.

  See `MscmpSystDb.Types.DbServer` for more.
  """

  @type t :: %__MODULE__{
          server_name: String.t() | nil,
          start_server_instances: boolean() | nil,
          server_pools: list(String.t()) | [] | nil,
          db_host: String.t() | nil,
          db_port: integer() | nil,
          db_show_sensitive: boolean() | nil,
          db_max_instances: integer() | nil,
          server_salt: String.t() | nil,
          dbadmin_password: String.t() | nil,
          dbadmin_pool_size: integer() | nil
        }
end
