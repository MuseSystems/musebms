# Source File: test_helper.exs
# Location:    musebms/components/system/mscmp_syst_settings/test/test_helper.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

#  This testing presumes that the database schema is tested separately and is
#  correct here.

TestSupport.setup_testing_database()

MscmpSystDb.put_datastore_context(TestSupport.get_testing_datastore_context_id())

settings_service_spec = %{
  id: MscmpSystSettingsTestingService,
  start: {
    MscmpSystSettings,
    :start_link,
    [{:settings_instance, TestSupport.get_testing_datastore_context_id()}]
  }
}

children = [
  {DynamicSupervisor, strategy: :one_for_one, name: MscmpSystSettings.TestingSupervisor}
]

Supervisor.start_link(children, strategy: :one_for_one)
Logger.configure(level: :info)
ExUnit.start()

DynamicSupervisor.start_child(MscmpSystSettings.TestingSupervisor, settings_service_spec)

ExUnit.after_suite(fn _suite_result ->
  TestSupport.cleanup_testing_database()
end)