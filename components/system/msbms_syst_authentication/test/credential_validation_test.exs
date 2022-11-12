# Source File: credential_validation_test.exs
# Location:    musebms/components/system/msbms_syst_authentication/test/credential_validation_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule CredentialValidationTest do
  use AuthenticationTestCase, async: true

  import Ecto.Query

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl

  @moduletag :capture_log

  test "Can Confirm Validation Credential" do
    test_account = get_account_data("credential_validation_confirm_test_accnt")

    assert {:ok, {:confirmed, []}} =
             Impl.Credential.Validation.confirm_credential(
               test_account.access_account_id,
               test_account.identity_id,
               "G0yRRAHw8R4dMlo5E3C3mnfXzLCMggXJYwbphTkFNkWrYLJt"
             )

    assert {:ok, {:wrong_credential, []}} =
             Impl.Credential.Validation.confirm_credential(
               test_account.access_account_id,
               test_account.identity_id,
               MsbmsSystUtils.get_random_string(48)
             )

    assert {:ok, {:no_credential, []}} =
             Impl.Credential.Validation.confirm_credential(
               test_account.access_account_id,
               nil,
               "G0yRRAHw8R4dMlo5E3C3mnfXzLCMggXJYwbphTkFNkWrYLJt"
             )

    assert {:confirmed, []} =
             Impl.Credential.Validation.confirm_credential!(
               test_account.access_account_id,
               test_account.identity_id,
               "G0yRRAHw8R4dMlo5E3C3mnfXzLCMggXJYwbphTkFNkWrYLJt"
             )

    assert {:wrong_credential, []} =
             Impl.Credential.Validation.confirm_credential!(
               test_account.access_account_id,
               test_account.identity_id,
               MsbmsSystUtils.get_random_string(48)
             )

    assert {:no_credential, []} =
             Impl.Credential.Validation.confirm_credential!(
               test_account.access_account_id,
               nil,
               "G0yRRAHw8R4dMlo5E3C3mnfXzLCMggXJYwbphTkFNkWrYLJt"
             )
  end

  test "Can insert an Validation Credential record" do
    # Default
    test_account = get_account_data("credential_validation_create1_test_accnt")

    assert {:ok, returned_credential} =
             Impl.Credential.Validation.set_credential(
               test_account.access_account_id,
               test_account.identity_id
             )

    assert String.length(returned_credential) == 40

    # Specified Token
    test_account = get_account_data("credential_validation_create2_test_accnt")

    specified_token = MsbmsSystUtils.get_random_string(40)

    assert {:ok, ^specified_token} =
             Impl.Credential.Validation.set_credential(
               test_account.access_account_id,
               test_account.identity_id,
               specified_token
             )

    # credential_token_length
    test_account = get_account_data("credential_validation_create3_test_accnt")

    assert {:ok, returned_credential} =
             Impl.Credential.Validation.set_credential(
               test_account.access_account_id,
               test_account.identity_id,
               nil,
               credential_token_length: 20
             )

    assert String.length(returned_credential) == 20

    # credential_tokens
    test_account = get_account_data("credential_validation_create4_test_accnt")

    assert {:ok, returned_credential} =
             Impl.Credential.Validation.set_credential(
               test_account.access_account_id,
               test_account.identity_id,
               nil,
               credential_tokens: 'XYZ'
             )

    assert String.length(returned_credential) == 40

    assert not (returned_credential =~ ~r/[^X-Z]/)
  end

  test "Cannot replace an Validation Credential record" do
    test_account = get_account_data("credential_validation_retrieval_test_accnt")

    assert {:error, _} =
             Impl.Credential.Validation.set_credential(
               test_account.access_account_id,
               test_account.identity_id
             )
  end

  test "Can get an Validation Credential record / Success Tuple" do
    test_account = get_account_data("credential_validation_retrieval_test_accnt")

    assert {:ok, %Data.SystCredentials{}} =
             Impl.Credential.Validation.get_credential_record(
               test_account.access_account_id,
               test_account.identity_id
             )
  end

  test "Can get an Validation Credential record / Raise on Error" do
    test_account = get_account_data("credential_validation_retrieval_test_accnt")

    assert %Data.SystCredentials{} =
             Impl.Credential.Validation.get_credential_record!(
               test_account.access_account_id,
               test_account.identity_id
             )
  end

  test "Can delete an Validation Credential record / Success Tuple" do
    test_account = get_account_data("credential_validation_delete_test_accnt")

    cred_record =
      Impl.Credential.Validation.get_credential_record!(
        test_account.access_account_id,
        test_account.identity_id
      )

    assert :ok = Impl.Credential.Validation.delete_credential(cred_record)
  end

  test "Can delete an Validation Credential record / Raise on Error" do
    test_account = get_account_data("credential_validation_delete1_test_accnt")

    cred_record =
      Impl.Credential.Validation.get_credential_record!(
        test_account.access_account_id,
        test_account.identity_id
      )

    assert :ok = Impl.Credential.Validation.delete_credential!(cred_record)
  end

  test "Can delete an Validation Credential record by ID / Success Tuple" do
    test_account = get_account_data("credential_validation_delete_id_test_accnt")

    cred_record =
      Impl.Credential.Validation.get_credential_record!(
        test_account.access_account_id,
        test_account.identity_id
      )

    assert :ok = Impl.Credential.Validation.delete_credential(cred_record.id)
  end

  test "Can delete an Validation Credential record by ID / Raise on Error" do
    test_account = get_account_data("credential_validation_delete1_id_test_accnt")

    cred_record =
      Impl.Credential.Validation.get_credential_record!(
        test_account.access_account_id,
        test_account.identity_id
      )

    assert :ok = Impl.Credential.Validation.delete_credential!(cred_record.id)
  end

  defp get_account_data(access_account_name) do
    from(aa in Data.SystAccessAccounts,
      join: i in assoc(aa, :identities),
      join: ei in assoc(i, :identity_type),
      select: %{access_account_id: aa.id, identity_id: i.id},
      where:
        aa.internal_name == ^access_account_name and
          ei.internal_name == "identity_types_sysdef_validation"
    )
    |> MsbmsSystDatastore.one!()
  end
end
