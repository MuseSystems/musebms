# Source File: db_session_manager.ex
# Location:    musebms/app_server/subsystems/mssub_mcp/lib/runtime/db_session_manager.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcp.Runtime.DbSessionManager do
  alias MscmpSystSession.Types, as: SessionTypes

  @moduledoc false

  use MssubMcp.Macros

  mcp_constants()

  @spec create_session(map(), Keyword.t()) ::
          {:ok, SessionTypes.session_name()} | {:error, MscmpSystError.t()}
  mcp_opfn create_session(session_data, opts) do
    opts =
      if opts[:expires_after] == nil do
        expires_after =
          MscmpSystSettings.get_setting_value("mssub_mcp_session_expiration", :setting_integer)

        MscmpSystUtils.resolve_options(opts, expires_after: expires_after)
      else
        opts
      end

    MscmpSystSession.create_session(session_data, opts)
  end

  @spec get_session(SessionTypes.session_name(), Keyword.t()) ::
          {:ok, SessionTypes.session_data()} | {:ok, :not_found} | {:error, MscmpSystError.t()}
  mcp_opfn get_session(session_name, opts) do
    opts =
      if opts[:expires_after] == nil do
        expires_after =
          MscmpSystSettings.get_setting_value("mssub_mcp_session_expiration", :setting_integer)

        MscmpSystUtils.resolve_options(opts, expires_after: expires_after)
      else
        opts
      end

    MscmpSystSession.get_session(session_name, opts)
  end

  @spec refresh_session_expiration(SessionTypes.session_name(), Keyword.t()) ::
          :ok | {:ok, :not_found} | {:error, MscmpSystError.t()}
  mcp_opfn refresh_session_expiration(session_name, opts) do
    opts =
      if opts[:expires_after] == nil do
        expires_after =
          MscmpSystSettings.get_setting_value("mssub_mcp_session_expiration", :setting_integer)

        MscmpSystUtils.resolve_options(opts, expires_after: expires_after)
      else
        opts
      end

    MscmpSystSession.refresh_session_expiration(session_name, opts)
  end

  @spec update_session(SessionTypes.session_name(), SessionTypes.session_data(), Keyword.t()) ::
          :ok | {:ok, :not_found} | {:error, MscmpSystError.t()}
  mcp_opfn update_session(session_name, session_data, opts) do
    opts =
      if opts[:expires_after] == nil do
        expires_after =
          MscmpSystSettings.get_setting_value("mssub_mcp_session_expiration", :setting_integer)

        MscmpSystUtils.resolve_options(opts, expires_after: expires_after)
      else
        opts
      end

    MscmpSystSession.update_session(session_name, session_data, opts)
  end

  @spec delete_session(SessionTypes.session_name()) ::
          :ok | {:ok, :not_found} | {:error, MscmpSystError.t()}
  mcp_opfn delete_session(session_name) do
    MscmpSystSession.delete_session(session_name)
  end

  @spec purge_expired_sessions(Keyword.t()) :: :ok | {:error, MscmpSystError.t()}
  mcp_opfn purge_expired_sessions(opts) do
    MscmpSystSession.purge_expired_sessions(opts)
  end
end
