# Source File: credential_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_authn/test/credential_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule CredentialTest do
  @moduledoc false

  use AuthenticationTestCase, async: true

  alias MscmpSystAuthn.Impl

  @moduletag :unit
  @moduletag :capture_log

  describe "get_credential_type_by_name/1" do
    test "returns credential type when given valid name" do
      assert %Msdata.SystEnumItems{internal_name: "credential_types_sysdef_mfa_totp"} =
               Impl.Credential.get_credential_type_by_name("credential_types_sysdef_mfa_totp")
    end

    test "returns nil for nonexistent credential type" do
      assert nil == Impl.Credential.get_credential_type_by_name("nonexistent_type")
    end

    test "returns nil for empty string" do
      assert nil == Impl.Credential.get_credential_type_by_name("")
    end
  end

  describe "get_credential_type_default/1" do
    test "returns password type when nil provided" do
      assert %Msdata.SystEnumItems{internal_name: "credential_types_sysdef_password"} =
               Impl.Credential.get_credential_type_default(nil)
    end

    test "returns correct type for functional type atom" do
      assert %Msdata.SystEnumItems{internal_name: "credential_types_sysdef_token_api"} =
               Impl.Credential.get_credential_type_default(:credential_types_token_api)
    end

    test "raises for unknown functional type" do
      assert_raise RuntimeError, fn ->
        Impl.Credential.get_credential_type_default(:unknown_type)
      end
    end
  end
end
