# Source File: test_helper.exs
# Location:    components/system/msbms_syst_instance_mgr/test/test_helper.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

#  This testing presumes that the database schema is tested separately and is
#  for module testing purposes.

test_kind =
  if ExUnit.configuration() |> Keyword.get(:include) |> Enum.member?(:integration) do
    ExUnit.configure(seed: 0)
    :integration_testing
  else
    ExUnit.configure(exclude: [:integration])
    :unit_testing
  end

TestSupport.setup_testing_database(test_kind)

MsbmsSystDatastore.set_datastore_context(TestSupport.get_testing_datastore_context_id())

children = [
  {DynamicSupervisor, strategy: :one_for_one, name: MsbmsSystInstanceMgr.TestingSupervisor}
]

Supervisor.start_link(children, strategy: :one_for_one)
Logger.configure(level: :info)

ExUnit.start()

enum_service_spec = %{
  id: MsbmsSystInstanceMgrTestingEnumService,
  start: {
    MsbmsSystEnums,
    :start_link,
    [{:instance_mgr, TestSupport.get_testing_datastore_context_id()}]
  }
}

DynamicSupervisor.start_child(MsbmsSystInstanceMgr.TestingSupervisor, enum_service_spec)

ExUnit.after_suite(fn _suite_result ->
  TestSupport.cleanup_testing_database(test_kind)
end)
