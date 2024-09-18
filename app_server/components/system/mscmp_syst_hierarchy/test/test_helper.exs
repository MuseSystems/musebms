# Source File: test_helper.exs
# Location:    musebms/app_server/components/system/mscmp_syst_hierarchy/test/test_helper.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

Logger.configure(level: :info)

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

test_registry = MscmpSystHierarchy.TestRegistry

datastore_context_name =
  {:via, Registry, {test_registry, TestSupport.get_datastore_context_name()}}

children =
  [
    Registry.child_spec(keys: :unique, name: test_registry),
    TestSupport.setup_testing_database(test_kind, context_registry: test_registry),
    MscmpSystEnums.child_spec(
      service_name: TestSupport.get_enums_service_name(),
      datastore_context_name: datastore_context_name
    )
  ]

{:ok, _pid} =
  Supervisor.start_link(children,
    strategy: :one_for_one,
    name: :"MscmpSystHierarchy.TestSupportSupervisor"
  )

ExUnit.start()

ExUnit.after_suite(fn _suite_result ->
  TestSupport.cleanup_testing_database(test_kind, context_registry: test_registry)
end)
