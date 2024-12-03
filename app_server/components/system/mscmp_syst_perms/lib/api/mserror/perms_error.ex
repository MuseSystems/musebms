# Source File:  perms_error.ex
# Location:     musebms/app_server/components/system/mscmp_syst_perms/lib/api/mserror/perms_error.ex
# Project:      Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mserror.PermsError do
  @moduledoc """
  Defines an `Mserror` compliant error module for the MscmpSystPerms component.

  For more see the `MscmpSystError` Component documentation.
  """

  use MscmpSystError,
    component: MscmpSystPerms,
    kinds: [
      perms_management: "Failure operating on Permission data.",
      perms_data: "Failure operating on Permission data."
    ]
end
