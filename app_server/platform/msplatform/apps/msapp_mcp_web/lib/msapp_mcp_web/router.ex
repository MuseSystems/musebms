defmodule MsappMcpWeb.Router do
  use MsappMcpWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MsappMcpWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :bootstrap do
    plug :bootstrap_check
  end

  scope "/", MsappMcpWeb do
    pipe_through [:browser, :bootstrap]

    get "/", PageController, :home
  end

  scope "/bootstrap", MsappMcpWeb do
    pipe_through :browser

    get "/", BootstrapController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", MsappMcpWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:msapp_mcp_web, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MsappMcpWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  defp bootstrap_check(conn, _opts) do
    if MsappMcp.launch_bootstrap?(),
      do: redirect(conn, to: "/bootstrap") |> halt(),
      else: conn
  end
end
