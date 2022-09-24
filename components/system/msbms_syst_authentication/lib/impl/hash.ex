# Source File: hash.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/impl/hash.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Impl.Hash do
  @moduledoc false

  # Note that this module exists mostly to wrap library APIs which provide
  # proper cryptographic functions.  We wrap things here so that we can have
  # some flexibility in which libraries to expose to the rest of the
  # application. For example, the currently favored Argon2 password hashing
  # algorithm provided by comeonin is documented as being difficult to build on
  # Windows; so for Windows builds we may need to use a different algorithm
  # here.

  def create_credential_hash(credential_plaintext, opts \\ []) do
    Argon2.hash_pwd_salt(credential_plaintext, opts)
  end

  def verify_credential_hash(nil, _credential_plaintext), do: false

  def verify_credential_hash(credential_data, credential_plaintext) do
    Argon2.verify_pass(credential_plaintext, credential_data)
  end

  def weak_hash(plaintext) do
    :crypto.hash(:sha, plaintext)
  end
end
