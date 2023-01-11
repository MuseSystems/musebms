# Source File: application.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/msapp_mcp/application.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsappMcp.Runtime.Application do
  use Application

  @default_startup_options_path "ms_startup_options.toml"
  @mcp_datastore_type "msplatform_mssub_mcp"

  @moduledoc false

  @impl true
  def start(_type, _args) do
    migrations_root_dir = Path.join([:code.priv_dir(:msapp_mcp), "database"])

    startup_options_config =
      Application.get_env(:msapp_mcp, Msplatform.StartupOptions,
        path: @default_startup_options_path
      )

    startup_options = MscmpSystOptions.get_options!(startup_options_config[:path])

    :ok = setup_rate_limiter()

    children = [
      {Phoenix.PubSub, name: MsappMcp.PubSub},
      {Finch, name: MsappMcp.Finch},
      {MssubMcp.Updater,
       [
         startup_options: startup_options,
         migrations_root_dir: migrations_root_dir,
         datastore_type: @mcp_datastore_type
       ]},
      {MssubMcp.Supervisor, startup_options: startup_options}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: MsappMcp.Supervisor)
  end

  defp setup_rate_limiter do
    with :stopped <- :mnesia.stop(),
         :ok <- maybe_create_mnesia_schema() do
      :mnesia.start()
    else
      error ->
        raise MscmpSystError,
          code: :undefined_error,
          message: "Unable to setup Mnesia for MscmpSystLimiter.",
          cause: error
    end
  end

  defp maybe_create_mnesia_schema do
    case :mnesia.create_schema([node()]) do
      {:error, {_node, {:already_exists, _node_again}}} -> :ok
      :ok -> :ok
    end
  end
end
