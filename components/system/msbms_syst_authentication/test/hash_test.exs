# Source File: hash_test.exs
# Location:    musebms/components/system/msbms_syst_authentication/test/hash_test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule HashTest do
  use ExUnit.Case, async: true

  alias MsbmsSystAuthentication.Impl

  test "Can Create and Verify a Credential Hash" do
    test_credential = MsbmsSystUtils.get_random_string(128, :mixed_alphanum)

    assert new_hash = Impl.Hash.create_credential_hash(test_credential)
    assert true == Impl.Hash.verify_credential_hash(new_hash, test_credential)
  end

  test "Can fail Credential Hash Verification" do
    test_credential = MsbmsSystUtils.get_random_string(128, :mixed_alphanum)
    bad_credential = MsbmsSystUtils.get_random_string(128, :mixed_alphanum)

    assert new_hash = Impl.Hash.create_credential_hash(test_credential)
    assert false == Impl.Hash.verify_credential_hash(new_hash, bad_credential)
    assert false == Impl.Hash.verify_credential_hash(nil, test_credential)
  end

  test "Can process the Fake Credential Hash Routine" do
    assert false == Impl.Hash.fake_credential_hash_verify()
  end

  test "Can generate a Weak Hash consistently" do
    test_value = MsbmsSystUtils.get_random_string(128, :mixed_alphanum)

    assert Impl.Hash.weak_hash(test_value) == Impl.Hash.weak_hash(test_value)
  end
end
