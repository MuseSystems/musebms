# Source File: interaction_error.ex
# Location:    musebms/app_server/components/system/mscmp_syst_interaction/lib/api/mserror/interaction_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mserror.InteractionError do
  @moduledoc """
  Defines an `Mserror` compliant error module for the MscmpSystInteraction component.

  For more see the `MscmpSystError` Component documentation.
  """

  use MscmpSystError,
    component: MscmpSystInteraction,
    kinds: [
      service_management: "Failure performing a Service Management operation.",
      context_configuration: "Failure operating on Context Configuration data."
    ]
end
