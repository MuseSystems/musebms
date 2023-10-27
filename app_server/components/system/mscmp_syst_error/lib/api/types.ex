# Source File: types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_error/lib/api/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystError.Types do
  @moduledoc """
  Defines the public types exposed by the MscmpSystError component.
  """

  @typedoc """
  Categories or groups of error kinds which might be seen in the application.

  The level of granularity we're trying to achieve here is we want any logic
  that makes decisions on whether to handle an error/exception to be able to
  understand the nature of the error.
  """
  @type mscmp_error ::
          :undefined_error
          | :database_error
          | :example_error
          | :file_error
          | :invalid_data
          | :invalid_parameter
          | :permission_denied
          | :record_not_found
          | :process_error
end
