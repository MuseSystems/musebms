defmodule TestSupport do
  @moduledoc false

  use Agent
  import ExUnit.Callbacks

  @registry_name MscmpSystUtilsProcess.TestRegistry

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
