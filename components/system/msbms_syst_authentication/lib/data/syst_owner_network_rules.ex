# Source File: syst_owner_network_rules.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/syst_owner_network_rules.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.SystOwnerNetworkRules do
  use MscmpSystDb.Schema

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Types
  alias MscmpSystDb.DbTypes

  @moduledoc """
  Expresses Owner specific rules concerning which hosts, as identified by
  IP address, may or may not attempt to authenticate with the system.

  These are part of a firewall-like set of rules of which those defined in this
  'owner' scope are evaluated after any `SystGlobalNetworkRules` defined rules
  and prior to any `SystInstanceNetworkRules` defined rules.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            owner_id: MscmpSystInstance.Types.owner_id() | nil,
            owner: MscmpSystInstance.Data.SystOwners.t() | Ecto.Association.NotLoaded.t() | nil,
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

  @schema_prefix "msbms_syst"

  schema "syst_owner_network_rules" do
    field(:ordering, :integer)
    field(:functional_type, :string)
    field(:ip_host_or_network, DbTypes.Inet)
    field(:ip_host_range_lower, DbTypes.Inet)
    field(:ip_host_range_upper, DbTypes.Inet)
    field(:ip_family, :integer)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime)
    field(:diag_role_modified, :string)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer)

    belongs_to(:owner, MscmpSystInstance.Data.SystOwners)
  end

  @spec insert_changeset(Types.owner_network_rule_params()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(insert_params), to: Data.Validators.SystOwnerNetworkRules

  @spec update_changeset(t(), Types.owner_network_rule_params()) :: Ecto.Changeset.t()
  defdelegate update_changeset(owner_network_rule, update_params),
    to: Data.Validators.SystOwnerNetworkRules
end
