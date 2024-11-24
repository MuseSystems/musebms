# Source File: identity_email_test.exs
# Location:    musebms/components/system/mscmp_syst_authn/test/identity_email_test.exs
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
    create_validated: [
      type: :boolean,
      default: false
    ]
  ]

  describe "email address validation and normalization" do
    test "Can validate Email Address format" do
      assert {:ok, "AValid!EmailAddress@MuseSystems.Com"} =
               Impl.Identity.Email.verify_email_address("AValid!EmailAddress@MuseSystems.Com")

      assert {:error, {:invalid_email_address, "AValid!EmailAddress"}} =
               Impl.Identity.Email.verify_email_address("AValid!EmailAddress")
    end

    test "Can normalize Email Address" do
      assert "AValid!EmailAddress@musesystems.com" =
               Impl.Identity.Email.normalize_email_address("AValid!EmailAddress@MuseSystems.Com")
    end
  end

  describe "identity creation" do
    test "Can create Email Identity" do
      {:ok, access_account_id} =
        Impl.AccessAccount.get_access_account_id_by_name("identity_email_create_test_accnt")

      # Default Options

      default_opts =
        @test_options
        |> Keyword.take([
          :create_validated
        ])
        |> NimbleOptions.new!()
        |> then(&NimbleOptions.validate!([], &1))

      assert {:ok, default_identity} =
               Impl.Identity.Email.create_identity(
                 access_account_id,
                 "identity_email_create_test_accnt@musesystems.com",
                 default_opts
               )

      assert %Msdata.SystIdentities{validated: nil, account_identifier: identifier} =
               default_identity

      assert "identity_email_create_test_accnt@musesystems.com" = identifier

      :ok = Impl.Identity.delete_identity(default_identity.id, "identity_types_sysdef_email")

      # Options: create_validated

      opts =
        @test_options
        |> Keyword.take([
          :create_validated
        ])
        |> NimbleOptions.new!()
        |> then(&NimbleOptions.validate!([create_validated: true], &1))

      assert {:ok, default_identity} =
               Impl.Identity.Email.create_identity(
                 access_account_id,
                 "identity_email_create_test_accnt@musesystems.com",
                 opts
               )

      assert %Msdata.SystIdentities{validated: val_date, account_identifier: identifier} =
               default_identity

      assert DateTime.compare(val_date, DateTime.utc_now()) in [:eq, :lt]

      assert "identity_email_create_test_accnt@musesystems.com" = identifier

      :ok = Impl.Identity.delete_identity(default_identity.id, "identity_types_sysdef_email")

      # Bad Email Address

      assert {:error, {:invalid_email_address, "identity_email_create_test_accnt"}} =
               Impl.Identity.Email.create_identity(
                 access_account_id,
                 "identity_email_create_test_accnt",
                 default_opts
               )

      # Mixed Case Handling

      assert {:ok, default_identity} =
               Impl.Identity.Email.create_identity(
                 access_account_id,
                 "Identity_Email_Create_Test_Accnt@MuseSystems.Com",
                 default_opts
               )

      assert %Msdata.SystIdentities{validated: nil, account_identifier: identifier} =
               default_identity

      assert "Identity_Email_Create_Test_Accnt@musesystems.com" = identifier
    end
  end

  describe "access account identification" do
    test "Can identify Owned Access Account" do
      target =
        from(
          aa in Msdata.SystAccessAccounts,
          join: i in assoc(aa, :identities),
          join: ei in assoc(i, :identity_type),
          select: %{account_identifier: i.account_identifier, owning_owner_id: aa.owning_owner_id},
          where:
            aa.internal_name == "owned_all_access" and
              ei.internal_name == "identity_types_sysdef_email"
        )
        |> MscmpSystDb.one!()

      assert {:ok, %Msdata.SystIdentities{}} =
               Impl.Identity.Email.identify_access_account(
                 target.account_identifier,
                 target.owning_owner_id
               )

      assert {:error, :not_found} =
               Impl.Identity.Email.identify_access_account(target.account_identifier, nil)
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
              ei.internal_name == "identity_types_sysdef_email"
        )
        |> MscmpSystDb.one!()

      assert {:ok, %Msdata.SystIdentities{}} =
               Impl.Identity.Email.identify_access_account(
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
              ei.internal_name == "identity_types_sysdef_email"
        )
        |> MscmpSystDb.one!()

      assert {:error, :not_found} =
               Impl.Identity.Email.identify_access_account(bad_target.account_identifier, nil)
    end

    test "Can identify Access Account with mixed case email" do
      assert {:ok, %Msdata.SystIdentities{}} =
               Impl.Identity.Email.identify_access_account(
                 "unowned_all_access@MuseSystems.COM",
                 nil
               )

      assert {:error, :not_found} =
               Impl.Identity.Email.identify_access_account(
                 "Unowned_All_Access@musesystems.com",
                 nil
               )
    end
  end
end
