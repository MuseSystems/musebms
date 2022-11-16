# Source File: application.ex
# Location:    musebms/components/system/mscmp_syst_limiter/lib/runtime/application.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystLimiter.Runtime.Application do
  require Logger

  @default_backend Hammer.Backend.Mnesia
  @default_expiry_ms 60_000 * 60 * 2
  @default_cleanup_interval_ms 60_000 * 10
  @default_table_name :mscmp_syst_limiter_counters

  @moduledoc false

  # start/2 is called automatically on OTP application start-up.
  #
  # TODO: There's a good argument to be made that MscmpSystLimiter shouldn't
  #       be a startable application at all.  Rather it should be started via
  #       a start_link call by the consuming application.  This would mean that
  #       it could be started under an application defined supervision tree.
  #       The to-do here is to reconsider that possibility.

  @spec start(Application.start_type(), term()) ::
          {:ok, pid()} | {:ok, pid(), Application.state()} | {:error, term()}
  def start(_type, args \\ []) do
    expiry_ms =
      args[:expiry_ms] ||
        Application.get_env(:mscmp_syst_limiter, :expiry_ms, @default_expiry_ms)

    cleanup_interval_ms =
      args[:cleanup_interval_ms] ||
        Application.get_env(
          :mscmp_syst_limiter,
          :cleanup_interval_ms,
          @default_cleanup_interval_ms
        )

    table_name =
      args[:table_name] ||
        Application.get_env(:mscmp_syst_limiter, :table_name, @default_table_name)

    hammer_config =
      {@default_backend,
       [expiry_ms: expiry_ms, cleanup_interval_ms: cleanup_interval_ms, table_name: table_name]}

    Application.put_env(:hammer, :backend, hammer_config)

    Hammer.Supervisor.start_link(hammer_config, name: MscmpSystLimiter.Supervisor)
  end

  @spec start_phase(atom(), Application.start_type(), term()) :: :ok | {:error, reason :: term()}
  def start_phase(:post_mnesia_setup, _type, args \\ []) do
    mnesia_table_args = args[:mnesia_table_args] || []

    case init_rate_limiter(mnesia_table_args: mnesia_table_args) do
      {:ok, _details} -> :ok
      result -> result
    end
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
