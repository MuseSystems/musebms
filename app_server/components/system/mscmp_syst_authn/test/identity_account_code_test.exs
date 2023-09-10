# Source File: identity_account_code_test.exs
# Location:    musebms/components/system/mscmp_syst_authn/test/identity_account_code_test.exs
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
  # credo:disable-for-this-file Credo.Check.Design.AliasUsage
  #
  # In the tests we'll be more permissive of failing this check for now.
  # In application code we should adhere to our configured checks.

  use AuthenticationTestCase, async: true

  import Ecto.Query

  alias MscmpSystAuthn.Impl

  @moduletag :capture_log

  test "Can create Account Code Identity" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("identity_account_code_create_test_accnt")

    # Default Options
    assert {:ok, default_identity} =
             Impl.Identity.AccountCode.create_identity(access_account_id, nil, [])

    assert %Msdata.SystIdentities{validated: val_date, account_identifier: identifier} =
             default_identity

    assert val_date != nil

    assert String.length(identifier) == 12

    :deleted = Impl.Identity.delete_identity(default_identity.id, "identity_types_sysdef_account")

    # Specific account_code value
    assert {:ok, specific_token_identity} =
             Impl.Identity.AccountCode.create_identity(access_account_id, "This Is A Test", [])

    assert %Msdata.SystIdentities{} = specific_token_identity

    assert specific_token_identity.account_identifier == "This Is A Test"

    :deleted =
      Impl.Identity.delete_identity(specific_token_identity.id, "identity_types_sysdef_account")

    # identity_token_length
    assert {:ok, token_length_identity} =
             Impl.Identity.AccountCode.create_identity(access_account_id, nil,
               identity_token_length: 40
             )

    assert %Msdata.SystIdentities{validated: val_date, account_identifier: identifier} =
             token_length_identity

    assert val_date != nil

    assert String.length(identifier) == 40

    :deleted =
      Impl.Identity.delete_identity(token_length_identity.id, "identity_types_sysdef_account")

    # identity_tokens
    assert {:ok, tokens_identity} =
             Impl.Identity.AccountCode.create_identity(access_account_id, nil,
               identity_tokens: ~c"ABC"
             )

    assert %Msdata.SystIdentities{validated: val_date, account_identifier: identifier} =
             tokens_identity

    assert val_date != nil

    assert not (identifier =~ ~r/[^A-C]/)

    :deleted = Impl.Identity.delete_identity(tokens_identity.id, "identity_types_sysdef_account")
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
            ei.internal_name == "identity_types_sysdef_account"
      )
      |> MscmpSystDb.one!()

    assert %Msdata.SystIdentities{} =
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
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: %{account_identifier: i.account_identifier},
        where:
          aa.internal_name == "unowned_all_access" and
            ei.internal_name == "identity_types_sysdef_account"
      )
      |> MscmpSystDb.one!()

    assert %Msdata.SystIdentities{} =
             Impl.Identity.AccountCode.identify_access_account(
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
            ei.internal_name == "identity_types_sysdef_account"
      )
      |> MscmpSystDb.one!()

    assert Impl.Identity.AccountCode.identify_access_account(bad_target.account_identifier, nil) ==
             nil
  end

  test "Can reset Account Code for Access Account" do
    target =
      from(
        aa in Msdata.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "unowned_all_access" and
            ei.internal_name == "identity_types_sysdef_account"
      )
      |> MscmpSystDb.one!()

    # Default Options
    assert {:ok, %Msdata.SystIdentities{} = default_identity} =
             Impl.Identity.AccountCode.reset_identity_for_access_account_id(
               target.access_account_id,
               []
             )

    assert String.length(default_identity.account_identifier) == 12
    assert target.account_identifier != default_identity.account_identifier

    # identity_token_length
    assert {:ok, %Msdata.SystIdentities{} = token_length_identity} =
             Impl.Identity.AccountCode.reset_identity_for_access_account_id(
               target.access_account_id,
               identity_token_length: 40
             )

    assert String.length(token_length_identity.account_identifier) == 40
    assert default_identity.account_identifier != token_length_identity.account_identifier

    # identity_tokens
    assert {:ok, %Msdata.SystIdentities{} = tokens_identity} =
             Impl.Identity.AccountCode.reset_identity_for_access_account_id(
               target.access_account_id,
               identity_tokens: ~c"ABC"
             )

    assert String.length(tokens_identity.account_identifier) == 12
    assert token_length_identity.account_identifier != tokens_identity.account_identifier
    assert not (tokens_identity.account_identifier =~ ~r/[^A-C]/)
  end

  test "Can get existing Account Code by Access Account ID" do
    {:ok, found_access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("owned_all_access")

    assert {:ok, %Msdata.SystIdentities{}} =
             Impl.Identity.AccountCode.get_account_code_by_access_account_id(
               found_access_account_id
             )

    {:ok, no_code_access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("identity_account_code_no_code_test_accnt")

    assert {:ok, :not_found} =
             Impl.Identity.AccountCode.get_account_code_by_access_account_id(
               no_code_access_account_id
             )
  end
end
