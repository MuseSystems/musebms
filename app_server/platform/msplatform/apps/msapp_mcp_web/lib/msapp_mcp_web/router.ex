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
    live("/", AuthEmailPasswordLive)
  end

  scope "/logout", MsappMcpWeb do
    pipe_through([:browser, :logout])
    get("/", PageController, :home)
  end

  scope "/bootstrap", MsappMcpWeb do
    pipe_through([:browser, :no_bootstrap])

    live("/", BootstrapLive)
  end

  scope "/password-reset", MsappMcpWeb do
    pipe_through([:browser, :bootstrap, :authenticated])
    live("/", AuthPasswordResetLive)
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
      pipe_through([:browser, :bootstrap, :authenticated])

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
    if MsappMcp.launch_bootstrap?(),
      do: conn,
      else: redirect(conn, to: "/") |> halt()
  end

  defp authentication_check(conn, _opts) do
    authentication_action =
      conn
      |> get_session(:session_name)
      |> MsappMcp.test_session_authentication()

    case authentication_action do
      :session_valid ->
        if conn.request_path == "/login" do
          conn |> redirect(to: "/") |> halt()
        else
          conn
        end

      :session_invalid ->
        if conn.request_path == "/login" do
          conn
          |> put_session(:session_name, MsappMcp.generate_session_name())
        else
          conn
          |> put_session(:original_request_path, conn.request_path)
          |> redirect(to: "/login")
          |> halt()
        end

      {:session_reset, reset_reason} ->
        if conn.request_path == "/password-reset" do
          conn
        else
          conn
          |> put_session(:original_request_path, conn.request_path)
          |> put_session(:authenticator_reset_reason, reset_reason)
          |> redirect(to: "/password-reset")
          |> halt()
        end
    end
  end

  defp drop_session(conn, _opts) do
    conn =
      case get_session(conn, "session_name") do
        name when is_binary(name) ->
          :ok = MsappMcp.delete_session(name)

          conn
          |> delete_session("session_name")
          |> delete_session("authenticator_reset_reason")

        _ ->
          conn
      end

    redirect(conn, to: "/login") |> halt()
  end
end
