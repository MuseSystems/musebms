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

  test "Request Identity Recovery by target Identity ID" do
    target_identity =
      from(
        aa in Data.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_recovery_request_test_accnt" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MsbmsSystDatastore.one!()

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
             Impl.Identity.Recovery.request_identity_recovery(target_identity.id, [])

    assert :rcl = DbTypes.compare(recovery_identity.identity_expires, expires_datetime_range)

    assert String.length(recovery_identity.account_identifier) == 40

    :ok = Impl.Identity.delete_identity(recovery_identity)

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
             Impl.Identity.Recovery.request_identity_recovery(target_identity.id,
               expiration_hours: hours_before_expire
             )

    assert :rcl = DbTypes.compare(recovery_identity.identity_expires, expires_datetime_range)

    assert String.length(recovery_identity.account_identifier) == 40

    :ok = Impl.Identity.delete_identity(recovery_identity)

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
             Impl.Identity.Recovery.request_identity_recovery(target_identity.id,
               identity_token_length: token_length_override
             )

    assert :rcl = DbTypes.compare(recovery_identity.identity_expires, expires_datetime_range)

    assert String.length(recovery_identity.account_identifier) == token_length_override

    :ok = Impl.Identity.delete_identity(recovery_identity)

    # identity_tokens

    start_time = DateTime.utc_now()

    expires_start_time = DateTime.add(start_time, 24 * 60 * 60 - 30)
    expires_end_time = DateTime.add(start_time, 24 * 60 * 60 + 30)

    expires_datetime_range = %DbTypes.DateTimeRange{
      lower: expires_start_time,
      upper: expires_end_time
    }

    assert {:ok, recovery_identity} =
             Impl.Identity.Recovery.request_identity_recovery(target_identity.id,
               identity_tokens: 'ABC'
             )

    assert :rcl = DbTypes.compare(recovery_identity.identity_expires, expires_datetime_range)

    assert String.length(recovery_identity.account_identifier) == 40

    assert not (recovery_identity.account_identifier =~ ~r/[^A-C]/)

    :ok = Impl.Identity.delete_identity(recovery_identity)
  end

  test "Request Identity Recovery by target Identity" do
    target_identity =
      from(
        aa in Data.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_recovery_request_test_accnt" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MsbmsSystDatastore.one!()

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
             Impl.Identity.Recovery.request_identity_recovery(target_identity, [])

    assert :rcl = DbTypes.compare(recovery_identity.identity_expires, expires_datetime_range)

    assert String.length(recovery_identity.account_identifier) == 40

    :ok = Impl.Identity.delete_identity(recovery_identity)

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
             Impl.Identity.Recovery.request_identity_recovery(target_identity,
               expiration_hours: hours_before_expire
             )

    assert :rcl = DbTypes.compare(recovery_identity.identity_expires, expires_datetime_range)

    assert String.length(recovery_identity.account_identifier) == 40

    :ok = Impl.Identity.delete_identity(recovery_identity)

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
             Impl.Identity.Recovery.request_identity_recovery(target_identity,
               identity_token_length: token_length_override
             )

    assert :rcl = DbTypes.compare(recovery_identity.identity_expires, expires_datetime_range)

    assert String.length(recovery_identity.account_identifier) == token_length_override

    :ok = Impl.Identity.delete_identity(recovery_identity)

    # identity_tokens

    start_time = DateTime.utc_now()

    expires_start_time = DateTime.add(start_time, 24 * 60 * 60 - 30)
    expires_end_time = DateTime.add(start_time, 24 * 60 * 60 + 30)

    expires_datetime_range = %DbTypes.DateTimeRange{
      lower: expires_start_time,
      upper: expires_end_time
    }

    assert {:ok, recovery_identity} =
             Impl.Identity.Recovery.request_identity_recovery(target_identity,
               identity_tokens: 'ABC'
             )

    assert :rcl = DbTypes.compare(recovery_identity.identity_expires, expires_datetime_range)

    assert String.length(recovery_identity.account_identifier) == 40

    assert not (recovery_identity.account_identifier =~ ~r/[^A-C]/)

    :ok = Impl.Identity.delete_identity(recovery_identity)
  end

  test "Identify Owned Access Account" do
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

  test "Identify Unowned Access Account" do
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

  test "Can Confirm Recovery" do
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

    assert :ok = Impl.Identity.Recovery.confirm_identity_recovery(target_identity)

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

  test "Can Revoke Recovery Identity" do
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

    assert :ok = Impl.Identity.Recovery.revoke_identity_recovery(target_identity)

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
