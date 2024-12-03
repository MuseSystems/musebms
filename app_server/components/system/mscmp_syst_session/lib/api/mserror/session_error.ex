# Source File: session_error.ex
# Location:    musebms/app_server/components/system/mscmp_syst_session/lib/api/mserror/session_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mserror.SessionError do
  @moduledoc """
  Defines an `Mserror` compliant error module for the MscmpSystSession component.

  For more see the `MscmpSystError` Component documentation.
  """

  use MscmpSystError,
    component: MscmpSystSession,
    kinds: [session_management: "Failure performing a Session Management operation."]
end
