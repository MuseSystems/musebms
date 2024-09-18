# Source File: instance_state.ex
# Location:    musebms/components/system/mscmp_syst_instance/lib/impl/instance_state.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Impl.InstanceState do
  @moduledoc false

  alias MscmpSystInstance.Types

  ##############################################################################
  #
  # get_instance_state_by_name
  #
  #

  @spec get_instance_state_by_name(Types.instance_state_name()) :: Msdata.SystEnumItems.t() | nil
  def get_instance_state_by_name(instance_state_name),
    do: MscmpSystEnums.get_enum_item_by_name("instance_states", instance_state_name)

  ##############################################################################
  #
  # get_instance_state_default
  #
  #

  @spec get_instance_state_default(Types.instance_state_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  def get_instance_state_default(nil), do: MscmpSystEnums.get_default_enum_item("instance_states")

  ##############################################################################
  #
  # get_instance_state_default
  #
  #

  def get_instance_state_default(functional_type) when is_atom(functional_type) do
    MscmpSystEnums.get_default_enum_item("instance_states",
      functional_type_name: Atom.to_string(functional_type)
    )
  end
end
