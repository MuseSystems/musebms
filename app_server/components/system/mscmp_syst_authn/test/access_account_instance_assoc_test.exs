# Source File: access_account_instance_assoc_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_authn/test/access_account_instance_assoc_test.exs
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
  @moduledoc false

  use AuthenticationTestCase, async: true

  import Ecto.Query

  alias MscmpSystAuthn.Impl.AccessAccountInstanceAssoc

  @moduletag :unit
  @moduletag :capture_log

  describe "invite_to_instance/3" do
    test "can create immediate acceptance invitation" do
      access_account_id =
        from(aa in Msdata.SystAccessAccounts,
          where: aa.internal_name == "invite_to_instance_test_accnt",
          select: aa.id
        )
        |> MscmpSystDb.one!()

      instance_id =
        from(
          i in Msdata.SystInstances,
          join: o in assoc(i, :owner),
          join: is in assoc(i, :instance_lifecycle_state),
          where:
            o.internal_name == "owner1" and
              is.internal_name == "instance_lifecycle_states_sysdef_active",
          select: i.id,
          limit: 1
        )
        |> MscmpSystDb.one!()

      test_now = DateTime.now!("Etc/UTC") |> DateTime.truncate(:second)

      assert {:ok, new_record} =
               AccessAccountInstanceAssoc.invite_to_instance(access_account_id, instance_id,
                 create_accepted: true
               )

      assert DateTime.diff(new_record.access_granted, test_now) >= 0
      assert DateTime.diff(new_record.invitation_issued, test_now) >= 0
      assert is_nil(new_record.invitation_expires)
      assert is_nil(new_record.invitation_declined)

      # Cannot invite again if already accepted
      assert {:error, _error} =
               AccessAccountInstanceAssoc.invite_to_instance(access_account_id, instance_id,
                 create_accepted: true
               )
    end
  end

  describe "accept_instance_invite/2" do
    test "can accept pending invitation once" do
      access_account_id =
        from(aa in Msdata.SystAccessAccounts,
          where: aa.internal_name == "accept_account_to_instance_test_accnt",
          select: aa.id
        )
        |> MscmpSystDb.one!()

      instance_id =
        from(
          i in Msdata.SystInstances,
          where: i.internal_name == "app1_owner1_instance_types_std",
          select: i.id
        )
        |> MscmpSystDb.one!()

      test_now = DateTime.now!("Etc/UTC") |> DateTime.truncate(:second)

      assert {:ok, new_record} =
               AccessAccountInstanceAssoc.accept_instance_invite(
                 access_account_id,
                 instance_id
               )

      assert DateTime.diff(new_record.access_granted, test_now) >= 0
      assert DateTime.diff(new_record.invitation_issued, test_now) <= 0
      assert is_nil(new_record.invitation_declined)

      # Cannot accept again
      assert {:error, _error} = AccessAccountInstanceAssoc.accept_instance_invite(new_record.id)
    end
  end

  describe "decline_instance_invite/2" do
    test "can decline pending invitation once" do
      access_account_id =
        from(aa in Msdata.SystAccessAccounts,
          where: aa.internal_name == "decline_account_to_instance_test_accnt",
          select: aa.id
        )
        |> MscmpSystDb.one!()

      instance_id =
        from(
          i in Msdata.SystInstances,
          where: i.internal_name == "app1_owner1_instance_types_std",
          select: i.id
        )
        |> MscmpSystDb.one!()

      test_now = DateTime.now!("Etc/UTC") |> DateTime.truncate(:second)

      assert {:ok, new_record} =
               AccessAccountInstanceAssoc.decline_instance_invite(access_account_id, instance_id)

      assert DateTime.diff(new_record.invitation_declined, test_now) >= 0
      assert DateTime.diff(new_record.invitation_issued, test_now) <= 0
      assert is_nil(new_record.access_granted)

      # Cannot decline again
      assert {:error, _error} = AccessAccountInstanceAssoc.decline_instance_invite(new_record.id)
    end
  end

  describe "revoke_instance_access/2" do
    test "can revoke instance access once" do
      access_account_id =
        from(aa in Msdata.SystAccessAccounts,
          where: aa.internal_name == "revoke_account_to_instance_test_accnt",
          select: aa.id
        )
        |> MscmpSystDb.one!()

      instance_id =
        from(
          i in Msdata.SystInstances,
          where: i.internal_name == "app1_owner1_instance_types_std",
          select: i.id
        )
        |> MscmpSystDb.one!()

      assert :ok =
               AccessAccountInstanceAssoc.revoke_instance_access(access_account_id, instance_id)

      # Cannot revoke again
      assert {:error, _error} =
               AccessAccountInstanceAssoc.revoke_instance_access(access_account_id, instance_id)
    end
  end

  describe "instance_access_granted?/2" do
    test "correctly reports access grant status" do
      access_account_id =
        from(aa in Msdata.SystAccessAccounts,
          where: aa.internal_name == "instance_access_granted_test_accnt",
          select: aa.id
        )
        |> MscmpSystDb.one!()

      instance_id =
        from(
          i in Msdata.SystInstances,
          join: o in assoc(i, :owner),
          join: is in assoc(i, :instance_lifecycle_state),
          where:
            o.internal_name == "owner1" and
              is.internal_name == "instance_lifecycle_states_sysdef_active",
          select: i.id,
          limit: 1
        )
        |> MscmpSystDb.one!()

      # Initially no access
      refute AccessAccountInstanceAssoc.instance_access_granted?(access_account_id, instance_id)

      # Grant access
      {:ok, _} =
        AccessAccountInstanceAssoc.invite_to_instance(access_account_id, instance_id,
          create_accepted: true
        )

      # Now should have access
      assert AccessAccountInstanceAssoc.instance_access_granted?(access_account_id, instance_id)
    end
  end
end
