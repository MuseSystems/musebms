# Source File: options.ex
# Location:    musebms/subsystems/mssub_mcp/lib/runtime/options.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcp.Runtime.Options do
  @moduledoc false

  use MssubMcp.Macros

  require Logger

  mcp_constants()

  # The below is used as a salting value for MCP Context password generation.
  # The overall approach, including this value, is almost certainly a bad idea
  # and terribly naive.  Put "magic" in the name to make apparent that something
  # isn't right here.
  @password_magic <<44, 60, 238, 75, 246, 83, 116, 104, 187, 163, 159, 83, 37, 2, 54, 86>>

  @spec get_datastore_options(map(), Keyword.t()) :: MscmpSystDb.Types.DatastoreOptions.t()
  def get_datastore_options(startup_options, opts) do
    db_server = MscmpSystOptions.get_global_dbserver(startup_options)
    database_name = @mcp_db_name
    datastore_code = MscmpSystOptions.get_global_pepper_value(startup_options)
    contexts = get_datastore_contexts(startup_options, opts)

    %MscmpSystDb.Types.DatastoreOptions{
      database_name: database_name,
      datastore_code: datastore_code,
      datastore_name: :mssub_mcp,
      contexts: contexts,
      db_server: db_server
    }
  end

  @spec get_datastore_contexts(map(), Keyword.t()) :: [MscmpSystDb.Types.DatastoreContext.t()]
  def get_datastore_contexts(%{} = startup_options, opts) do
    opts =
      MscmpSystUtils.resolve_options(opts,
        owner_name: @mcp_db_owner_role,
        app_access_role_name: @mcp_db_app_access_role
      )

    [
      %MscmpSystDb.Types.DatastoreContext{
        context_name: nil,
        description: "Muse Systems MCP Subsystem Database Owner",
        database_role: opts[:owner_name],
        database_password: nil,
        starting_pool_size: 0,
        start_context: false,
        login_context: false,
        database_owner_context: true
      },
      %MscmpSystDb.Types.DatastoreContext{
        context_name: @mcp_db_app_access_context,
        description: "Muse Systems MCP Subsystem Application Access",
        database_role: opts[:app_access_role_name],
        database_password:
          get_context_password([
            @password_magic,
            MscmpSystOptions.get_global_db_password(startup_options),
            opts[:app_access_role_name],
            MscmpSystOptions.get_global_pepper_value(startup_options)
          ]),
        starting_pool_size: MscmpSystOptions.get_global_db_pool_size(startup_options),
        start_context: true,
        login_context: true
      }
    ]
  end

  defp get_context_password(password_list) do
    Enum.reduce(password_list, "", &(&2 <> &1))
    |> then(&:crypto.hash(:blake2b, &1))
    |> Base.encode64(padding: false)
  end
end
