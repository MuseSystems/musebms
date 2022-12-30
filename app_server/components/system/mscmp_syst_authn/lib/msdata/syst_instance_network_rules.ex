# Source File: syst_instance_network_rules.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/msdata/syst_instance_network_rules.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystInstanceNetworkRules do
  use MscmpSystDb.Schema

  alias MscmpSystAuthn.Msdata.Validators
  alias MscmpSystAuthn.Types
  alias MscmpSystDb.DbTypes

  @moduledoc """
  Expresses Instance specific rules concerning which hosts, as identified by
  IP address, may or may not attempt to authenticate with the system.

  These are part of a firewall-like set of rules of which those defined in this
  'instance' scope are evaluated after any `SystGlobalNetworkRules` and
  `SystOwnerNetworkRules` defined rules have been processed.

  Defined in `MscmpSystAuthn`.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            instance_id: MscmpSystInstance.Types.instance_id() | nil,
            instance: Msdata.SystInstances.t() | Ecto.Association.NotLoaded.t() | nil,
            ordering: integer() | nil,
            functional_type: String.t() | nil,
            ip_host_or_network: DbTypes.Inet.t() | nil,
            ip_host_range_lower: DbTypes.Inet.t() | nil,
            ip_host_range_upper: DbTypes.Inet.t() | nil,
            ip_family: integer() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "ms_syst"

  schema "syst_instance_network_rules" do
    field(:ordering, :integer)
    field(:functional_type, :string)
    field(:ip_host_or_network, DbTypes.Inet)
    field(:ip_host_range_lower, DbTypes.Inet)
    field(:ip_host_range_upper, DbTypes.Inet)
    field(:ip_family, :integer)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)

    belongs_to(:instance, Msdata.SystInstances)
  end

  @spec insert_changeset(Types.instance_network_rule_params()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(insert_params), to: Validators.SystInstanceNetworkRules

  @spec update_changeset(t(), Types.instance_network_rule_params()) :: Ecto.Changeset.t()
  defdelegate update_changeset(instance_id, update_params),
    to: Validators.SystInstanceNetworkRules
end
