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

  @spec create_session(SessionTypes.session_data(), non_neg_integer()) ::
          {:ok, SessionTypes.session_name()} | {:error, MscmpSystError.t()}
  mcp_opfn create_session(session_data, expires_after_secs) do
    MscmpSystSession.create_session(session_data, expires_after_secs)
  end

  @spec get_session(SessionTypes.session_name(), non_neg_integer()) ::
          {:ok, SessionTypes.session_data()} | {:ok, :not_found} | {:error, MscmpSystError.t()}
  mcp_opfn get_session(session_name, expires_after_secs) do
    MscmpSystSession.get_session(session_name, expires_after_secs)
  end

  @spec refresh_session_expiration(SessionTypes.session_name(), non_neg_integer()) ::
          :ok | {:ok, :not_found} | {:error, MscmpSystError.t()}
  mcp_opfn refresh_session_expiration(session_name, expires_after_secs) do
    MscmpSystSession.refresh_session_expiration(session_name, expires_after_secs)
  end

  @spec update_session(
          SessionTypes.session_name(),
          SessionTypes.session_data(),
          non_neg_integer()
        ) :: :ok | {:ok, :not_found} | {:error, MscmpSystError.t()}
  mcp_opfn update_session(session_name, session_data, expires_after_secs) do
    MscmpSystSession.update_session(session_name, session_data, expires_after_secs)
  end

  @spec delete_session(SessionTypes.session_name()) ::
          :ok | {:ok, :not_found} | {:error, MscmpSystError.t()}
  mcp_opfn delete_session(session_name) do
    MscmpSystSession.delete_session(session_name)
  end

  @spec purge_expired_sessions() :: :ok | {:error, MscmpSystError.t()}
  mcp_opfn purge_expired_sessions do
    MscmpSystSession.purge_expired_sessions()
  end
end
