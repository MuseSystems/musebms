# Source File: test_helper.exs
# Location:    musebms/app_server/components/application/mscmp_core_hierarchy/test/test_helper.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

TestSupport.setup_testing_database()

MscmpSystDb.put_datastore_context(TestSupport.get_testing_datastore_context_id())

children = [
  {DynamicSupervisor, strategy: :one_for_one, name: MscmpCoreHierarchy.TestingSupervisor}
]

Supervisor.start_link(children, strategy: :one_for_one)

enum_service_spec = %{
  id: MscmpCoreHierarchyTestingEnumService,
  start: {
    MscmpSystEnums,
    :start_link,
    [{:hierarchy, TestSupport.get_testing_datastore_context_id()}]
  }
}

Logger.configure(level: :info)

ExUnit.start()

DynamicSupervisor.start_child(MscmpCoreHierarchy.TestingSupervisor, enum_service_spec)

ExUnit.after_suite(fn _suite_result ->
  TestSupport.cleanup_testing_database()
end)
