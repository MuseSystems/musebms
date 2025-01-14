# Source File: process_utils_error.ex
# Location:    musebms/app_server/components/system/mscmp_syst_utils/lib/api/mserror/process_utils_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mserror.ProcessUtilsError do
  @moduledoc """
  This module defines the error types for the Msutils.Process module.
  """

  use MscmpSystError,
    kinds: [
      lookup: """
      Indicates that there was an error looking up a process.
      """,
      registration: """
      Indicates that there was an error registering a process.
      """
    ],
    component: MscmpSystUtilsProcess
end
