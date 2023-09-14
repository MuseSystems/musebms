# Source File: syst_disallowed_passwords.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/msdata/syst_disallowed_passwords.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystDisallowedPasswords do
  @moduledoc """
  Represents a SHA-1 hashed password which is expected to be listed in
  the dictionaries used by attackers to compromised online accounts.  Disallowed
  passwords, as the name suggests, are used to prevent users selecting these
  known compromised passwords when the password rule to disallow known passwords
  is in effect.

  Defined in `MscmpSystAuthn`.
  """

  use Ecto.Schema

  alias MscmpSystAuthn.Msdata.Validators

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            password_hash: binary() | nil
          }

  @schema_prefix "ms_syst"
  @primary_key {:password_hash, :binary, autogenerate: false, redact: true}

  schema "syst_disallowed_passwords" do
  end

  @spec insert_changeset(binary()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(password_hash), to: Validators.SystDisallowedPasswords
end
