# Source File: test_helper.exs
# Location:    musebms/app_server/components/system/mscmp_syst_limiter/test/test_helper.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

_test_kind =
  if ExUnit.configuration() |> Keyword.get(:include) |> Enum.member?(:integration) do
    ExUnit.configure(seed: 0)
    :integration_testing
  else
    ExUnit.configure(exclude: [:integration])
    :unit_testing
  end

test_registry = MscmpSystLimiter.TestRegistry

children = [
  Registry.child_spec(keys: :unique, name: test_registry),
  MscmpSystLimiter.child_spec(
    service_name: TestSupport.get_limiter_service_name(),
    algorithms: :all,
    cleanup_interval: [all: 60_000]
  )
]

{:ok, _pid} =
  Supervisor.start_link(children,
    strategy: :one_for_one,
    name: :"MscmpSystLimiter.TestSupportSupervisor"
  )

ExUnit.start()
