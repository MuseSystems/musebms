# Source File: identity_account_code_test.exs
# Location:    musebms/components/system/msbms_syst_authentication/test/identity_account_code_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule IdentityAccountCodeTest do
  use AuthenticationTestCase, async: true

  import Ecto.Query

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl

  test "Can create Account Code Identity" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("identity_account_code_create_test_accnt")

    # Default Options
    assert default_identity = Impl.Identity.AccountCode.create_identity(access_account_id, nil)

    assert %Data.SystIdentities{validated: val_date, account_identifier: identifier} =
             default_identity

    assert DateTime.compare(val_date, DateTime.utc_now()) in [:eq, :lt]

    assert String.length(identifier) == 12

    :ok = Impl.Identity.delete_identity(default_identity.id)

    # Specific account_code value
    assert specific_token_identity =
             Impl.Identity.AccountCode.create_identity(access_account_id, "This Is A Test")

    assert %Data.SystIdentities{} = specific_token_identity

    assert specific_token_identity.account_identifier == "This Is A Test"

    :ok = Impl.Identity.delete_identity(specific_token_identity.id)

    # create_validated
    assert not_validated_identity =
             Impl.Identity.AccountCode.create_identity(access_account_id, nil,
               create_validated: false
             )

    assert %Data.SystIdentities{validated: val_date, account_identifier: identifier} =
             not_validated_identity

    assert val_date == nil

    assert String.length(identifier) == 12

    :ok = Impl.Identity.delete_identity(not_validated_identity.id)

    # identity_token_length
    assert token_length_identity =
             Impl.Identity.AccountCode.create_identity(access_account_id, nil,
               identity_token_length: 40
             )

    assert %Data.SystIdentities{validated: val_date, account_identifier: identifier} =
             token_length_identity

    assert DateTime.compare(val_date, DateTime.utc_now()) in [:eq, :lt]

    assert String.length(identifier) == 40

    :ok = Impl.Identity.delete_identity(token_length_identity.id)

    # identity_tokens
    assert tokens_identity =
             Impl.Identity.AccountCode.create_identity(access_account_id, nil,
               identity_tokens: 'ABC'
             )

    assert %Data.SystIdentities{validated: val_date, account_identifier: identifier} =
             tokens_identity

    assert DateTime.compare(val_date, DateTime.utc_now()) in [:eq, :lt]

    assert not (identifier =~ ~r/[^A-C]/)

    :ok = Impl.Identity.delete_identity(tokens_identity.id)
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
            ei.internal_name == "identity_types_sysdef_account"
      )
      |> MsbmsSystDatastore.one!()

    assert %Data.SystIdentities{} =
             Impl.Identity.AccountCode.identify_access_account(
               target.account_identifier,
               target.owning_owner_id
             )

    assert Impl.Identity.AccountCode.identify_access_account(target.account_identifier, nil) ==
             nil
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
            ei.internal_name == "identity_types_sysdef_account"
      )
      |> MsbmsSystDatastore.one!()

    assert %Data.SystIdentities{} =
             Impl.Identity.AccountCode.identify_access_account(
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
            ei.internal_name == "identity_types_sysdef_account"
      )
      |> MsbmsSystDatastore.one!()

    assert Impl.Identity.AccountCode.identify_access_account(bad_target.account_identifier, nil) ==
             nil
  end

  test "Can reset Account Code for Access Account" do
    target =
      from(
        aa in Data.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "unowned_all_access" and
            ei.internal_name == "identity_types_sysdef_account"
      )
      |> MsbmsSystDatastore.one!()

    # Default Options
    assert default_identity =
             Impl.Identity.AccountCode.reset_identity_for_access_account_id(
               target.access_account_id,
               []
             )

    assert %Data.SystIdentities{} = default_identity

    assert String.length(default_identity.account_identifier) == 12
    assert target.account_identifier != default_identity.account_identifier

    # identity_token_length
    assert token_length_identity =
             Impl.Identity.AccountCode.reset_identity_for_access_account_id(
               target.access_account_id,
               identity_token_length: 40
             )

    assert %Data.SystIdentities{} = token_length_identity

    assert String.length(token_length_identity.account_identifier) == 40
    assert default_identity.account_identifier != token_length_identity.account_identifier

    # identity_tokens
    assert tokens_identity =
             Impl.Identity.AccountCode.reset_identity_for_access_account_id(
               target.access_account_id,
               identity_tokens: 'ABC'
             )

    assert %Data.SystIdentities{} = tokens_identity

    assert String.length(tokens_identity.account_identifier) == 12
    assert token_length_identity.account_identifier != tokens_identity.account_identifier
    assert not (tokens_identity.account_identifier =~ ~r/[^A-C]/)
  end

  test "Can reset Account Code by Identity ID" do
    target =
      from(
        aa in Data.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "unowned_all_access" and
            ei.internal_name == "identity_types_sysdef_account"
      )
      |> MsbmsSystDatastore.one!()

    # Default Options
    assert default_identity = Impl.Identity.AccountCode.reset_identity(target.id, [])

    assert %Data.SystIdentities{} = default_identity

    assert String.length(default_identity.account_identifier) == 12
    assert target.account_identifier != default_identity.account_identifier

    # identity_token_length
    assert token_length_identity =
             Impl.Identity.AccountCode.reset_identity(default_identity.id,
               identity_token_length: 40
             )

    assert %Data.SystIdentities{} = token_length_identity

    assert String.length(token_length_identity.account_identifier) == 40
    assert default_identity.account_identifier != token_length_identity.account_identifier

    # identity_tokens
    assert tokens_identity =
             Impl.Identity.AccountCode.reset_identity(token_length_identity.id,
               identity_tokens: 'ABC'
             )

    assert %Data.SystIdentities{} = tokens_identity

    assert String.length(tokens_identity.account_identifier) == 12
    assert token_length_identity.account_identifier != tokens_identity.account_identifier
    assert not (tokens_identity.account_identifier =~ ~r/[^A-C]/)
  end

  test "Can reset Account Code by Identity" do
    target =
      from(
        aa in Data.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "unowned_all_access" and
            ei.internal_name == "identity_types_sysdef_account"
      )
      |> MsbmsSystDatastore.one!()

    # Default Options
    assert default_identity = Impl.Identity.AccountCode.reset_identity(target, [])

    assert %Data.SystIdentities{} = default_identity

    assert String.length(default_identity.account_identifier) == 12
    assert target.account_identifier != default_identity.account_identifier

    # identity_token_length
    assert token_length_identity =
             Impl.Identity.AccountCode.reset_identity(default_identity, identity_token_length: 40)

    assert %Data.SystIdentities{} = token_length_identity

    assert String.length(token_length_identity.account_identifier) == 40
    assert default_identity.account_identifier != token_length_identity.account_identifier

    # identity_tokens
    assert tokens_identity =
             Impl.Identity.AccountCode.reset_identity(token_length_identity,
               identity_tokens: 'ABC'
             )

    assert %Data.SystIdentities{} = tokens_identity

    assert String.length(tokens_identity.account_identifier) == 12
    assert token_length_identity.account_identifier != tokens_identity.account_identifier
    assert not (tokens_identity.account_identifier =~ ~r/[^A-C]/)
  end
end
