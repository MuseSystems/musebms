# Source File: syst_disallowed_hosts.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/data/syst_disallowed_hosts.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Data.SystDisallowedHosts do
  use MscmpSystDb.Schema

  alias MscmpSystAuthn.Data.Validators
  alias MscmpSystDb.DbTypes

  @moduledoc """
  A simple listing of "banned" IP address which are not allowed to authenticate
  their users to the system.

  This registry differs from the syst_*_network_rules tables in that IP
  addresses here are registered as the result of automatic system heuristics
  whereas the network rules are direct expressions of system administrator
  intent.  The timing between these two mechanisms is also different in that
  records in this table are evaluated prior to an authentication attempt and
  most network rules are processed in the authentication attempt sequence.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            host_address: DbTypes.Inet.t() | nil
          }

  @schema_prefix "msbms_syst"

  schema "syst_disallowed_hosts" do
    field(:host_address, DbTypes.Inet)
  end

  @spec insert_changeset(DbTypes.Inet.t()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(host_address), to: Validators.SystDisallowedHosts
end
