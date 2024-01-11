# Source File: identity_email_test.exs
# Location:    musebms/components/system/mscmp_syst_authn/test/identity_email_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule IdentityEmailTest do
  # credo:disable-for-this-file Credo.Check.Design.AliasUsage
  #
  # In the tests we'll be more permissive of failing this check for now.
  # In application code we should adhere to our configured checks.

  use AuthenticationTestCase, async: true

  import Ecto.Query

  alias MscmpSystAuthn.Impl

  @moduletag :unit
  @moduletag :capture_log

  test "Can validate Email Address format" do
    assert {:ok, "AValid!EmailAddress@MuseSystems.Com"} =
             Impl.Identity.Email.verify_email_address("AValid!EmailAddress@MuseSystems.Com")

    assert {:error, %MscmpSystError{}} =
             Impl.Identity.Email.verify_email_address("AValid!EmailAddress")
  end

  test "Can normalize Email Address" do
    assert "AValid!EmailAddress@musesystems.com" =
             Impl.Identity.Email.normalize_email_address("AValid!EmailAddress@MuseSystems.Com")
  end

  test "Can create Email Identity" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("identity_email_create_test_accnt")

    # Default Options
    assert {:ok, default_identity} =
             Impl.Identity.Email.create_identity(
               access_account_id,
               "identity_email_create_test_accnt@musesystems.com"
             )

    assert %Msdata.SystIdentities{validated: nil, account_identifier: identifier} =
             default_identity

    assert "identity_email_create_test_accnt@musesystems.com" = identifier

    :deleted = Impl.Identity.delete_identity(default_identity.id, "identity_types_sysdef_email")

    # Options: create_validated

    assert {:ok, default_identity} =
             Impl.Identity.Email.create_identity(
               access_account_id,
               "identity_email_create_test_accnt@musesystems.com",
               create_validated: true
             )

    assert %Msdata.SystIdentities{validated: val_date, account_identifier: identifier} =
             default_identity

    assert DateTime.compare(val_date, DateTime.utc_now()) in [:eq, :lt]

    assert "identity_email_create_test_accnt@musesystems.com" = identifier

    :deleted = Impl.Identity.delete_identity(default_identity.id, "identity_types_sysdef_email")

    # Bad Email Address

    assert {:error, %MscmpSystError{}} =
             Impl.Identity.Email.create_identity(
               access_account_id,
               "identity_email_create_test_accnt"
             )

    # Mixed Case Handling

    assert {:ok, default_identity} =
             Impl.Identity.Email.create_identity(
               access_account_id,
               "Identity_Email_Create_Test_Accnt@MuseSystems.Com"
             )

    assert %Msdata.SystIdentities{validated: nil, account_identifier: identifier} =
             default_identity

    assert "Identity_Email_Create_Test_Accnt@musesystems.com" = identifier
  end

  test "Can identify Owned Access Account" do
    target =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: %{account_identifier: i.account_identifier, owning_owner_id: aa.owning_owner_id},
        where:
          aa.internal_name == "owned_all_access" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MscmpSystDb.one!()

    assert %Msdata.SystIdentities{} =
             Impl.Identity.Email.identify_access_account(
               target.account_identifier,
               target.owning_owner_id
             )

    assert Impl.Identity.Email.identify_access_account(target.account_identifier, nil) == nil
  end

  test "Can identify Unowned Access Account" do
    good_target =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: %{account_identifier: i.account_identifier},
        where:
          aa.internal_name == "unowned_all_access" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MscmpSystDb.one!()

    assert %Msdata.SystIdentities{} =
             Impl.Identity.Email.identify_access_account(
               good_target.account_identifier,
               nil
             )

    bad_target =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: %{account_identifier: i.account_identifier},
        where:
          aa.internal_name == "owned_all_access" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MscmpSystDb.one!()

    assert Impl.Identity.Email.identify_access_account(bad_target.account_identifier, nil) == nil
  end

  test "Can identify Access Account with mixed case email" do
    assert %Msdata.SystIdentities{} =
             Impl.Identity.Email.identify_access_account(
               "unowned_all_access@MuseSystems.COM",
               nil
             )

    assert Impl.Identity.Email.identify_access_account("Unowned_All_Access@musesystems.com", nil) ==
             nil
  end
end
