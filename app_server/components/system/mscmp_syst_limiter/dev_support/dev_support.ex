# Source File: dev_support.ex
# Location:    musebms/app_server/components/system/mscmp_syst_limiter/dev_support/dev_support.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule DevSupport do
  alias Mix.Tasks.Builddb

  use MscmpSystLimiter.Macros

  limiter_devsupport(:dev)

  def start_dev_environment(db_kind \\ :unit_testing) do
    children =
      [
        MscmpSystLimiter.child_spec(
          service_name: @limiter_service_name,
          algorithms: :all,
          cleanup_interval: [all: 60_000]
        )
      ]

    {:ok, _pid} =
      Supervisor.start_link(
        children,
        strategy: :one_for_one,
        name: :"MscmpSystLimiter.DevSupportSupervisor"
      )

    _ = MscmpSystLimiter.put_service(@limiter_service_name)

    :ok
  end

  def stop_dev_environment do
    Supervisor.stop(:"MscmpSystLimiter.DevSupportSupervisor")
  end
end
