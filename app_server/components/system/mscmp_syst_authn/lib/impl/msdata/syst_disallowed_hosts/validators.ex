# Source File: validators.ex
# Location:    musebms/app_server/components/system/mscmp_syst_authn/lib/impl/msdata/syst_disallowed_hosts/validators.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.Msdata.SystDisallowedHosts.Validators do
  @moduledoc false

  import Ecto.Changeset

  alias MscmpSystDb.DbTypes

  ##############################################################################
  #
  # insert_changeset
  #
  #

  @spec insert_changeset(DbTypes.Inet.t()) :: Ecto.Changeset.t()
  def insert_changeset(host_address) do
    %Msdata.SystDisallowedHosts{}
    |> cast(%{host_address: host_address}, [:host_address])
    |> validate_required([:host_address])
    |> unique_constraint(:host_address, name: :syst_disallowed_hosts_host_address_udx)
  end
end
