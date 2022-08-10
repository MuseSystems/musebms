# Source File: application.ex
# Location:    musebms/components/system/msbms_syst_rate_limiter/lib/runtime/application.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystRateLimiter.Runtime.Application do
  @default_backend Hammer.Backend.Mnesia
  @default_expiry_ms 60_000 * 60 * 2
  @default_cleanup_interval_ms 60_000 * 10
  @default_table_name :msbms_syst_rate_limiter_counters

  @moduledoc false

  # start/2 is called automatically on OTP application start-up.
  #
  # TODO: There's a good argument to be made that MsbmsSystRateLimiter shouldn't
  #       be a startable application at all.  Rather it should be started via 
  #       a start_link call by the consuming application.  This would mean that
  #       it could be started under an application defined supervision tree.
  #       The to-do here is to reconsider that possibility.

  @spec start(Application.start_type(), term()) ::
          {:ok, pid()} | {:ok, pid(), Application.state()} | {:error, term()}
  def start(_type, args \\ []) do
    expiry_ms =
      args[:expiry_ms] ||
        Application.get_env(:msbms_syst_rate_limiter, :expiry_ms, @default_expiry_ms)

    cleanup_interval_ms =
      args[:cleanup_interval_ms] ||
        Application.get_env(
          :msbms_syst_rate_limiter,
          :cleanup_interval_ms,
          @default_cleanup_interval_ms
        )

    table_name =
      args[:table_name] ||
        Application.get_env(:msbms_syst_rate_limiter, :table_name, @default_table_name)

    hammer_config =
      {@default_backend,
       [expiry_ms: expiry_ms, cleanup_interval_ms: cleanup_interval_ms, table_name: table_name]}

    Application.put_env(:hammer, :backend, hammer_config)

    Hammer.Backend.Mnesia.create_mnesia_table(@default_table_name, [])

    Hammer.Supervisor.start_link(hammer_config, name: MsbmsSystRateLimiter.Supervisor)
  end
end
