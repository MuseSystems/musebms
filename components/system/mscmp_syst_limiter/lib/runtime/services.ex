# Source File: services.ex
# Location:    musebms/components/system/mscmp_syst_limiter/lib/runtime/services.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystLimiter.Runtime.Services do
  require Logger

  @default_backend Hammer.Backend.Mnesia
  @default_expiry_ms 60_000 * 60 * 2
  @default_cleanup_interval_ms 60_000 * 10
  @default_table_name :mscmp_syst_limiter_counters
  @default_supervisor_name MscmpSystLimiter.Supervisor

  @moduledoc false

  @spec start_link(Keyword.t()) :: Supervisor.on_start_child()
  def start_link(opts) do
    opts =
      MscmpSystUtils.resolve_options(opts,
        supervisor_name: @default_supervisor_name,
        expiry_ms: @default_expiry_ms,
        cleanup_interval_ms: @default_cleanup_interval_ms,
        table_name: @default_table_name
      )

    hammer_config =
      {@default_backend,
       [
         expiry_ms: opts[:expiry_ms],
         cleanup_interval_ms: opts[:cleanup_interval_ms],
         table_name: opts[:table_name]
       ]}

    Application.put_env(:hammer, :backend, hammer_config)

    Hammer.Supervisor.start_link(hammer_config, name: opts[:supervisor_name])
  end

  @spec init_rate_limiter(Keyword.t()) ::
          {:ok, detail :: atom()} | {:error, MscmpSystError.t()}
  def init_rate_limiter(opts) do
    {_backend, config_opts} = Application.get_env(:hammer, :backend)

    mnesia_table_args = opts[:mnesia_table_args] || []

    # credo:disable-for-next-line Credo.Check.Design.AliasUsage
    Hammer.Backend.Mnesia.create_mnesia_table(config_opts[:table_name], mnesia_table_args)
    |> process_create_mnesia_table_result()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure initializing rate limiter.",
         cause: error
       }}
  end

  defp process_create_mnesia_table_result({:aborted, {:already_exists, _}}),
    do: {:ok, :resource_exists}

  defp process_create_mnesia_table_result({:aborted, _} = reason) do
    raise MscmpSystError,
      code: :undefined_error,
      message: "Internal error initializing rate limiter.",
      cause: reason
  end

  defp process_create_mnesia_table_result(result), do: {:ok, result}
end
