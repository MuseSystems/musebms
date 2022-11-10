# Source File: identity_recovery_test.exs
# Location:    musebms/components/system/msbms_syst_authentication/test/identity_recovery_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule IdentityRecoveryTest do
  use AuthenticationTestCase, async: true

  import Ecto.Query

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl

  alias MsbmsSystDatastore.DbTypes

  test "Can successfully Request Identity Recovery" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("identity_recovery_request_test_accnt")

    # Note that the DateTime comparisons are given a generous tolerance of
    # +/- 30 seconds since we really can't test an exact value.  The tolerance
    # is almost certainly unnecessarily wide, but small enough that any passing
    # value would be sufficient for the expiration business requirement.

    # default

    start_time = DateTime.utc_now()

    expires_start_time = DateTime.add(start_time, 24 * 60 * 60 - 30)
    expires_end_time = DateTime.add(start_time, 24 * 60 * 60 + 30)

    expires_datetime_range = %DbTypes.DateTimeRange{
      lower: expires_start_time,
      upper: expires_end_time
    }

    assert {:ok, recovery_identity} =
             Impl.Identity.Recovery.request_credential_recovery(access_account_id, [])

    assert :rcl = DbTypes.compare(recovery_identity.identity_expires, expires_datetime_range)

    assert String.length(recovery_identity.account_identifier) == 40

    :deleted =
      Impl.Identity.delete_identity(recovery_identity, "identity_types_sysdef_password_recovery")

    # expiration_hours

    start_time = DateTime.utc_now()

    hours_before_expire = :rand.uniform(60)

    expires_start_time = DateTime.add(start_time, hours_before_expire * 60 * 60 - 30)
    expires_end_time = DateTime.add(start_time, hours_before_expire * 60 * 60 + 30)

    expires_datetime_range = %DbTypes.DateTimeRange{
      lower: expires_start_time,
      upper: expires_end_time
    }

    assert {:ok, recovery_identity} =
             Impl.Identity.Recovery.request_credential_recovery(access_account_id,
               expiration_hours: hours_before_expire
             )

    assert :rcl = DbTypes.compare(recovery_identity.identity_expires, expires_datetime_range)

    assert String.length(recovery_identity.account_identifier) == 40

    :deleted =
      Impl.Identity.delete_identity(recovery_identity, "identity_types_sysdef_password_recovery")

    # identity_token_length

    start_time = DateTime.utc_now()

    expires_start_time = DateTime.add(start_time, 24 * 60 * 60 - 30)
    expires_end_time = DateTime.add(start_time, 24 * 60 * 60 + 30)

    expires_datetime_range = %DbTypes.DateTimeRange{
      lower: expires_start_time,
      upper: expires_end_time
    }

    token_length_override = :rand.uniform(60) + 10

    assert {:ok, recovery_identity} =
             Impl.Identity.Recovery.request_credential_recovery(access_account_id,
               identity_token_length: token_length_override
             )

    assert :rcl = DbTypes.compare(recovery_identity.identity_expires, expires_datetime_range)

    assert String.length(recovery_identity.account_identifier) == token_length_override

    :deleted =
      Impl.Identity.delete_identity(recovery_identity, "identity_types_sysdef_password_recovery")

    # identity_tokens

    start_time = DateTime.utc_now()

    expires_start_time = DateTime.add(start_time, 24 * 60 * 60 - 30)
    expires_end_time = DateTime.add(start_time, 24 * 60 * 60 + 30)

    expires_datetime_range = %DbTypes.DateTimeRange{
      lower: expires_start_time,
      upper: expires_end_time
    }

    assert {:ok, recovery_identity} =
             Impl.Identity.Recovery.request_credential_recovery(access_account_id,
               identity_tokens: 'ABC'
             )

    assert :rcl = DbTypes.compare(recovery_identity.identity_expires, expires_datetime_range)

    assert String.length(recovery_identity.account_identifier) == 40

    assert not (recovery_identity.account_identifier =~ ~r/[^A-C]/)

    :deleted =
      Impl.Identity.delete_identity(recovery_identity, "identity_types_sysdef_password_recovery")
  end

  test "Can test if Access Account is recoverable" do
    {:ok, recoverable_access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name(
        "identity_recovery_is_recoverable_test_accnt"
      )

    assert :ok =
             Impl.Identity.Recovery.access_account_credential_recoverable!(
               recoverable_access_account_id
             )

    {:ok, no_pwd_access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("identity_recovery_no_password_test_accnt")

    assert :not_found =
             Impl.Identity.Recovery.access_account_credential_recoverable!(
               no_pwd_access_account_id
             )

    {:ok, existing_access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name(
        "identity_recovery_existing_recovery_test_accnt"
      )

    assert :existing_recovery =
             Impl.Identity.Recovery.access_account_credential_recoverable!(
               existing_access_account_id
             )
  end

  test "Can identify Owned Access Account" do
    recovery_identity =
      from(
        i in Data.SystIdentities,
        join: ei in assoc(i, :identity_type),
        join: aa in assoc(i, :access_account),
        where:
          aa.internal_name == "identity_recovery_identify_test_accnt" and
            ei.internal_name == "identity_types_sysdef_password_recovery",
        preload: [access_account: aa]
      )
      |> MsbmsSystDatastore.one!()

    recovery_identity_id = recovery_identity.id

    assert %Data.SystIdentities{id: ^recovery_identity_id} =
             Impl.Identity.Recovery.identify_access_account(
               recovery_identity.account_identifier,
               recovery_identity.access_account.owning_owner_id
             )

    assert Impl.Identity.Recovery.identify_access_account(
             recovery_identity.account_identifier,
             nil
           ) == nil
  end

  test "Can identify Unowned Access Account" do
    recovery_identity =
      from(
        i in Data.SystIdentities,
        join: ei in assoc(i, :identity_type),
        join: aa in assoc(i, :access_account),
        where:
          aa.internal_name == "identity_recovery_identify_unowned_test_accnt" and
            ei.internal_name == "identity_types_sysdef_password_recovery",
        preload: [access_account: aa]
      )
      |> MsbmsSystDatastore.one!()

    recovery_identity_id = recovery_identity.id

    assert %Data.SystIdentities{id: ^recovery_identity_id} =
             Impl.Identity.Recovery.identify_access_account(
               recovery_identity.account_identifier,
               nil
             )
  end

  test "Can confirm Recovery" do
    # The DateTime.truncate/2 call is needed here since DateTime.utc_now/0
    # produces a timestamp with a greater resolution than that returned from the
    # database. This can lead to validation_time seemingly being later than the
    # record validated time which in this test isn't possible.

    target_identity =
      from(
        aa in Data.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_recovery_confirm_test_accnt" and
            ei.internal_name == "identity_types_sysdef_password_recovery"
      )
      |> MsbmsSystDatastore.one!()

    assert :ok = Impl.Identity.Recovery.confirm_credential_recovery(target_identity)

    no_identity =
      from(
        aa in Data.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_recovery_confirm_test_accnt" and
            ei.internal_name == "identity_types_sysdef_password_recovery"
      )
      |> MsbmsSystDatastore.one()

    assert no_identity == nil
  end

  test "Can revoke Recovery Identity" do
    target_identity =
      from(
        aa in Data.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_recovery_revoke_test_accnt" and
            ei.internal_name == "identity_types_sysdef_password_recovery"
      )
      |> MsbmsSystDatastore.one!()

    assert :ok = Impl.Identity.Recovery.revoke_credential_recovery(target_identity)

    no_identity =
      from(
        aa in Data.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_recovery_revoke_test_accnt" and
            ei.internal_name == "identity_types_sysdef_password_recovery"
      )
      |> MsbmsSystDatastore.one()

    assert no_identity == nil
  end
end
