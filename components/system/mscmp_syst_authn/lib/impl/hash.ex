# Source File: hash.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/impl/hash.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.Hash do
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

  # The function below attempts to eliminate certain timing attacks which could
  # otherwise see cases where we didn't run an actual verification of a
  # credential.  Note that mimicking the hash process time by itself is may not
  # be sufficient, just likely better than no effort.  In addition to hash
  # processing there are various database queries and the like leading up to an
  # attempt to process a hash which also contribute to total authentication
  # time.  Depending on where authentication failed one or more of these queries
  # or processes may not have run possibly revealing timing discrepancies that
  # could be interpreted by an attacker.

  def fake_credential_hash_verify(opts \\ []) do
    Argon2.no_user_verify(opts)
  end

  def weak_hash(plaintext) do
    :crypto.hash(:sha, plaintext)
  end
end
