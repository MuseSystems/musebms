defmodule MsappPlatform.Runtime.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @default_startup_options_path "ms_startup_options.toml"
  @mcp_datastore_type "msapp_platform_mssub_mcp"

  @impl true
  def start(_type, _args) do
    migrations_root_dir = Path.join([:code.priv_dir(:msapp_platform), "database"])

    startup_options_config =
      Application.get_env(:msapp_platform, MsappPlatform.StartupOptions,
        path: @default_startup_options_path
      )

    startup_options = MscmpSystOptions.get_options!(startup_options_config[:path])

    :ok = setup_rate_limiter()

    children = [
      # Start the Telemetry supervisor
      MsappPlatformWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MsappPlatform.PubSub},
      # Start Finch
      {Finch, name: MsappPlatform.Finch},
      # Start the Endpoint (http/https)
      MsappPlatformWeb.Endpoint,
      {MssubMcp.Updater,
       [
         startup_options: startup_options,
         migrations_root_dir: migrations_root_dir,
         datastore_type: @mcp_datastore_type
       ]},
      {MssubMcp.Supervisor, startup_options: startup_options}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MsappPlatform.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MsappPlatformWeb.Endpoint.config_change(changed, removed)
    :ok
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
