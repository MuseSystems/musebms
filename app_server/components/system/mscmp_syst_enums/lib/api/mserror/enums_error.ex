# Source File: enums_error.ex
# Location:    musebms/app_server/components/system/mscmp_syst_enums/lib/api/mserror/enums_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mserror.EnumsError do
  @moduledoc false

  use MscmpSystError,
    component: MscmpSystEnums,
    kinds: [
      service_management: "Failure operating on an Enums service.",
      enum_data: "Failure operating on Enums data.",
      enum_functional_type_data: "Failure operating on Enums functional type data.",
      enum_item_data: "Failure operating on Enums item data."
    ]
end
