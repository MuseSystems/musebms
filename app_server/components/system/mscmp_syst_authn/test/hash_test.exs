# Source File: hash_test.exs
# Location:    musebms/app_server/components/system/mscmp_syst_authn/test/hash_test.exs
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
  @moduledoc false

  use ExUnit.Case, async: true

  alias MscmpSystAuthn.Impl

  @moduletag :unit
  @moduletag :capture_log
  @strong_iterations 250
  @weak_iterations 10_000

  describe "credential hash operations" do
    test "Can Create and Verify a Credential Hash" do
      for _i <- 1..@strong_iterations do
        test_credential = Msutils.String.get_random_string(128, :mixed_alphanum)

        assert new_hash = Impl.Hash.create_credential_hash(test_credential)
        assert true == Impl.Hash.verify_credential_hash(new_hash, test_credential)
      end
    end

    test "Can fail Credential Hash Verification" do
      for _i <- 1..@strong_iterations do
        test_credential = Msutils.String.get_random_string(128, :mixed_alphanum)
        bad_credential = Msutils.String.get_random_string(128, :mixed_alphanum)

        assert new_hash = Impl.Hash.create_credential_hash(test_credential)
        assert false == Impl.Hash.verify_credential_hash(new_hash, bad_credential)
      end

      test_credential = Msutils.String.get_random_string(128, :mixed_alphanum)
      assert false == Impl.Hash.verify_credential_hash(nil, test_credential)
    end

    test "Can process the Fake Credential Hash Routine" do
      assert false == Impl.Hash.fake_credential_hash_verify()
    end
  end

  describe "weak hash operations" do
    test "Can generate a Weak Hash consistently" do
      for _i <- 1..@weak_iterations do
        test_value = Msutils.String.get_random_string(128, :mixed_alphanum)

        assert Impl.Hash.weak_hash(test_value) == Impl.Hash.weak_hash(test_value)
      end
    end
  end
end
