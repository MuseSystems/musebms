# Source File: syst_disallowed_hosts.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/data/validators/syst_disallowed_hosts.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Data.Validators.SystDisallowedHosts do
  import Ecto.Changeset

  alias MscmpSystAuthn.Data
  alias MscmpSystDb.DbTypes

  @moduledoc false

  @spec insert_changeset(DbTypes.Inet.t()) :: Ecto.Changeset.t()
  def insert_changeset(host_address) do
    %Data.SystDisallowedHosts{}
    |> cast(%{host_address: host_address}, [:host_address])
    |> validate_required([:host_address])
  end
end
