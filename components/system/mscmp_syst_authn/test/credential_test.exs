# Source File: credential_test.exs
# Location:    musebms/components/system/mscmp_syst_authn/test/credential_test.exs
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
  use AuthenticationTestCase, async: true

  alias MscmpSystAuthn.Impl

  @moduletag :capture_log

  test "Can retrieve Credential Type by Internal Name" do
    assert %Msdata.SystEnumItems{internal_name: "credential_types_sysdef_mfa_totp"} =
             Impl.Credential.get_credential_type_by_name("credential_types_sysdef_mfa_totp")

    assert nil == Impl.Credential.get_credential_type_by_name("nonexistent_type")
  end

  test "Can retrieve system default Credential Type" do
    assert %Msdata.SystEnumItems{internal_name: "credential_types_sysdef_password"} =
             Impl.Credential.get_credential_type_default(nil)
  end

  test "Can retrieve functional type default Credential Type" do
    assert %Msdata.SystEnumItems{internal_name: "credential_types_sysdef_token_api"} =
             Impl.Credential.get_credential_type_default(:credential_types_token_api)
  end
end
