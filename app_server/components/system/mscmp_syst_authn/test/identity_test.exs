# Source File: identity_test.exs
# Location:    musebms/components/system/mscmp_syst_authn/test/identity_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule IdentityTest do
  use AuthenticationTestCase, async: true

  alias MscmpSystAuthn.Impl

  @moduletag :capture_log

  test "Can retrieve Identity Type by Internal Name" do
    assert %Msdata.SystEnumItems{internal_name: "identity_types_sysdef_account"} =
             Impl.Identity.get_identity_type_by_name("identity_types_sysdef_account")

    assert nil == Impl.Identity.get_identity_type_by_name("nonexistent_type")
  end

  test "Can retrieve system default Identity Type" do
    assert %Msdata.SystEnumItems{internal_name: "identity_types_sysdef_email"} =
             Impl.Identity.get_identity_type_default(nil)
  end

  test "Can retrieve functional type default Identity Type" do
    assert %Msdata.SystEnumItems{internal_name: "identity_types_sysdef_api"} =
             Impl.Identity.get_identity_type_default(:identity_types_api)
  end

  test "Can set Identity expiration" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner2")

    %Msdata.SystIdentities{} =
      unexpired_identity =
      Impl.Identity.Email.identify_access_account(
        "identity_set_expired_test_accnt@musesystems.com",
        owner_id
      )

    {:ok, false} = Impl.Identity.identity_expired?(unexpired_identity)

    assert {:ok, expired_identity} =
             Impl.Identity.set_identity_expiration(unexpired_identity.id, DateTime.utc_now())

    assert {:ok, true} = Impl.Identity.identity_expired?(expired_identity)
  end

  test "Can clear Identity expiration" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner2")

    %Msdata.SystIdentities{} =
      expired_identity =
      Impl.Identity.Email.identify_access_account(
        "identity_clear_expired_test_accnt@musesystems.com",
        owner_id
      )

    {:ok, true} = Impl.Identity.identity_expired?(expired_identity)

    assert {:ok, cleared_identity} = Impl.Identity.clear_identity_expiration(expired_identity.id)

    assert {:ok, false} = Impl.Identity.identity_expired?(cleared_identity)
  end

  test "Can test if Identity is expired" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner2")

    %Msdata.SystIdentities{} =
      expired_identity =
      Impl.Identity.Email.identify_access_account(
        "identity_expired_test_accnt@musesystems.com",
        owner_id
      )

    assert {:ok, true} = Impl.Identity.identity_expired?(expired_identity)

    %Msdata.SystIdentities{} =
      not_expired_identity =
      Impl.Identity.Email.identify_access_account(
        "identity_not_expired_test_accnt@musesystems.com",
        owner_id
      )

    assert {:ok, false} = Impl.Identity.identity_expired?(not_expired_identity)
  end

  test "Can test if Identity is validated" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner2")

    %Msdata.SystIdentities{} =
      validated_identity =
      Impl.Identity.Email.identify_access_account(
        "identity_validated_test_accnt@musesystems.com",
        owner_id
      )

    assert {:ok, true} = Impl.Identity.identity_validated?(validated_identity)

    # We don't have a great way to retrieve the not validated identity record
    # since identify_access_account/2 filters out not validated results and we
    # really only want to test identity_validated?/1 anyway.

    not_validated_identity = Map.put(validated_identity, :validated, nil)

    assert {:ok, false} = Impl.Identity.identity_validated?(not_validated_identity)
  end

  test "Can delete Identity" do
    {:ok, owner_id} = MscmpSystInstance.get_owner_id_by_name("owner2")

    %Msdata.SystIdentities{} =
      delete_identity =
      Impl.Identity.Email.identify_access_account(
        "identity_delete_test_accnt@musesystems.com",
        owner_id
      )

    assert :deleted =
             Impl.Identity.delete_identity(delete_identity.id, "identity_types_sysdef_email")
  end
end
