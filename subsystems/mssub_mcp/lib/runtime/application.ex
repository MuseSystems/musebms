defmodule MssubMcp.Application do
  use Application

  @supervisor_name MssubMcp.Supervisor
  @datastore_supervisor_name MssubMcp.DatastoreSupervisor

  @impl true
  @spec start(Application.start_type(), term()) ::
          {:ok, pid()} | {:ok, pid(), Application.state()} | {:error, term()}
  def start(_type, args) do
    opts = MscmpSystUtils.resolve_options(args[:opts], datastore_name: @datastore_supervisor_name)

    mcp_service_childredn = [
      MssubMcp.Runtime.Datastore.child_spec(opts)
    ]

    Supervisor.start_link(mcp_service_childredn, strategy: :one_for_one, name: @supervisor_name)
  end
end
