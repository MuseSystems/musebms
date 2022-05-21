# Source File: doctests_test.exs
# Location:    components/system/msbms_syst_instance_mgr/test/doctests_test.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule DoctestsTest do
  use InstanceMgrTestCase, async: true

  setup_all do
    _ = MsbmsSystDatastore.set_datastore_context(TestSupport.get_testing_datastore_context_id())
    MsbmsSystEnums.put_enums_service(:instance_mgr)

    setup_set_owner_values()
    setup_delete_owner_state()
    setup_delete_instance_type()
    setup_delete_instance_state()

    :ok
  end

  doctest MsbmsSystInstanceMgr

  defp setup_set_owner_values do
    new_owner_state = MsbmsSystEnums.get_default_enum_item("owner_states")

    {:ok, _} =
      MsbmsSystInstanceMgr.create_owner(
        "set_owner_example",
        "Set Owner Values Example",
        new_owner_state.id
      )
  end

  defp setup_delete_owner_state do
    new_state = %{
      internal_name: "owner_state_delete_example",
      display_name: "Owner State / Delete State Example",
      external_name: "Delete Owner State Example",
      user_description: "An example of Owner State deletion.",
      functional_type_name: "owner_states_active"
    }

    {:ok, _owner_state} = MsbmsSystInstanceMgr.create_owner_state(new_state)
  end

  defp setup_delete_instance_type do
    instance_type = %{
      internal_name: "instance_type_delete_example",
      display_name: "Instance Type / Delete Example",
      external_name: "Delete Example",
      functional_type_name: "instance_types_primary",
      user_description: "Example of Instance Type Deletion.",
      user_options: %{}
    }

    {:ok, _instance_type} = MsbmsSystInstanceMgr.create_instance_type(instance_type)
  end

  defp setup_delete_instance_state do
    instance_state = %{
      internal_name: "instance_state_delete_example",
      display_name: "Instance State / Delete Example",
      external_name: "Delete Example",
      functional_type_name: "instance_states_initializing",
      user_description: "Example of Instance State Deletion."
    }

    {:ok, _instance_state} = MsbmsSystInstanceMgr.create_instance_state(instance_state)
  end
end
