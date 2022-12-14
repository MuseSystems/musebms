# Source File: updater.ex
# Location:    musebms/subsystems/mssub_mcp/lib/updater.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcp.Updater do
  alias MssubMcp.Runtime

  @moduledoc """
  Provides an API for bootstrapping and migration application for the MCP
  subsystem.
  """

  use MssubMcp.Macros

  mcp_constants()

  @spec start_link(Keyword.t()) :: :ignore | {:error, MscmpSystError.t() | any()}
  defdelegate start_link(opts), to: Runtime.Datastore

  # TODO: should restart really be :temporary?
  @spec child_spec(Keyword.t()) :: Supervisor.child_spec()
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :transient
    }
  end
end
