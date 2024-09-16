# Source File: types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_utils_data/lib/api/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msutils.Data.Types do
  @moduledoc """
  Data types  for the mscmp_syst_utils_data component.
  """

  @typedoc """
  Establishes the known common changeset validator options.
  """
  @type common_validators() :: :internal_name | :display_name | :external_name | :user_description
end
