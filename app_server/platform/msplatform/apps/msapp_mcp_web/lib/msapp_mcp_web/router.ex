# Source File: router.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp_web/lib/msapp_mcp_web/router.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems
defmodule MsappMcpWeb.Router do
  use MsappMcpWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {MsappMcpWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :bootstrap do
    plug(:bootstrap_check)
  end

  pipeline :no_bootstrap do
    plug(:not_bootstrapping_check)
  end

  pipeline :authenticated do
    plug(:authentication_check)
  end

  pipeline :logout do
    plug(:drop_session)
  end

  scope "/", MsappMcpWeb do
    pipe_through([:browser, :bootstrap, :authenticated])
    get("/", PageController, :home)
  end

  scope "/login", MsappMcpWeb do
    pipe_through([:browser, :bootstrap, :authenticated])
    live("/", LoginLive)
  end

  scope "/logout", MsappMcpWeb do
    pipe_through([:browser, :logout])
    live("/", LoginLive)
  end

  scope "/bootstrap", MsappMcpWeb do
    pipe_through([:browser, :no_bootstrap, :authenticated])

    live("/", BootstrapLive)
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
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: MsappMcpWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  defp bootstrap_check(conn, _opts) do
    if MsappMcp.launch_bootstrap?(),
      do: redirect(conn, to: "/bootstrap") |> halt(),
      else: conn
  end

  defp not_bootstrapping_check(conn, _opts) do
    unless MsappMcp.launch_bootstrap?(),
      do: redirect(conn, to: "/") |> halt(),
      else: conn
  end

  defp authentication_check(conn, _opts) do
    conn
    |> put_session("session_name", MssubMcp.generate_session_name())
  end

  defp drop_session(conn, _opts) do
    conn =
      case get_session(conn, "session_name") do
        name when is_binary(name) ->
          MsappMcp.delete_session(name)
          delete_session(conn, "session_name")

        _ ->
          conn
      end

    redirect(conn, to: "/login") |> halt()
  end
end
