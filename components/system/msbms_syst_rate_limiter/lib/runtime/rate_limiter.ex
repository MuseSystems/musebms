# Source File: rate_limiter.ex
# Location:    musebms/components/system/msbms_syst_rate_limiter/lib/runtime/rate_limiter.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystRateLimiter.Runtime.RateLimiter do
  import MsbmsSystUtils

  alias MsbmsSystRateLimiter.Types

  require Logger

  @moduledoc false

  @spec init_backend(Types.table(), [Types.create_option()]) ::
          Types.t_result(:ok) | {:error, MsbmsSystError.t()}
  def init_backend(table_name, opts) do
    opts = resolve_options(opts, [])

    Hammer.Backend.Mnesia.create_mnesia_table(table_name, opts)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure initializing rate limiter counters.",
          cause: error
        }
      }
  end
end
