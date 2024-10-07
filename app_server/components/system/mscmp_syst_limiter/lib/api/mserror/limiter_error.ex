# Source File: limiter_error.ex
# Location:    musebms/components/system/mscmp_syst_limiter/lib/api/mserror/limiter_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mserror.LimiterError do
  @moduledoc """
  Defines errors and related metadata for MscmpSystLimiter component errors.
  """

  use MscmpSystError,
    kinds: [
      check_counter: "Failure checking and incrementing the rate limit.",
      inspect_counter: "Failure inspecting the rate limit counter.",
      delete_counter: "Failure deleting the rate limit counter."
    ],
    component: MscmpSystLimiter
end
