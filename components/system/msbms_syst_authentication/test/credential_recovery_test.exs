# Source File: credential_recovery_test.exs
# Location:    musebms/components/system/msbms_syst_authentication/test/credential_recovery_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule CredentialRecoveryTest do
  use AuthenticationTestCase, async: true

  import Ecto.Query

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl

  test "Can confirm Recovery Credential" do
    test_account = get_account_data("credential_recovery_confirm_test_accnt")

    assert {:confirmed, []} =
             Impl.Credential.Recovery.confirm_credential(
               test_account.access_account_id,
               test_account.identity_id,
               "xSU8rjv2JvFwoQF4C6FIoveFylNYwHYhv6myz7lZRkrrJL9i"
             )

    assert {:wrong_credential, []} =
             Impl.Credential.Recovery.confirm_credential(
               test_account.access_account_id,
               test_account.identity_id,
               MsbmsSystUtils.get_random_string(48)
             )

    assert {:no_credential, []} =
             Impl.Credential.Recovery.confirm_credential(
               test_account.access_account_id,
               nil,
               "xSU8rjv2JvFwoQF4C6FIoveFylNYwHYhv6myz7lZRkrrJL9i"
             )
  end

  test "Can Insert new Recovery Credentials" do
    # Default
    test_account = get_account_data("credential_recovery_create1_test_accnt")

    assert {:ok, returned_credential} =
             Impl.Credential.Recovery.set_credential(
               test_account.access_account_id,
               test_account.identity_id
             )

    assert String.length(returned_credential) == 40

    # Specified Token
    test_account = get_account_data("credential_recovery_create2_test_accnt")

    specified_token = MsbmsSystUtils.get_random_string(40)

    assert {:ok, ^specified_token} =
             Impl.Credential.Recovery.set_credential(
               test_account.access_account_id,
               test_account.identity_id,
               specified_token
             )

    # credential_token_length
    test_account = get_account_data("credential_recovery_create3_test_accnt")

    assert {:ok, returned_credential} =
             Impl.Credential.Recovery.set_credential(
               test_account.access_account_id,
               test_account.identity_id,
               nil,
               credential_token_length: 20
             )

    assert String.length(returned_credential) == 20

    # credential_tokens
    test_account = get_account_data("credential_recovery_create4_test_accnt")

    assert {:ok, returned_credential} =
             Impl.Credential.Recovery.set_credential(
               test_account.access_account_id,
               test_account.identity_id,
               nil,
               credential_tokens: 'XYZ'
             )

    assert String.length(returned_credential) == 40

    assert not (returned_credential =~ ~r/[^X-Z]/)
  end

  test "Can retrieve a Recovery Credential record" do
    test_account = get_account_data("credential_recovery_retrieval_test_accnt")

    assert %Data.SystCredentials{} =
             Impl.Credential.Recovery.get_credential_record(
               test_account.access_account_id,
               test_account.identity_id
             )
  end

  test "Cannot replace a Recovery Credential record" do
    test_account = get_account_data("credential_recovery_retrieval_test_accnt")

    assert {:error, _} =
             Impl.Credential.Recovery.set_credential(
               test_account.access_account_id,
               test_account.identity_id
             )
  end

  test "Can delete Recovery Credential record by ID" do
    test_account = get_account_data("credential_recovery_delete_id_test_accnt")

    cred_record =
      Impl.Credential.Recovery.get_credential_record(
        test_account.access_account_id,
        test_account.identity_id
      )

    assert :ok = Impl.Credential.Recovery.delete_credential(cred_record.id)
  end

  test "Can delete Recovery Credential record" do
    test_account = get_account_data("credential_recovery_delete_test_accnt")

    cred_record =
      Impl.Credential.Recovery.get_credential_record(
        test_account.access_account_id,
        test_account.identity_id
      )

    assert :ok = Impl.Credential.Recovery.delete_credential(cred_record)
  end

  defp get_account_data(access_account_name) do
    from(aa in Data.SystAccessAccounts,
      join: i in assoc(aa, :identities),
      join: ei in assoc(i, :identity_type),
      select: %{access_account_id: aa.id, identity_id: i.id},
      where:
        aa.internal_name == ^access_account_name and
          ei.internal_name == "identity_types_sysdef_password_recovery"
    )
    |> MsbmsSystDatastore.one!()
  end
end