# Source File: identity_api_token_test.exs
# Location:    musebms/components/system/mscmp_syst_authn/test/identity_api_token_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule IdentityApiTokenTest do
  use AuthenticationTestCase, async: true

  import Ecto.Query

  alias MscmpSystAuthn.Data
  alias MscmpSystAuthn.Impl

  @moduletag :capture_log

  test "Can create API Token Identity" do
    {:ok, access_account_id} =
      Impl.AccessAccount.get_access_account_id_by_name("identity_api_token_create_test_accnt")

    # Default Options
    assert {:ok, default_identity} =
             Impl.Identity.ApiToken.create_identity(access_account_id, nil)

    assert %Data.SystIdentities{validated: val_date, account_identifier: identifier} =
             default_identity

    assert DateTime.compare(val_date, DateTime.utc_now()) in [:eq, :lt]

    assert String.length(identifier) == 20

    :deleted = Impl.Identity.delete_identity(default_identity.id, "identity_types_sysdef_api")

    # Specific api_token value
    assert {:ok, specific_token_identity} =
             Impl.Identity.ApiToken.create_identity(access_account_id, "This Is A Test")

    assert %Data.SystIdentities{account_identifier: identifier} = specific_token_identity

    assert identifier == "This Is A Test"

    :deleted =
      Impl.Identity.delete_identity(specific_token_identity.id, "identity_types_sysdef_api")

    # create_validated
    assert {:ok, not_validated_identity} =
             Impl.Identity.ApiToken.create_identity(access_account_id, nil,
               create_validated: false
             )

    assert %Data.SystIdentities{validated: val_date, account_identifier: identifier} =
             not_validated_identity

    assert val_date == nil

    assert String.length(identifier) == 20

    :deleted =
      Impl.Identity.delete_identity(not_validated_identity.id, "identity_types_sysdef_api")

    # identity_token_length
    assert {:ok, token_length_identity} =
             Impl.Identity.ApiToken.create_identity(access_account_id, nil,
               identity_token_length: 40
             )

    assert %Data.SystIdentities{validated: val_date, account_identifier: identifier} =
             token_length_identity

    assert DateTime.compare(val_date, DateTime.utc_now()) in [:eq, :lt]

    assert String.length(identifier) == 40

    :deleted =
      Impl.Identity.delete_identity(token_length_identity.id, "identity_types_sysdef_api")

    # identity_tokens
    assert {:ok, tokens_identity} =
             Impl.Identity.ApiToken.create_identity(access_account_id, nil, identity_tokens: 'ABC')

    assert %Data.SystIdentities{validated: val_date, account_identifier: identifier} =
             tokens_identity

    assert DateTime.compare(val_date, DateTime.utc_now()) in [:eq, :lt]

    assert not (identifier =~ ~r/[^A-C]/)

    :deleted = Impl.Identity.delete_identity(tokens_identity.id, "identity_types_sysdef_api")

    # external_name
    assert {:ok, ext_name_identity} =
             Impl.Identity.ApiToken.create_identity(access_account_id, nil,
               external_name: "API Token Test"
             )

    assert %Data.SystIdentities{validated: val_date, external_name: external_name} =
             ext_name_identity

    assert DateTime.compare(val_date, DateTime.utc_now()) in [:eq, :lt]

    assert "API Token Test" = external_name

    :deleted = Impl.Identity.delete_identity(ext_name_identity.id, "identity_types_sysdef_api")
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
            ei.internal_name == "identity_types_sysdef_api"
      )
      |> MscmpSystDb.one!()

    assert %Data.SystIdentities{} =
             Impl.Identity.ApiToken.identify_access_account(
               target.account_identifier,
               target.owning_owner_id
             )

    assert Impl.Identity.ApiToken.identify_access_account(target.account_identifier, nil) == nil
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
            ei.internal_name == "identity_types_sysdef_api"
      )
      |> MscmpSystDb.one!()

    assert %Data.SystIdentities{} =
             Impl.Identity.ApiToken.identify_access_account(
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
            ei.internal_name == "identity_types_sysdef_api"
      )
      |> MscmpSystDb.one!()

    assert Impl.Identity.ApiToken.identify_access_account(bad_target.account_identifier, nil) ==
             nil
  end

  test "Can update Identity External Name by ID" do
    test_name = MscmpSystUtils.get_random_string(20)

    target =
      from(
        aa in Data.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: %{identity_id: i.id},
        where:
          aa.internal_name == "unowned_all_access" and
            ei.internal_name == "identity_types_sysdef_api"
      )
      |> MscmpSystDb.one!()

    assert %Data.SystIdentities{external_name: ^test_name} =
             Impl.Identity.ApiToken.update_identity_external_name(target.identity_id, test_name)
  end

  test "Can update Identity External Name" do
    test_name = MscmpSystUtils.get_random_string(20)

    target =
      from(
        aa in Data.SystAccessAccounts,
        join: i in assoc(aa, :identities),
        join: ei in assoc(i, :identity_type),
        select: i,
        where:
          aa.internal_name == "owned_all_access" and
            ei.internal_name == "identity_types_sysdef_api"
      )
      |> MscmpSystDb.one!()

    assert %Data.SystIdentities{external_name: ^test_name} =
             Impl.Identity.ApiToken.update_identity_external_name(target, test_name)
  end
end
