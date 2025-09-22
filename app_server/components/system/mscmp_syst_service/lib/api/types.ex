# Source File: types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_service/lib/api/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystService.Types do
  @moduledoc """
  Type definitions for the MscmpSystService module.

  This module defines the core types used throughout the Mscmp Syst Service component.
  """

  @typedoc """
  The valid forms of service name acceptable to identify MscmpSystService
  compliant services.

  When the service name is an atom, it is assumed to be a registered name using
  the default Elixir name registration process.  When the service name is a
  String, you must also identify a valid registry with which the name will be
  registered.  Finally, if the value is `nil`, the service will be started
  without a name and you are responsible for using the returned PID for later
  accesses of the service.
  """
  @type service_name() :: GenServer.name() | nil
end
