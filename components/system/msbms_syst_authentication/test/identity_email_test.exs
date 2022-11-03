# Source File: identity_email_test.exs
# Location:    musebms/components/system/msbms_syst_authentication/test/identity_email_test.exs
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
  use AuthenticationTestCase, async: true

  import Ecto.Query

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl

  test "Can create Email Identity" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("identity_email_create_test_accnt")

    # Default Options
    assert {:ok, default_identity} =
             Impl.Identity.Email.create_identity(
               access_account_id,
               "identity_email_create_test_accnt@musesystems.com"
             )

    assert %Data.SystIdentities{validated: nil, account_identifier: identifier} = default_identity

    assert "identity_email_create_test_accnt@musesystems.com" = identifier

    :ok = Impl.Identity.delete_identity(default_identity.id)

    # Options: create_validated

    assert {:ok, default_identity} =
             Impl.Identity.Email.create_identity(
               access_account_id,
               "identity_email_create_test_accnt@musesystems.com",
               create_validated: true
             )

    assert %Data.SystIdentities{validated: val_date, account_identifier: identifier} =
             default_identity

    assert DateTime.compare(val_date, DateTime.utc_now()) in [:eq, :lt]

    assert "identity_email_create_test_accnt@musesystems.com" = identifier

    :ok = Impl.Identity.delete_identity(default_identity.id)

    # Bad Email Address

    assert {:error, %MsbmsSystError{}} =
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

    assert %Data.SystIdentities{validated: nil, account_identifier: identifier} = default_identity

    assert "Identity_Email_Create_Test_Accnt@musesystems.com" = identifier
  end

  test "Can identify Owned Access Account" do
    target =
      from(
        aa in Data.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: %{account_identifier: i.account_identifier, owning_owner_id: aa.owning_owner_id},
        where:
          aa.internal_name == "owned_all_access" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MsbmsSystDatastore.one!()

    assert %Data.SystIdentities{} =
             Impl.Identity.Email.identify_access_account(
               target.account_identifier,
               target.owning_owner_id
             )

    assert Impl.Identity.Email.identify_access_account(target.account_identifier, nil) == nil
  end

  test "Can identify Unowned Access Account" do
    good_target =
      from(
        aa in Data.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: %{account_identifier: i.account_identifier},
        where:
          aa.internal_name == "unowned_all_access" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MsbmsSystDatastore.one!()

    assert %Data.SystIdentities{} =
             Impl.Identity.Email.identify_access_account(
               good_target.account_identifier,
               nil
             )

    bad_target =
      from(
        aa in Data.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: %{account_identifier: i.account_identifier},
        where:
          aa.internal_name == "owned_all_access" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MsbmsSystDatastore.one!()

    assert Impl.Identity.Email.identify_access_account(bad_target.account_identifier, nil) == nil
  end

  test "Can identify Access Account with mixed case email" do
    assert %Data.SystIdentities{} =
             Impl.Identity.Email.identify_access_account(
               "unowned_all_access@MuseSystems.COM",
               nil
             )

    assert Impl.Identity.Email.identify_access_account("Unowned_All_Access@musesystems.com", nil) ==
             nil
  end
end
