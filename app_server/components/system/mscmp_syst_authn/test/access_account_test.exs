# Source File: access_account_test.exs
# Location:    musebms/components/system/mscmp_syst_authn/test/access_account_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule AccessAccountTest do
  @moduledoc false

  use AuthenticationTestCase, async: true

  alias MscmpSystAuthn.Impl

  @moduletag :unit
  @moduletag :capture_log

  # TODO: Historically, unit testing was performed using the public API calls.
  #       while unit testing the public API helps to ensure the bare essentials
  #       are tested, it's not the final approach we've settled on.  Unit tests
  #       should exercise the internal API and integration tests should exercise
  #       the public API.  These tests were mostly written using the old way and
  #       should be converted at some point.  This only applies to the direct
  #       code being tested; incidental calls supporting the tests should remain
  #       directed to their respective public APIs,

  test "Can create an unowned Access Account" do
    access_account_state = MscmpSystEnums.get_default_enum_item("access_account_states")

    create_params = %{
      internal_name: "create_unowned_test_account",
      external_name: "Create Unowned Test Access Account",
      allow_global_logins: true,
      access_account_state_id: access_account_state.id
    }

    assert {:ok, new_access_account} = MscmpSystAuthn.create_access_account(create_params)

    assert %Msdata.SystAccessAccounts{
             id: new_id,
             internal_name: "create_unowned_test_account",
             external_name: "Create Unowned Test Access Account"
           } = new_access_account

    assert is_binary(new_id)

    assert access_account_state.id == new_access_account.access_account_state_id
  end

  test "Can create an owned Access Account" do
    access_account_state = MscmpSystEnums.get_default_enum_item("access_account_states")

    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner1")

    create_params = %{
      owning_owner_id: owner_id,
      internal_name: "create_owned_test_account",
      external_name: "Create Owned Test Access Account",
      allow_global_logins: false,
      access_account_state_id: access_account_state.id
    }

    assert {:ok, new_access_account} = MscmpSystAuthn.create_access_account(create_params)

    assert %Msdata.SystAccessAccounts{
             id: new_id,
             internal_name: "create_owned_test_account",
             external_name: "Create Owned Test Access Account"
           } = new_access_account

    assert is_binary(new_id)

    assert access_account_state.id == new_access_account.access_account_state_id

    assert owner_id == new_access_account.owning_owner_id
  end

  test "Can retrieve Access Account State by Internal Name" do
    assert %Msdata.SystEnumItems{internal_name: "access_account_states_sysdef_active"} =
             Impl.AccessAccount.get_access_account_state_by_name(
               "access_account_states_sysdef_active"
             )

    assert nil == Impl.AccessAccount.get_access_account_state_by_name("nonexistent_type")
  end

  test "Can retrieve system default Access Account State" do
    assert %Msdata.SystEnumItems{internal_name: "access_account_states_sysdef_pending"} =
             Impl.AccessAccount.get_access_account_state_default(nil)
  end

  test "Can retrieve functional type default Access Account State" do
    assert %Msdata.SystEnumItems{internal_name: "access_account_states_sysdef_inactive"} =
             Impl.AccessAccount.get_access_account_state_default(:access_account_states_inactive)
  end

  test "Can update an Access Account" do
    {:ok, target_account_id} = MscmpSystAuthn.get_access_account_id_by_name("update_test_accnt")

    access_account_state =
      MscmpSystEnums.get_enum_item_by_name(
        "access_account_states",
        "access_account_states_sysdef_purge_eligible"
      )

    update_params = %{
      internal_name: "update_test_accnt_updated",
      external_name: "Update Test Access Account Updated",
      allow_global_logins: true,
      access_account_state_id: access_account_state.id
    }

    assert {:ok, _updated_account} =
             MscmpSystAuthn.update_access_account(target_account_id, update_params)
  end

  test "Cannot update Access Account immutable values" do
    {:ok, target_account_id} =
      MscmpSystAuthn.get_access_account_id_by_name("bad_update_test_accnt")

    {:ok, owner2} = MscmpSystInstance.get_owner_by_name("owner2")

    update_params = %{
      owning_owner_id: owner2.id
    }

    assert {:ok, updated_account} =
             MscmpSystAuthn.update_access_account(target_account_id, update_params)

    refute updated_account.owning_owner_id == owner2.id
  end

  test "Can purge eligible Access Account" do
    {:ok, %Msdata.SystAccessAccounts{id: target_account_id}} =
      MscmpSystAuthn.get_access_account_by_name("purge_test_accnt")

    assert :ok =
             MscmpSystAuthn.purge_access_account(%Msdata.SystAccessAccounts{
               id: target_account_id
             })
  end

  test "Cannot purge ineligible Access Account" do
    {:ok, %Msdata.SystAccessAccounts{id: target_account_id}} =
      MscmpSystAuthn.get_access_account_by_name("owned_all_access")

    assert {:error, _error} =
             MscmpSystAuthn.purge_access_account(%Msdata.SystAccessAccounts{
               id: target_account_id
             })
  end

  test "Can get Access Account ID by Name" do
    assert {:ok, access_account_id} =
             MscmpSystAuthn.get_access_account_id_by_name("unowned_all_access")

    assert is_binary(access_account_id)
  end

  test "Can test if Access Accounts Exists" do
    {:ok, access_account_record} = MscmpSystAuthn.get_access_account_by_name("owned_all_access")

    assert true == Impl.AccessAccount.access_accounts_exist?()

    assert true ==
             Impl.AccessAccount.access_account_id_exists?(access_account_record.id)

    assert false ==
             Impl.AccessAccount.access_account_id_exists?("00000000-0000-0000-0000-000000000000")

    assert true ==
             Impl.AccessAccount.access_account_name_exists?(access_account_record.internal_name)

    assert false ==
             Impl.AccessAccount.access_account_name_exists?("nonexistent_access_account")
  end
end
