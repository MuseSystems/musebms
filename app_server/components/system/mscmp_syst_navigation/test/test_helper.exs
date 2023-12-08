# Source File: test_helper.exs
# Location:    musebms/app_server/components/system/mscmp_syst_navigation/test/test_helper.exs
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
  cond do
    ExUnit.configuration() |> Keyword.get(:include) |> Enum.member?(:integration) ->
      ExUnit.configure(seed: 0)
      :integration_testing

    ExUnit.configuration() |> Keyword.get(:include) |> Enum.member?(:doctest) ->
      :doc_testing

    true ->
      ExUnit.configure(exclude: [:integration, :doctest])
      :unit_testing
  end

TestSupport.setup_testing_database(test_kind)

MscmpSystDb.put_datastore_context(TestSupport.get_testing_datastore_context_id())

children = [
  {DynamicSupervisor, strategy: :one_for_one, name: MscmpSystNavigation.TestingSupervisor}
]

Supervisor.start_link(children, strategy: :one_for_one)

enum_service_spec = %{
  id: MscmpSystNavigationTestingEnumService,
  start: {
    MscmpSystEnums,
    :start_link,
    [{:menu, TestSupport.get_testing_datastore_context_id()}]
  }
}

Logger.configure(level: :info)

ExUnit.start()

DynamicSupervisor.start_child(MscmpSystNavigation.TestingSupervisor, enum_service_spec)

ExUnit.after_suite(fn _suite_result ->
  TestSupport.cleanup_testing_database(test_kind)
end)
