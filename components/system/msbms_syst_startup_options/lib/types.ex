# Source File: types.ex
# Location:    components/system/msbms_syst_startup_options/lib/types.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystStartupOptions.Types do

  @type server_log_levels :: :emergency | :alert | :critical | :error | :warning | :notice | :info | :debug

  @type dbserver :: %{
          server_name:                   String.t(),
          start_server_instances:        boolean(),
          instance_production_dbserver:  boolean(),
          instance_sandbox_dbserver:     boolean(),
          db_host:                       String.t(),
          db_port:                       integer(),
          db_show_sensitive:             boolean(),
          db_log_level:                  server_log_levels(),
          db_max_instances:              integer(),
          db_default_app_user_pool_size: integer(),
          db_default_api_user_pool_size: integer(),
          server_salt:                   binary(),
          dbadmin_password:              String.t(),
          dbadmin_pool_size:             integer()
        }

  @doc """
  Returns a map reflecting the data structure of the dbserver() type suitable for use in with the
  Ecto.Changeset module.

  ## Examples

      iex> MsbmsSystStartupOptions.Types.dbserver_changeset_types()
      %{
        server_name:                   :string,
        start_server_instances:        :boolean,
        instance_production_dbserver:  :boolean,
        instance_sandbox_dbserver:     :boolean,
        db_host:                       :string,
        db_port:                       :integer,
        db_show_sensitive:             :boolean,
        db_log_level:                  :string,
        db_max_instances:              :integer,
        db_default_app_user_pool_size: :integer,
        db_default_api_user_pool_size: :integer,
        server_salt:                   :string,
        dbadmin_password:              :string,
        dbadmin_pool_size:             :integer
      }
  """
  @spec dbserver_changeset_types :: map()
  def dbserver_changeset_types() do
    %{
      server_name:                   :string,
      start_server_instances:        :boolean,
      instance_production_dbserver:  :boolean,
      instance_sandbox_dbserver:     :boolean,
      db_host:                       :string,
      db_port:                       :integer,
      db_show_sensitive:             :boolean,
      db_log_level:                  :string,
      db_max_instances:              :integer,
      db_default_app_user_pool_size: :integer,
      db_default_api_user_pool_size: :integer,
      server_salt:                   :string,
      dbadmin_password:              :string,
      dbadmin_pool_size:             :integer
    }
  end
end
