# Source File: validators.ex
# Location:    musebms/app_server/components/system/mscmp_syst_authn/lib/impl/msdata/syst_disallowed_passwords/validators.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.Msdata.SystDisallowedPasswords.Validators do
  @moduledoc false

  import Ecto.Changeset

  ##############################################################################
  #
  # insert_changeset
  #
  #

  @spec insert_changeset(binary()) :: Ecto.Changeset.t()
  def insert_changeset(password_hash) do
    %Msdata.SystDisallowedPasswords{}
    |> cast(%{password_hash: password_hash}, [:password_hash])
    |> validate_required([:password_hash])
  end
end
