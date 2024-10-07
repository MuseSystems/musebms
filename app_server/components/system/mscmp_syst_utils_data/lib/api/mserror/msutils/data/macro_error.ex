# Source File: macro_error.ex
# Location:    musebms/app_server/components/system/mscmp_syst_utils_data/lib/api/mserror/msutils/data/macro_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mserror.Msutils.Data.MacroError do
  @moduledoc """
  This module defines the macro related error types for the Msutils.Data module.
  """

  use MscmpSystError,
    kinds: [
      invalid_option: """
      Defines errors where the selected options are invalid even though they
      are in the correct form.
      """,
      invalid_selector: """
      Defines errors where the parameter value is of an invalid type.
      """
    ],
    component: MscmpSystUtilsData
end
