# Source File: identity_validation_test.exs
# Location:    musebms/components/system/mscmp_syst_authn/test/identity_validation_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule IdentityValidationTest do
  # credo:disable-for-this-file Credo.Check.Design.AliasUsage
  #
  # In the tests we'll be more permissive of failing this check for now.
  # In application code we should adhere to our configured checks.

  use AuthenticationTestCase, async: true

  import Ecto.Query

  alias MscmpSystAuthn.Impl

  alias MscmpSystDb.DbTypes

  @moduletag :capture_log

  test "Request Identity Validation by target Identity ID" do
    target_identity =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_validation_request_test_accnt" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MscmpSystDb.one!()

    # Note that the DateTime comparisons are given a generous tolerance of
    # +/- 30 seconds since we really can't test an exact value.  The tolerance
    # is almost certainly unnecessarily wide, but small enough that any passing
    # value would be sufficient for the expiration business requirement.

    # default

    requested_start_time = DateTime.add(DateTime.utc_now(), -30)
    requested_end_time = DateTime.add(requested_start_time, 60)

    requested_datetime_range = %DbTypes.DateTimeRange{
      lower: requested_start_time,
      upper: requested_end_time
    }

    expires_start_time = DateTime.add(requested_start_time, 24 * 60 * 60)
    expires_end_time = DateTime.add(requested_end_time, 24 * 60 * 60)

    expires_datetime_range = %DbTypes.DateTimeRange{
      lower: expires_start_time,
      upper: expires_end_time
    }

    assert {:ok, validation_identity} =
             Impl.Identity.Validation.request_identity_validation(target_identity.id, [])

    updated_target_identity =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_validation_request_test_accnt" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MscmpSystDb.one!()

    assert {:ok, false} = Impl.Identity.identity_validated?(updated_target_identity)

    assert :rcl =
             DbTypes.compare(
               updated_target_identity.validation_requested,
               requested_datetime_range
             )

    assert :rcl = DbTypes.compare(validation_identity.identity_expires, expires_datetime_range)

    assert String.length(validation_identity.account_identifier) == 40

    :deleted =
      Impl.Identity.delete_identity(validation_identity, "identity_types_sysdef_validation")

    # expiration_hours

    requested_start_time = DateTime.add(DateTime.utc_now(), -30)
    requested_end_time = DateTime.add(requested_start_time, 60)

    requested_datetime_range = %DbTypes.DateTimeRange{
      lower: requested_start_time,
      upper: requested_end_time
    }

    hours_before_expire = :rand.uniform(60)

    expires_start_time = DateTime.add(requested_start_time, hours_before_expire * 60 * 60)
    expires_end_time = DateTime.add(requested_end_time, hours_before_expire * 60 * 60)

    expires_datetime_range = %DbTypes.DateTimeRange{
      lower: expires_start_time,
      upper: expires_end_time
    }

    assert {:ok, validation_identity} =
             Impl.Identity.Validation.request_identity_validation(target_identity.id,
               expiration_hours: hours_before_expire
             )

    updated_target_identity =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_validation_request_test_accnt" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MscmpSystDb.one!()

    assert {:ok, false} = Impl.Identity.identity_validated?(updated_target_identity)

    assert :rcl =
             DbTypes.compare(
               updated_target_identity.validation_requested,
               requested_datetime_range
             )

    assert :rcl = DbTypes.compare(validation_identity.identity_expires, expires_datetime_range)

    assert String.length(validation_identity.account_identifier) == 40

    :deleted =
      Impl.Identity.delete_identity(validation_identity, "identity_types_sysdef_validation")

    # identity_token_length

    requested_start_time = DateTime.add(DateTime.utc_now(), -30)
    requested_end_time = DateTime.add(requested_start_time, 60)

    requested_datetime_range = %DbTypes.DateTimeRange{
      lower: requested_start_time,
      upper: requested_end_time
    }

    expires_start_time = DateTime.add(requested_start_time, 24 * 60 * 60)
    expires_end_time = DateTime.add(requested_end_time, 24 * 60 * 60)

    expires_datetime_range = %DbTypes.DateTimeRange{
      lower: expires_start_time,
      upper: expires_end_time
    }

    token_length_override = :rand.uniform(60) + 10

    assert {:ok, validation_identity} =
             Impl.Identity.Validation.request_identity_validation(target_identity.id,
               identity_token_length: token_length_override
             )

    updated_target_identity =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_validation_request_test_accnt" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MscmpSystDb.one!()

    assert {:ok, false} = Impl.Identity.identity_validated?(updated_target_identity)

    assert :rcl =
             DbTypes.compare(
               updated_target_identity.validation_requested,
               requested_datetime_range
             )

    assert :rcl = DbTypes.compare(validation_identity.identity_expires, expires_datetime_range)

    assert String.length(validation_identity.account_identifier) == token_length_override

    :deleted =
      Impl.Identity.delete_identity(validation_identity, "identity_types_sysdef_validation")

    # identity_tokens

    requested_start_time = DateTime.add(DateTime.utc_now(), -30)
    requested_end_time = DateTime.add(requested_start_time, 60)

    requested_datetime_range = %DbTypes.DateTimeRange{
      lower: requested_start_time,
      upper: requested_end_time
    }

    expires_start_time = DateTime.add(requested_start_time, 24 * 60 * 60)
    expires_end_time = DateTime.add(requested_end_time, 24 * 60 * 60)

    expires_datetime_range = %DbTypes.DateTimeRange{
      lower: expires_start_time,
      upper: expires_end_time
    }

    assert {:ok, validation_identity} =
             Impl.Identity.Validation.request_identity_validation(target_identity.id,
               identity_tokens: ~c"ABC"
             )

    updated_target_identity =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_validation_request_test_accnt" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MscmpSystDb.one!()

    assert {:ok, false} = Impl.Identity.identity_validated?(updated_target_identity)

    assert :rcl =
             DbTypes.compare(
               updated_target_identity.validation_requested,
               requested_datetime_range
             )

    assert :rcl = DbTypes.compare(validation_identity.identity_expires, expires_datetime_range)

    assert String.length(validation_identity.account_identifier) == 40

    assert not (validation_identity.account_identifier =~ ~r/[^A-C]/)

    :deleted =
      Impl.Identity.delete_identity(validation_identity, "identity_types_sysdef_validation")
  end

  test "Request Identity Validation by target Identity" do
    target_identity =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_validation_request_test_accnt" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MscmpSystDb.one!()

    # Note that the DateTime comparisons are given a generous tolerance of
    # +/- 30 seconds since we really can't test an exact value.  The tolerance
    # is almost certainly unnecessarily wide, but small enough that any passing
    # value would be sufficient for the expiration business requirement.

    # default

    requested_start_time = DateTime.add(DateTime.utc_now(), -30)
    requested_end_time = DateTime.add(requested_start_time, 60)

    requested_datetime_range = %DbTypes.DateTimeRange{
      lower: requested_start_time,
      upper: requested_end_time
    }

    expires_start_time = DateTime.add(requested_start_time, 24 * 60 * 60)
    expires_end_time = DateTime.add(requested_end_time, 24 * 60 * 60)

    expires_datetime_range = %DbTypes.DateTimeRange{
      lower: expires_start_time,
      upper: expires_end_time
    }

    assert {:ok, validation_identity} =
             Impl.Identity.Validation.request_identity_validation(target_identity, [])

    updated_target_identity =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_validation_request_test_accnt" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MscmpSystDb.one!()

    assert {:ok, false} = Impl.Identity.identity_validated?(updated_target_identity)

    assert :rcl =
             DbTypes.compare(
               updated_target_identity.validation_requested,
               requested_datetime_range
             )

    assert :rcl = DbTypes.compare(validation_identity.identity_expires, expires_datetime_range)

    assert String.length(validation_identity.account_identifier) == 40

    :deleted =
      Impl.Identity.delete_identity(validation_identity, "identity_types_sysdef_validation")

    # expiration_hours

    requested_start_time = DateTime.add(DateTime.utc_now(), -30)
    requested_end_time = DateTime.add(requested_start_time, 60)

    requested_datetime_range = %DbTypes.DateTimeRange{
      lower: requested_start_time,
      upper: requested_end_time
    }

    expires_start_time = DateTime.add(requested_start_time, 48 * 60 * 60)
    expires_end_time = DateTime.add(requested_end_time, 48 * 60 * 60)

    expires_datetime_range = %DbTypes.DateTimeRange{
      lower: expires_start_time,
      upper: expires_end_time
    }

    assert {:ok, validation_identity} =
             Impl.Identity.Validation.request_identity_validation(updated_target_identity,
               expiration_hours: 48
             )

    updated_target_identity =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_validation_request_test_accnt" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MscmpSystDb.one!()

    assert {:ok, false} = Impl.Identity.identity_validated?(updated_target_identity)

    assert :rcl =
             DbTypes.compare(
               updated_target_identity.validation_requested,
               requested_datetime_range
             )

    assert :rcl = DbTypes.compare(validation_identity.identity_expires, expires_datetime_range)

    assert String.length(validation_identity.account_identifier) == 40

    :deleted =
      Impl.Identity.delete_identity(validation_identity, "identity_types_sysdef_validation")

    # identity_token_length

    requested_start_time = DateTime.add(DateTime.utc_now(), -30)
    requested_end_time = DateTime.add(requested_start_time, 60)

    requested_datetime_range = %DbTypes.DateTimeRange{
      lower: requested_start_time,
      upper: requested_end_time
    }

    expires_start_time = DateTime.add(requested_start_time, 24 * 60 * 60)
    expires_end_time = DateTime.add(requested_end_time, 24 * 60 * 60)

    expires_datetime_range = %DbTypes.DateTimeRange{
      lower: expires_start_time,
      upper: expires_end_time
    }

    assert {:ok, validation_identity} =
             Impl.Identity.Validation.request_identity_validation(updated_target_identity,
               identity_token_length: 20
             )

    updated_target_identity =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_validation_request_test_accnt" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MscmpSystDb.one!()

    assert {:ok, false} = Impl.Identity.identity_validated?(updated_target_identity)

    assert :rcl =
             DbTypes.compare(
               updated_target_identity.validation_requested,
               requested_datetime_range
             )

    assert :rcl = DbTypes.compare(validation_identity.identity_expires, expires_datetime_range)

    assert String.length(validation_identity.account_identifier) == 20

    :deleted =
      Impl.Identity.delete_identity(validation_identity, "identity_types_sysdef_validation")

    # identity_tokens

    requested_start_time = DateTime.add(DateTime.utc_now(), -30)
    requested_end_time = DateTime.add(requested_start_time, 60)

    requested_datetime_range = %DbTypes.DateTimeRange{
      lower: requested_start_time,
      upper: requested_end_time
    }

    expires_start_time = DateTime.add(requested_start_time, 24 * 60 * 60)
    expires_end_time = DateTime.add(requested_end_time, 24 * 60 * 60)

    expires_datetime_range = %DbTypes.DateTimeRange{
      lower: expires_start_time,
      upper: expires_end_time
    }

    assert {:ok, validation_identity} =
             Impl.Identity.Validation.request_identity_validation(updated_target_identity,
               identity_tokens: ~c"ABC"
             )

    updated_target_identity =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_validation_request_test_accnt" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MscmpSystDb.one!()

    assert {:ok, false} = Impl.Identity.identity_validated?(updated_target_identity)

    assert :rcl =
             DbTypes.compare(
               updated_target_identity.validation_requested,
               requested_datetime_range
             )

    assert :rcl = DbTypes.compare(validation_identity.identity_expires, expires_datetime_range)

    assert String.length(validation_identity.account_identifier) == 40

    assert not (validation_identity.account_identifier =~ ~r/[^A-C]/)

    :deleted =
      Impl.Identity.delete_identity(validation_identity, "identity_types_sysdef_validation")
  end

  test "Identify Owned Access Account" do
    validation_identity =
      from(
        i in Msdata.SystIdentities,
        join: ei in assoc(i, :identity_type),
        join: aa in assoc(i, :access_account),
        where:
          aa.internal_name == "identity_validation_identify_test_accnt" and
            ei.internal_name == "identity_types_sysdef_validation",
        preload: [access_account: aa]
      )
      |> MscmpSystDb.one!()

    validation_identity_id = validation_identity.id

    assert %Msdata.SystIdentities{id: ^validation_identity_id} =
             Impl.Identity.Validation.identify_access_account(
               validation_identity.account_identifier,
               validation_identity.access_account.owning_owner_id
             )

    assert Impl.Identity.Validation.identify_access_account(
             validation_identity.account_identifier,
             nil
           ) == nil
  end

  test "Identify Unowned Access Account" do
    validation_identity =
      from(
        i in Msdata.SystIdentities,
        join: ei in assoc(i, :identity_type),
        join: aa in assoc(i, :access_account),
        where:
          aa.internal_name == "identity_validation_identify_unowned_test_accnt" and
            ei.internal_name == "identity_types_sysdef_validation",
        preload: [access_account: aa]
      )
      |> MscmpSystDb.one!()

    validation_identity_id = validation_identity.id

    assert %Msdata.SystIdentities{id: ^validation_identity_id} =
             Impl.Identity.Validation.identify_access_account(
               validation_identity.account_identifier,
               nil
             )
  end

  test "Can Confirm Validation for Identity" do
    # The DateTime.truncate/2 call is needed here since DateTime.utc_now/0
    # produces a timestamp with a greater resolution than that returned from the
    # database. This can lead to validation_time seemingly being later than the
    # record validated time which in this test isn't possible.

    validation_time = DateTime.utc_now() |> DateTime.truncate(:second)

    target_identity =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_validation_confirm_test_accnt" and
            ei.internal_name == "identity_types_sysdef_validation"
      )
      |> MscmpSystDb.one!()

    assert {:ok, validated_identity} =
             Impl.Identity.Validation.confirm_identity_validation(target_identity)

    assert DateTime.compare(validated_identity.validated, validation_time) in [:gt, :eq]

    no_identity =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_validation_confirm_test_accnt" and
            ei.internal_name == "identity_types_sysdef_validation"
      )
      |> MscmpSystDb.one()

    assert no_identity == nil
  end

  test "Can Revoke Validation for Identity" do
    target_identity =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_validation_revoke_test_accnt" and
            ei.internal_name == "identity_types_sysdef_validation"
      )
      |> MscmpSystDb.one!()

    assert {:ok, revoked_identity} =
             Impl.Identity.Validation.revoke_identity_validation(target_identity)

    assert revoked_identity.validated == nil
    assert revoked_identity.validation_requested == nil

    no_identity =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "identity_validation_revoke_test_accnt" and
            ei.internal_name == "identity_types_sysdef_validation"
      )
      |> MscmpSystDb.one()

    assert no_identity == nil
  end

  test "Can get Validation Identity for Identity ID" do
    validation_identity_id =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i.id,
        where:
          aa.internal_name == "identity_validation_identify_test_accnt" and
            ei.internal_name == "identity_types_sysdef_validation"
      )
      |> MscmpSystDb.one!()

    target_identity_id =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i.id,
        where:
          aa.internal_name == "identity_validation_identify_test_accnt" and
            ei.internal_name == "identity_types_sysdef_email"
      )
      |> MscmpSystDb.one!()

    assert {:ok, %Msdata.SystIdentities{id: ^validation_identity_id}} =
             Impl.Identity.Validation.get_validation_identity_for_identity_id(target_identity_id)
  end
end
