# Source File: credential_api_token_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_authn/test/credential_api_token_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule CredentialApiTokenTest do
  @moduledoc false

  # credo:disable-for-this-file Credo.Check.Design.AliasUsage
  #
  # In the tests we'll be more permissive of failing this check for now.
  # In application code we should adhere to our configured checks.

  use AuthenticationTestCase, async: true

  import Ecto.Query

  alias MscmpSystAuthn.Impl

  @moduletag :unit
  @moduletag :capture_log

  ##############################################################################
  #
  # Test Option Definitions
  #
  #

  @test_options [
    credential_token_length: [
      type: :pos_integer,
      default: 40
    ],
    credential_tokens: [
      type: {:or, [{:list, :any}, {:in, [:alphanum, :mixed_alphanum, :b32e, :b32c]}]},
      default: :mixed_alphanum
    ]
  ]

  describe "credential confirmation" do
    test "Can Confirm API Token Credential" do
      test_account = get_account_data("owned_all_access")

      assert {:ok, {:confirmed, []}} =
               Impl.Credential.ApiToken.confirm_credential(
                 test_account.access_account_id,
                 test_account.identity_id,
                 "QNXWXLSYLB8O3PHMSLOEU9Y1WZF4PIIPUQREXSRRYLVBMPU2"
               )

      assert {:ok, {:wrong_credential, []}} =
               Impl.Credential.ApiToken.confirm_credential(
                 test_account.access_account_id,
                 test_account.identity_id,
                 Msutils.String.get_random_string(48)
               )

      assert {:ok, {:no_credential, []}} =
               Impl.Credential.ApiToken.confirm_credential(
                 test_account.access_account_id,
                 "00000000-0000-0000-0000-000000000000",
                 "QNXWXLSYLB8O3PHMSLOEU9Y1WZF4PIIPUQREXSRRYLVBMPU2"
               )

      assert {:error, :invalid_request} =
               Impl.Credential.ApiToken.confirm_credential(
                 test_account.access_account_id,
                 nil,
                 "QNXWXLSYLB8O3PHMSLOEU9Y1WZF4PIIPUQREXSRRYLVBMPU2"
               )
    end
  end

  describe "credential management" do
    test "Can insert an API Token Credential record" do
      # Default

      test_account = get_account_data("credential_api_token_create1_test_accnt")

      default_opts =
        @test_options
        |> Keyword.take([
          :credential_token_length,
          :credential_tokens
        ])
        |> NimbleOptions.new!()
        |> then(&NimbleOptions.validate!([], &1))

      assert {:ok, returned_credential} =
               Impl.Credential.ApiToken.set_credential(
                 test_account.access_account_id,
                 test_account.identity_id,
                 nil,
                 default_opts
               )

      assert String.length(returned_credential) == 40

      # Specified Token

      test_account = get_account_data("credential_api_token_create2_test_accnt")

      specified_token = Msutils.String.get_random_string(40)

      assert {:ok, ^specified_token} =
               Impl.Credential.ApiToken.set_credential(
                 test_account.access_account_id,
                 test_account.identity_id,
                 specified_token,
                 default_opts
               )

      # credential_token_length

      test_account = get_account_data("credential_api_token_create3_test_accnt")

      opts =
        @test_options
        |> Keyword.take([
          :credential_token_length,
          :credential_tokens
        ])
        |> NimbleOptions.new!()
        |> then(&NimbleOptions.validate!([credential_token_length: 20], &1))

      assert {:ok, returned_credential} =
               Impl.Credential.ApiToken.set_credential(
                 test_account.access_account_id,
                 test_account.identity_id,
                 nil,
                 opts
               )

      assert String.length(returned_credential) == 20

      # credential_tokens

      test_account = get_account_data("credential_api_token_create4_test_accnt")

      opts =
        @test_options
        |> Keyword.take([
          :credential_token_length,
          :credential_tokens
        ])
        |> NimbleOptions.new!()
        |> then(&NimbleOptions.validate!([credential_tokens: ~c"XYZ"], &1))

      assert {:ok, returned_credential} =
               Impl.Credential.ApiToken.set_credential(
                 test_account.access_account_id,
                 test_account.identity_id,
                 nil,
                 opts
               )

      assert String.length(returned_credential) == 40

      assert not (returned_credential =~ ~r/[^X-Z]/)
    end

    test "Cannot replace an API Token Credential record" do
      test_account = get_account_data("unowned_all_access")

      opts =
        @test_options
        |> Keyword.take([
          :credential_token_length,
          :credential_tokens
        ])
        |> NimbleOptions.new!()
        |> then(&NimbleOptions.validate!([], &1))

      assert {:error, _} =
               Impl.Credential.ApiToken.set_credential(
                 test_account.access_account_id,
                 test_account.identity_id,
                 nil,
                 opts
               )
    end

    test "Can get an API Token Credential record" do
      test_account = get_account_data("unowned_all_access")

      assert {:ok, %Msdata.SystCredentials{}} =
               Impl.Credential.ApiToken.get_credential_record(
                 test_account.access_account_id,
                 test_account.identity_id
               )
    end
  end

  describe "credential deletion" do
    test "Can delete an API Token Credential record" do
      test_account = get_account_data("credential_api_token_delete_test_accnt")

      {:ok, cred_record} =
        Impl.Credential.ApiToken.get_credential_record(
          test_account.access_account_id,
          test_account.identity_id
        )

      assert :ok = Impl.Credential.ApiToken.delete_credential(cred_record)
    end

    test "Can delete an API Token Credential record by ID" do
      test_account = get_account_data("credential_api_token_delete_id_test_accnt")

      {:ok, cred_record} =
        Impl.Credential.ApiToken.get_credential_record(
          test_account.access_account_id,
          test_account.identity_id
        )

      assert :ok = Impl.Credential.ApiToken.delete_credential(cred_record.id)
    end
  end

  defp get_account_data(access_account_name) do
    from(aa in Msdata.SystAccessAccounts,
      join: i in assoc(aa, :identities),
      join: ei in assoc(i, :identity_type),
      select: %{access_account_id: aa.id, identity_id: i.id},
      where:
        aa.internal_name == ^access_account_name and
          ei.internal_name == "identity_types_sysdef_api"
    )
    |> MscmpSystDb.one!()
  end
end
