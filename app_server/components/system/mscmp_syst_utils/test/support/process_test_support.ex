# Source File: support/process_test_support.ex
# Location:    musebms/app_server/components/system/mscmp_syst_utils/test/support/process_test_support.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule ProcessTestSupport do
  @moduledoc false

  use Agent
  import ExUnit.Callbacks

  @registry_name MscmpSystUtils.TestRegistry

  # API for test setup

  @type test_process :: %{pid: pid(), name: GenServer.name() | nil}
  @type test_processes :: %{
          local: test_process,
          global: test_process,
          via: test_process,
          unnamed: test_process
        }

  @spec start_test_processes() :: map()
  def start_test_processes() do
    # Start the Registry under supervision
    _registry_pid = start_supervised!({Registry, keys: :unique, name: @registry_name})

    # Start processes under supervision with different registration methods
    unnamed_pid =
      start_supervised!(%{
        id: :test_unnamed,
        start: {Agent, :start_link, [fn -> %{} end]}
      })

    local_pid =
      start_supervised!(%{
        id: :test_local,
        start: {Agent, :start_link, [fn -> %{} end, [name: :test_local_process]]}
      })

    global_pid =
      start_supervised!(%{
        id: :test_global,
        start: {Agent, :start_link, [fn -> %{} end, [name: {:global, :test_global_process}]]}
      })

    via_pid =
      start_supervised!(%{
        id: :test_via,
        start:
          {Agent, :start_link,
           [
             fn -> %{} end,
             [name: {:via, Registry, {@registry_name, {:msutils, :process_testing, :test}}}]
           ]}
      })

    # Return the test process information
    %{
      local: %{
        pid: local_pid,
        name: :test_local_process
      },
      global: %{
        pid: global_pid,
        name: {:global, :test_global_process}
      },
      via: %{
        pid: via_pid,
        name: {:via, Registry, {@registry_name, {:msutils, :process_testing, :test}}}
      },
      unnamed: %{
        pid: unnamed_pid
      }
    }
  end
end
