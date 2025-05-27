# Source File: telemetry_error.ex
# Location:    musebms/app_server/components/system/mscmp_syst_telemetry/lib/api/mserror/telemetry_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mserror.TelemetryError do
  @moduledoc """
  Defines an `Mserror` compliant error module for the MscmpSystTelemetry component.

  For more see the `MscmpSystTelemetry` Component documentation.
  """

  use MscmpSystError,
    component: MscmpSystTelemetry,
    kinds: [
      error_kind: "An mscmp_syst_telemetry error kind."
    ]
end
