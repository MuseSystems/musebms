# Source File: types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_hierarchy/lib/api/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystHierarchy.Types do
  @moduledoc """
  Types defining `MscmpSystHierarchy` object data types and data structures.
  """

  #
  # Note that the ordering of typespecs here is alphabetical.
  #

  @type hierarchy_id() :: Ecto.UUID.t()

  @type hierarchy_item_id() :: Ecto.UUID.t()

  @type hierarchy_item_name() :: String.t()

  @type hierarchy_name() :: String.t()

  @type hierarchy_state_functional_types :: :hierarchy_states_active | :hierarch_states_inactive

  @type hierarchy_state_id() :: MscmpSystEnums.Types.enum_item_id()

  @type hierarchy_state_name() :: MscmpSystEnums.Types.enum_item_name()

  @type hierarchy_type_id() :: MscmpSystEnums.Types.enum_item_id()

  @type hierarchy_type_name() :: MscmpSystEnums.Types.enum_item_name()
end
