defmodule MssubMcp.Application do
  use Application

  @supervisor_name MssubMcp.Supervisor
  @datastore_supervisor_name MssubMcp.DatastoreSupervisor

  @impl true
  @spec start(Application.start_type(), term()) ::
          {:ok, pid()} | {:ok, pid(), Application.state()} | {:error, term()}
  def start(_type, args) do
    opts = MscmpSystUtils.resolve_options(args[:opts], datastore_name: @datastore_supervisor_name)

    setup_rate_limiter()

    enum_service_spec = %{
      id: MssubMcpEnumsService,
      start: {MscmpSystEnums, :start_link, [{:mssub_mcp_enums_service, :mssub_mcp_app_access}]}
    }

    settings_service_spec = %{
      id: MssubMcpSettingsService,
      start:
        {MscmpSystSettings, :start_link, [{:mssub_mcp_settings_service, :mssub_mcp_app_access}]}
    }

    mcp_service_childredn = [
      MssubMcp.Runtime.Datastore.child_spec(opts),
      enum_service_spec,
      settings_service_spec
    ]

    Supervisor.start_link(mcp_service_childredn, strategy: :one_for_one, name: @supervisor_name)
  end

  defp setup_rate_limiter() do
    :mnesia.stop()
    :mnesia.create_schema([node()])
    :mnesia.start()

    MscmpSystLimiter.init_rate_limiter()
  end
end
