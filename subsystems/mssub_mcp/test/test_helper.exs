# Source File: test_helper.exs
# Location:    musebms/subsystems/mssub_mcp/test/test_helper.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

test_kind =
  if ExUnit.configuration() |> Keyword.get(:include) |> Enum.member?(:integration) do
    ExUnit.configure(seed: 0)
    :integration_testing
  else
    ExUnit.configure(exclude: [:integration])
    :unit_testing
  end

children = [
  {DynamicSupervisor, strategy: :one_for_one, name: MssubMcp.TestingSupervisor}
]

Supervisor.start_link(children, strategy: :one_for_one)

startup_options = MscmpSystOptions.get_options!("test_startup_options.toml")

TestSupport.setup_testing_database(test_kind, startup_options)

DynamicSupervisor.start_child(
  MssubMcp.TestingSupervisor,
  {MssubMcp.Supervisor, startup_options: startup_options}
)

ExUnit.start()

MscmpSystDb.put_datastore_context(TestSupport.get_testing_datastore_context_id())

ExUnit.after_suite(fn _suite_result ->
  TestSupport.cleanup_testing_database(test_kind, startup_options)
end)
