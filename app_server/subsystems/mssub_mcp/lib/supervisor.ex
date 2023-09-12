# Source File: supervisor.ex
# Location:    musebms/subsystems/mssub_mcp/lib/supervisor.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcp.Supervisor do
  @moduledoc false

  use Supervisor

  alias MssubMcp.Runtime

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  defdelegate init(init_arg), to: Runtime.Services
end
