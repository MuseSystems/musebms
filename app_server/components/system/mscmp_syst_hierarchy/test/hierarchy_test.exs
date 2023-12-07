# Source File: hierarchy_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_hierarchy/test/hierarchy_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule HierarchyTest do
  use HierarchyTestCase, async: true

  import Ecto.Query

  alias MscmpSystHierarchy.Impl

  @moduletag :capture_log

  @hierarchy_types [
    "hierarchy_types_sysdef_test_01",
    "hierarchy_types_sysdef_test_02",
    "hierarchy_types_sysdef_test_03"
  ]

  @hierarchy_states ["hierarchy_states_sysdef_inactive", "hierarchy_states_sysdef_active"]

  @hierarchies ["hierarchy_test_01", "hierarchy_test_02", "hierarchy_test_03"]

  test "Can get Hierarchy Type by Name" do
    [type_internal_name] = Enum.take_random(@hierarchy_types, 1)

    control_record =
      from(ei in Msdata.SystEnumItems,
        where: ei.internal_name == ^type_internal_name
      )
      |> MscmpSystDb.one!()

    assert success_record = Impl.Hierarchy.get_hierarchy_type_by_name(type_internal_name)

    assert control_record.id === success_record.id
    assert control_record.internal_name === success_record.internal_name

    assert nil === Impl.Hierarchy.get_hierarchy_type_by_name("nonexistent_type")
  end

  test "Can get Hierarchy Type Record ID by Name" do
    [type_internal_name] = Enum.take_random(@hierarchy_types, 1)

    control_id =
      from(ei in Msdata.SystEnumItems,
        select: ei.id,
        where: ei.internal_name == ^type_internal_name
      )
      |> MscmpSystDb.one!()

    assert success_id = Impl.Hierarchy.get_hierarchy_type_id_by_name(type_internal_name)

    assert control_id === success_id

    assert nil === Impl.Hierarchy.get_hierarchy_type_id_by_name("nonexistent_type")
  end

  test "Can list Hierarchy Types with Exceptions" do
    ## No sort tests
    assert unsorted_success_list = Impl.Hierarchy.list_hierarchy_types!(sorted: false)

    assert Enum.all?(unsorted_success_list, &(&1.internal_name in @hierarchy_types))

    ## Sorted tests
    sorted_hierarchies = Enum.reverse(@hierarchy_types)

    assert sorted_success_list = Impl.Hierarchy.list_hierarchy_types!([])

    assert Enum.zip_reduce(sorted_hierarchies, sorted_success_list, true, fn a, b, acc ->
             a === b.internal_name and acc
           end)
  end

  test "Can list Hierarchy Types with Result Tuples" do
    ## No sort tests
    assert {:ok, unsorted_success_list} = Impl.Hierarchy.list_hierarchy_types(sorted: false)

    assert Enum.all?(unsorted_success_list, &(&1.internal_name in @hierarchy_types))

    ## Sorted tests
    sorted_hierarchies = Enum.reverse(@hierarchy_types)

    assert {:ok, sorted_success_list} = Impl.Hierarchy.list_hierarchy_types([])

    assert Enum.zip_reduce(sorted_hierarchies, sorted_success_list, true, fn a, b, acc ->
             a === b.internal_name and acc
           end)
  end

  test "Can get Hierarchy State by Name" do
    [state_internal_name] = Enum.take_random(@hierarchy_states, 1)

    control_record =
      from(ei in Msdata.SystEnumItems,
        where: ei.internal_name == ^state_internal_name
      )
      |> MscmpSystDb.one!()

    assert success_record = Impl.Hierarchy.get_hierarchy_state_by_name(state_internal_name)

    assert control_record.id === success_record.id
    assert control_record.internal_name === success_record.internal_name

    assert nil === Impl.Hierarchy.get_hierarchy_state_by_name("nonexistent_state")
  end

  test "Can get Hierarchy State Record ID by Name" do
    [state_internal_name] = Enum.take_random(@hierarchy_states, 1)

    control_id =
      from(ei in Msdata.SystEnumItems,
        select: ei.id,
        where: ei.internal_name == ^state_internal_name
      )
      |> MscmpSystDb.one!()

    assert success_id = Impl.Hierarchy.get_hierarchy_state_id_by_name(state_internal_name)

    assert control_id === success_id

    assert nil === Impl.Hierarchy.get_hierarchy_state_id_by_name("nonexistent_state")
  end

  test "Can get Default Hierarchy State" do
    ## Enum Default Tests
    enum_default_control_record =
      from(ei in Msdata.SystEnumItems,
        join: e in assoc(ei, :enum),
        select: ei,
        where: e.internal_name == "hierarchy_states" and ei.enum_default
      )
      |> MscmpSystDb.one!()

    assert enum_default_success_record = Impl.Hierarchy.get_hierarchy_state_default(nil)

    assert enum_default_control_record.id === enum_default_success_record.id
    assert enum_default_control_record.internal_name === enum_default_success_record.internal_name
    assert "hierarchy_states_sysdef_inactive" === enum_default_success_record.internal_name

    ## Enum Functional Type Default Tests
    type_default_control_record =
      from(ei in Msdata.SystEnumItems,
        join: eft in assoc(ei, :functional_type),
        select: ei,
        where: eft.internal_name == "hierarchy_states_active" and ei.functional_type_default
      )
      |> MscmpSystDb.one!()

    assert type_default_success_record =
             Impl.Hierarchy.get_hierarchy_state_default(:hierarchy_states_active)

    assert type_default_control_record.id === type_default_success_record.id
    assert type_default_control_record.internal_name === type_default_success_record.internal_name
    assert "hierarchy_states_sysdef_active" === type_default_success_record.internal_name
  end

  test "Can get Default Hierarchy State Record ID" do
    ## Enum Default Tests
    enum_default_control_id =
      from(ei in Msdata.SystEnumItems,
        join: e in assoc(ei, :enum),
        select: ei.id,
        where: e.internal_name == "hierarchy_states" and ei.enum_default
      )
      |> MscmpSystDb.one!()

    assert enum_default_success_id = Impl.Hierarchy.get_hierarchy_state_default_id(nil)

    assert enum_default_control_id === enum_default_success_id

    ## Enum Functional Type Default Tests
    type_default_control_id =
      from(ei in Msdata.SystEnumItems,
        join: eft in assoc(ei, :functional_type),
        select: ei.id,
        where: eft.internal_name == "hierarchy_states_active" and ei.functional_type_default
      )
      |> MscmpSystDb.one!()

    assert type_default_success_id =
             Impl.Hierarchy.get_hierarchy_state_default_id(:hierarchy_states_active)

    assert type_default_control_id === type_default_success_id
  end

  test "Can get Hierarchy Record ID by Name with Exceptions" do
    [hierarchy_internal_name] = Enum.take_random(@hierarchies, 1)

    control_hierarchy_id =
      from(h in Msdata.SystHierarchies,
        select: h.id,
        where: h.internal_name == ^hierarchy_internal_name
      )
      |> MscmpSystDb.one!()

    assert success_hierarchy_id =
             Impl.Hierarchy.get_hierarchy_id_by_name!(hierarchy_internal_name)

    assert control_hierarchy_id === success_hierarchy_id

    assert catch_error(Impl.Hierarchy.get_hierarchy_id_by_name!("nonexistent_hierarchy"))
  end

  test "Can get Hierarchy Record ID by Name with Result Tuples" do
    [hierarchy_internal_name] = Enum.take_random(@hierarchies, 1)

    control_hierarchy_id =
      from(h in Msdata.SystHierarchies,
        select: h.id,
        where: h.internal_name == ^hierarchy_internal_name
      )
      |> MscmpSystDb.one!()

    assert {:ok, success_hierarchy_id} =
             Impl.Hierarchy.get_hierarchy_id_by_name(hierarchy_internal_name)

    assert control_hierarchy_id === success_hierarchy_id

    assert {:error, %MscmpSystError{}} =
             Impl.Hierarchy.get_hierarchy_id_by_name("nonexistent_hierarchy")
  end
end
