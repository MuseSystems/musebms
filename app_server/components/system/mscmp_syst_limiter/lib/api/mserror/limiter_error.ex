# Source File: limiter_error.ex
# Location:    musebms/app_server/components/system/mscmp_syst_limiter/lib/api/mserror/limiter_error.ex
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
      service_management: "Failure performing a service management operation.",
      limiter_management: "Failure managing a rate limiter instance.",
      check_limiter: "Failure incrementing or inspecting a rate limiter counter.",
      reset_limiter: "Failure resetting a rate limiter counter."
    ],
    component: MscmpSystLimiter
end
