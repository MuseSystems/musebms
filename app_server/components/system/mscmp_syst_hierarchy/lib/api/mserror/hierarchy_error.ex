# Source File: hierarchy_error.ex
# Location:    musebms/app_server/components/system/mscmp_syst_hierarchy/lib/api/mserror/hierarchy_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mserror.HierarchyError do
  @moduledoc false

  use MscmpSystError,
    component: MscmpSystHierarchy,
    kinds: [
      hierarchy_data: "Failure operating on Hierarchy data.",
      enumerations_data: "Failure operating on Enumeration data."
    ]
end
