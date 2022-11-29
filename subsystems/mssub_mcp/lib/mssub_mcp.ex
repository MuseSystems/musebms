# Source File: mssub_mcp.ex
# Location:    musebms/subsystems/mssub_mcp/lib/mssub_mcp.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcp do
  alias MssubMcp.Runtime

  @moduledoc """
  API for the Master Control Program Subsystem.

  """

  require Logger

  @doc """
  Processes the given function in the context of the MCP services & Datastore.

  Returns the return value of the provided function.

  ## Parameters

    * `operation` - a function  which wraps the operations to be executed in
    the MCP service context.

  ## Examples

  Retrieving an Msdata.SystOwners record from the MCP database.

      iex> mcp_operation = fn -> MscmpSystInstance.get_owner_by_name("owner1") end
      iex> {:ok, %Msdata.SystOwners{}} = MssubMcp.process_operation(mcp_operation)
  """
  @spec process_operation((() -> any())) :: any()
  defdelegate process_operation(operation), to: Runtime.Processing
end
