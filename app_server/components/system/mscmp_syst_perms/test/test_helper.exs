# Source File: test_helper.exs
# Location:    musebms/components/system/mscmp_syst_perms/test/test_helper.exs
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
#  for module testing purposes.

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

test_registry = MscmpSystPerms.TestRegistry

children = [
  Registry.child_spec(keys: :unique, name: test_registry),
  TestSupport.setup_testing_database(test_kind, context_registry: test_registry)
]

{:ok, _pid} =
  Supervisor.start_link(children,
    strategy: :one_for_one,
    name: :"MscmpSystPerms.TestSupportSupervisor"
  )

ExUnit.start()

ExUnit.after_suite(fn _suite_result ->
  TestSupport.cleanup_testing_database(test_kind, context_registry: test_registry)
end)
