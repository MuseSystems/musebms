# Source File: access_account_instance_assoc_test.exs
# Location:    musebms/components/system/msbms_syst_authentication/test/access_account_instance_assoc_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule AccessAccountInstanceAssocTest do
  use AuthenticationTestCase, async: true

  import Ecto.Query

  alias MsbmsSystAuthentication.Data

  test "Can invite Access Account to Instance Immediate Acceptance once" do
    {:ok, access_account} =
      MsbmsSystAuthentication.get_access_account_by_name("invite_to_instance_test_accnt")

    instance_id =
      from(
        i in MsbmsSystInstanceMgr.Data.SystInstances,
        join: o in assoc(i, :owner),
        join: is in assoc(i, :instance_state),
        where:
          o.internal_name == "owner1" and is.internal_name == "instance_states_sysdef_active",
        select: i.id,
        limit: 1
      )
      |> MsbmsSystDatastore.one!()

    credential_type =
      MsbmsSystEnums.get_enum_item_by_name(
        "credential_types",
        "credential_types_sysdef_token_api"
      )

    test_now = DateTime.now!("Etc/UTC")

    assert {:ok, new_record} =
             MsbmsSystAuthentication.invite_to_instance(
               access_account.id,
               instance_id,
               credential_type.id,
               create_accepted: true
             )

    assert DateTime.diff(new_record.access_granted, test_now) >= 0
    assert DateTime.diff(new_record.invitation_issued, test_now) >= 0
    assert is_nil(new_record.invitation_expires)
    assert is_nil(new_record.invitation_declined)

    assert {:error, _error} =
             MsbmsSystAuthentication.invite_to_instance(
               access_account.id,
               instance_id,
               credential_type.id,
               create_accepted: true
             )
  end

  test "Can accept Access Account to Instance invitation once" do
    {:ok, access_account} =
      MsbmsSystAuthentication.get_access_account_by_name("accept_account_to_instance_test_accnt")

    instance_id =
      from(
        i in MsbmsSystInstanceMgr.Data.SystInstances,
        where: i.internal_name == "app1_owner1_instance_types_std",
        select: i.id
      )
      |> MsbmsSystDatastore.one!()

    credential_type =
      MsbmsSystEnums.get_enum_item_by_name(
        "credential_types",
        "credential_types_sysdef_password"
      )

    test_now = DateTime.now!("Etc/UTC")

    assert {:ok, new_record} =
             MsbmsSystAuthentication.accept_instance_invite(
               access_account.id,
               instance_id,
               credential_type.id
             )

    assert DateTime.diff(new_record.access_granted, test_now) >= 0
    assert DateTime.diff(new_record.invitation_issued, test_now) <= 0
    assert is_nil(new_record.invitation_declined)

    assert {:error, _error} = MsbmsSystAuthentication.accept_instance_invite(new_record.id)
  end

  test "Can decline Access Account to Instance invitation once" do
    {:ok, access_account} =
      MsbmsSystAuthentication.get_access_account_by_name("decline_account_to_instance_test_accnt")

    instance_id =
      from(
        i in MsbmsSystInstanceMgr.Data.SystInstances,
        where: i.internal_name == "app1_owner1_instance_types_std",
        select: i.id
      )
      |> MsbmsSystDatastore.one!()

    credential_type =
      MsbmsSystEnums.get_enum_item_by_name(
        "credential_types",
        "credential_types_sysdef_password"
      )

    test_now = DateTime.now!("Etc/UTC")

    assert {:ok, new_record} =
             MsbmsSystAuthentication.decline_instance_invite(
               access_account.id,
               instance_id,
               credential_type.id
             )

    assert DateTime.diff(new_record.invitation_declined, test_now) >= 0
    assert DateTime.diff(new_record.invitation_issued, test_now) <= 0
    assert is_nil(new_record.access_granted)

    assert {:error, _error} = MsbmsSystAuthentication.decline_instance_invite(new_record.id)
  end

  test "Can revoke Access Account to Instance invitation once" do
    {:ok, access_account} =
      MsbmsSystAuthentication.get_access_account_by_name("revoke_account_to_instance_test_accnt")

    instance_id =
      from(
        i in MsbmsSystInstanceMgr.Data.SystInstances,
        where: i.internal_name == "app1_owner1_instance_types_std",
        select: i.id
      )
      |> MsbmsSystDatastore.one!()

    credential_type =
      MsbmsSystEnums.get_enum_item_by_name(
        "credential_types",
        "credential_types_sysdef_password"
      )

    test_now = DateTime.now!("Etc/UTC")

    assert :ok =
             MsbmsSystAuthentication.revoke_instance_access(
               access_account.id,
               instance_id,
               credential_type.id
             )

    assert {:error, _error} =
             MsbmsSystAuthentication.revoke_instance_access(
               access_account.id,
               instance_id,
               credential_type.id
             )
  end
end
