# Source File: instance_type_contexts_test.exs
# Location:    components/system/msbms_syst_instance_mgr/test/instance_type_contexts_test.exs
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule InstanceTypeContextTest do
  use InstanceMgrTestCase, async: true

  alias MsbmsSystInstanceMgr.Data

  test "Can Get Instance Type Contexts" do
    assert {:ok, [_ | _] = instance_type_contexts} =
             MsbmsSystInstanceMgr.list_instance_type_contexts()

    Enum.each(
      instance_type_contexts,
      &assert(
        %Data.SystInstanceTypeContexts{
          instance_type_application: %Ecto.Association.NotLoaded{},
          application_context: %Ecto.Association.NotLoaded{}
        } = &1
      )
    )
  end

  test "Can Get Instance Type Contexts Filtered by Instance Type Name" do
    assert {:ok, instance_type_contexts} =
             MsbmsSystInstanceMgr.list_instance_type_contexts(
               filters: [instance_type_name: "instance_types_big"],
               extra_data: [:instance_type]
             )

    Enum.each(
      instance_type_contexts,
      &assert(&1.instance_type_application.instance_type.internal_name == "instance_types_big")
    )
  end

  test "Can Get Instance Type Contexts Filtered by Instance Type ID" do
    {:ok, instance_type} = MsbmsSystInstanceMgr.get_instance_type_by_name("instance_types_sml")

    assert {:ok, instance_type_contexts} =
             MsbmsSystInstanceMgr.list_instance_type_contexts(
               filters: [instance_type_id: instance_type.id],
               extra_data: [:instance_type]
             )

    Enum.each(
      instance_type_contexts,
      &assert(&1.instance_type_application.instance_type_id == instance_type.id)
    )
  end

  test "Can Get Instance Type Context by login_context" do
    {:ok, instance_type_contexts} =
      MsbmsSystInstanceMgr.list_instance_type_contexts(
        filters: [login_context: true],
        extra_data: [:application_context]
      )

    Enum.each(instance_type_contexts, &assert(&1.application_context.login_context == true))

    {:ok, instance_type_contexts} =
      MsbmsSystInstanceMgr.list_instance_type_contexts(
        filters: [login_context: false],
        extra_data: [:application_context]
      )

    Enum.each(instance_type_contexts, &assert(&1.application_context.login_context == false))
  end

  test "Can Get Instance Type Context by database_owner_context" do
    {:ok, instance_type_contexts} =
      MsbmsSystInstanceMgr.list_instance_type_contexts(
        filters: [database_owner_context: true],
        extra_data: [:application_context]
      )

    Enum.each(
      instance_type_contexts,
      &assert(&1.application_context.database_owner_context == true)
    )

    {:ok, instance_type_contexts} =
      MsbmsSystInstanceMgr.list_instance_type_contexts(
        filters: [database_owner_context: false],
        extra_data: [:application_context]
      )

    Enum.each(
      instance_type_contexts,
      &assert(&1.application_context.database_owner_context == false)
    )
  end

  test "Can Get Instance Type Context by application_name" do
    {:ok, [application | _]} = MsbmsSystInstanceMgr.list_applications()

    {:ok, instance_type_contexts} =
      MsbmsSystInstanceMgr.list_instance_type_contexts(
        filters: [application_name: application.internal_name],
        extra_data: [:application_context]
      )

    Enum.each(
      instance_type_contexts,
      &assert(&1.application_context.application_id == application.id)
    )
  end

  test "Can Get Instance Type Contexts Combined Filters" do
    {:ok, instance_type} = MsbmsSystInstanceMgr.get_instance_type_by_name("instance_types_std")

    # These filters are redundant, but shouldn't prevent the test from running
    # successfully; except in the case where they contradict which should return
    # nothing... this is good test that both params are being added.
    assert {:ok, instance_type_contexts} =
             MsbmsSystInstanceMgr.list_instance_type_contexts(
               filters: [
                 instance_type_id: instance_type.id,
                 instance_type_name: "instance_types_std"
               ],
               extra_data: [:instance_type]
             )

    Enum.each(
      instance_type_contexts,
      &assert(&1.instance_type_application.instance_type.internal_name == "instance_types_std")
    )

    assert {:ok, []} =
             MsbmsSystInstanceMgr.list_instance_type_contexts(
               filters: [
                 instance_type_id: instance_type.id,
                 instance_type_name: "instance_types_big"
               ]
             )
  end

  test "Can List Instance Type Contexts with Only instance_type Extra Data" do
    {:ok, instance_type_contexts} =
      MsbmsSystInstanceMgr.list_instance_type_contexts(extra_data: [:instance_type])

    Enum.each(
      instance_type_contexts,
      &assert(
        %Data.SystInstanceTypeContexts{
          instance_type_application: %Data.SystInstanceTypeApplications{
            instance_type: %MsbmsSystEnums.Data.SystEnumItems{}
          },
          application_context: %Ecto.Association.NotLoaded{}
        } = &1
      )
    )
  end

  test "Can List Instance Type Contexts with Only application_context Extra Data" do
    {:ok, instance_type_contexts} =
      MsbmsSystInstanceMgr.list_instance_type_contexts(extra_data: [:application_context])

    Enum.each(
      instance_type_contexts,
      &assert(
        %Data.SystInstanceTypeContexts{
          instance_type_application: %Ecto.Association.NotLoaded{},
          application_context: %Data.SystApplicationContexts{}
        } = &1
      )
    )
  end

  test "Can List Instance Context Types Sorted By instance_type" do
    {:ok, [first_instance_type_context | _] = instance_type_contexts} =
      MsbmsSystInstanceMgr.list_instance_type_contexts(
        sorts: [:instance_type],
        extra_data: [:instance_type]
      )

    Enum.each(
      instance_type_contexts,
      &assert(
        first_instance_type_context.instance_type_application.instance_type.sort_order <=
          &1.instance_type_application.instance_type.sort_order
      )
    )
  end

  test "Can List Instance Context Types Sorted By application_context" do
    {:ok, [first_instance_type_context | _] = instance_type_contexts} =
      MsbmsSystInstanceMgr.list_instance_type_contexts(
        sorts: [:application_context],
        extra_data: [:application_context]
      )

    Enum.each(
      instance_type_contexts,
      &assert(
        first_instance_type_context.application_context.display_name <=
          &1.application_context.display_name
      )
    )
  end

  test "Can Update Instance Type Context Default DB Pool Size" do
    {:ok, [instance_type_context | _]} =
      MsbmsSystInstanceMgr.list_instance_type_contexts(filters: [login_context: true])

    assert {:ok, updated_instance_type_context} =
             MsbmsSystInstanceMgr.set_instance_type_context_db_pool_size(
               instance_type_context.id,
               instance_type_context.default_db_pool_size + 7
             )

    assert updated_instance_type_context.default_db_pool_size ==
             instance_type_context.default_db_pool_size + 7

    assert {:ok, updated_instance_type_context} =
             MsbmsSystInstanceMgr.set_instance_type_context_db_pool_size(
               instance_type_context.id,
               instance_type_context.default_db_pool_size
             )

    assert updated_instance_type_context.default_db_pool_size ==
             instance_type_context.default_db_pool_size
  end

  test "Can Get Instance Type Context by ID" do
    {:ok, [instance_type_context | _]} =
      MsbmsSystInstanceMgr.list_instance_type_contexts(
        filters: [login_context: false, application_name: "app1"]
      )

    assert {:ok, found_instance_type_context} =
             MsbmsSystInstanceMgr.get_instance_type_context_by_id(instance_type_context.id)

    assert found_instance_type_context.id == instance_type_context.id

    assert %Data.SystInstanceTypeContexts{
             instance_type_application: %Ecto.Association.NotLoaded{},
             application_context: %Ecto.Association.NotLoaded{}
           } = found_instance_type_context
  end

  test "Can Get Instance Type Context by ID with Instance Type Extra Data" do
    {:ok, [instance_type_context | _]} =
      MsbmsSystInstanceMgr.list_instance_type_contexts(
        filters: [login_context: false, application_name: "app1"]
      )

    assert {:ok, found_instance_type_context} =
             MsbmsSystInstanceMgr.get_instance_type_context_by_id(instance_type_context.id,
               extra_data: [:instance_type]
             )

    assert found_instance_type_context.id == instance_type_context.id

    assert %Data.SystInstanceTypeContexts{
             instance_type_application: %Data.SystInstanceTypeApplications{
               instance_type: %MsbmsSystEnums.Data.SystEnumItems{}
             },
             application_context: %Ecto.Association.NotLoaded{}
           } = found_instance_type_context
  end

  test "Can Get Instance Type Context by ID  with Application Context Extra Data" do
    {:ok, [instance_type_context | _]} =
      MsbmsSystInstanceMgr.list_instance_type_contexts(
        filters: [login_context: false, application_name: "app1"]
      )

    assert {:ok, found_instance_type_context} =
             MsbmsSystInstanceMgr.get_instance_type_context_by_id(instance_type_context.id,
               extra_data: [:application_context]
             )

    assert found_instance_type_context.id == instance_type_context.id

    assert %Data.SystInstanceTypeContexts{
             instance_type_application: %Ecto.Association.NotLoaded{},
             application_context: %Data.SystApplicationContexts{}
           } = found_instance_type_context
  end
end
