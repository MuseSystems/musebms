# Source File: syst_disallowed_passwords.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/validators/syst_disallowed_passwords.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.Validators.SystDisallowedPasswords do
  import Ecto.Changeset

  alias MsbmsSystAuthentication.Data

  @moduledoc false

  @spec insert_changeset(binary()) :: Ecto.Changeset.t()
  def insert_changeset(password_hash) do
    %Data.SystDisallowedPasswords{}
    |> cast(%{password_hash: password_hash}, [:password_hash])
    |> validate_required([:password_hash])
  end
end
