# Source File: instance_error.ex
# Location:    musebms/app_server/components/system/mscmp_syst_instance/lib/api/mserror/instance_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mserror.InstanceError do
  @moduledoc false

  use MscmpSystError,
    component: MscmpSystInstance,
    kinds: [
      owner_data: "Failure operating on Owner data.",
      instance_data: "Failure operating on Instance data.",
      application_data: "Failure operating on Application data.",
      instance_type_data: "Failure operating on Instance Type data.",
      service_management: "Failure performing a Service Management operation."
    ]
end
