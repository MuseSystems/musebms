# Source File: types.ex
# Location:    musebms/app_server/components/application/mscmp_core_hierarchy/lib/api/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpCoreHierarchy.Types do
  @moduledoc """
  Types defining MscmpCoreHierarchy object data types and data structures.
  """

  #
  # Note that the ordering of typespecs here is alphabetical.
  #

  @type hierarchy_id() :: Ecto.UUID.t()

  @type hierarchy_item_id() :: Ecto.UUID.t()

  @type hierarchy_item_name() :: String.t()

  @type hierarchy_name() :: String.t()

  @type hierarchy_type_id() :: MscmpSystEnums.Types.enum_item_id()

  @type hierarchy_type_name() :: String.t()
end
