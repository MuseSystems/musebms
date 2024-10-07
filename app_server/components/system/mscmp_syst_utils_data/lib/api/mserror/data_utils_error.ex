# Source File: data_utils_error.ex
# Location:    musebms/app_server/components/system/mscmp_syst_utils_data/lib/api/mserror/data_utils_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mserror.DataUtilsError do
  @moduledoc """
  This module defines the macro related error types for the Msutils.Data module.
  """

  use MscmpSystError,
    kinds: [
      macro_error: """
      Indicates that there were compilation errors in the macros provided by
      this Component.  This will often times be due to invalid parameters being
      passed to the macros.
      """
    ],
    component: MscmpSystUtilsData
end
