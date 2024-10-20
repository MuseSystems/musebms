# Source File: access_account_instance_assoc_test.exs
# Location:    musebms/components/system/mscmp_syst_authn/test/access_account_instance_assoc_test.exs
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

  @moduletag :unit
  @moduletag :capture_log

  test "Can invite Access Account to Instance Immediate Acceptance once" do
    {:ok, access_account} =
      MscmpSystAuthn.get_access_account_by_name("invite_to_instance_test_accnt")

    instance_id =
      from(
        i in Msdata.SystInstances,
        join: o in assoc(i, :owner),
        join: is in assoc(i, :instance_state),
        where:
          o.internal_name == "owner1" and is.internal_name == "instance_states_sysdef_active",
        select: i.id,
        limit: 1
      )
      |> MscmpSystDb.one!()

    test_now = DateTime.now!("Etc/UTC")

    assert {:ok, new_record} =
             MscmpSystAuthn.invite_to_instance(access_account.id, instance_id,
               create_accepted: true
             )

    assert DateTime.diff(new_record.access_granted, test_now) >= 0
    assert DateTime.diff(new_record.invitation_issued, test_now) >= 0
    assert is_nil(new_record.invitation_expires)
    assert is_nil(new_record.invitation_declined)

    assert {:error, _error} =
             MscmpSystAuthn.invite_to_instance(access_account.id, instance_id,
               create_accepted: true
             )
  end

  test "Can accept Access Account to Instance invitation once" do
    {:ok, access_account} =
      MscmpSystAuthn.get_access_account_by_name("accept_account_to_instance_test_accnt")

    instance_id =
      from(
        i in Msdata.SystInstances,
        where: i.internal_name == "app1_owner1_instance_types_std",
        select: i.id
      )
      |> MscmpSystDb.one!()

    test_now = DateTime.now!("Etc/UTC")

    assert {:ok, new_record} =
             MscmpSystAuthn.accept_instance_invite(
               access_account.id,
               instance_id
             )

    assert DateTime.diff(new_record.access_granted, test_now) >= 0
    assert DateTime.diff(new_record.invitation_issued, test_now) <= 0
    assert is_nil(new_record.invitation_declined)

    assert {:error, _error} = MscmpSystAuthn.accept_instance_invite(new_record.id)
  end

  test "Can decline Access Account to Instance invitation once" do
    {:ok, access_account} =
      MscmpSystAuthn.get_access_account_by_name("decline_account_to_instance_test_accnt")

    instance_id =
      from(
        i in Msdata.SystInstances,
        where: i.internal_name == "app1_owner1_instance_types_std",
        select: i.id
      )
      |> MscmpSystDb.one!()

    test_now = DateTime.now!("Etc/UTC")

    assert {:ok, new_record} =
             MscmpSystAuthn.decline_instance_invite(access_account.id, instance_id)

    assert DateTime.diff(new_record.invitation_declined, test_now) >= 0
    assert DateTime.diff(new_record.invitation_issued, test_now) <= 0
    assert is_nil(new_record.access_granted)

    assert {:error, _error} = MscmpSystAuthn.decline_instance_invite(new_record.id)
  end

  test "Can revoke Access Account to Instance invitation once" do
    {:ok, access_account} =
      MscmpSystAuthn.get_access_account_by_name("revoke_account_to_instance_test_accnt")

    instance_id =
      from(
        i in Msdata.SystInstances,
        where: i.internal_name == "app1_owner1_instance_types_std",
        select: i.id
      )
      |> MscmpSystDb.one!()

    assert :ok = MscmpSystAuthn.revoke_instance_access(access_account.id, instance_id)

    assert {:error, _error} =
             MscmpSystAuthn.revoke_instance_access(access_account.id, instance_id)
  end
end
