# Source File: syst_identities.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/data/syst_identities.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Data.SystIdentities do
  use MscmpSystDb.Schema

  alias MscmpSystAuthn.Data
  alias MscmpSystAuthn.Types

  @moduledoc """
  The identities with which access accounts are identified to the system.

  The most common example of an identity would be a user name such as an email
  address.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            access_account_id: Types.access_account_id() | nil,
            access_account: Data.SystAccessAccounts.t() | Ecto.Association.NotLoaded.t() | nil,
            identity_type_id: Types.identity_type_id() | nil,
            identity_type:
              MscmpSystEnums.Data.SystEnumItems.t() | Ecto.Association.NotLoaded.t() | nil,
            account_identifier: String.t() | nil,
            validated: DateTime.t() | nil,
            validates_identity_id: Types.identity_id() | nil,
            validates_identity: t() | Ecto.Association.NotLoaded.t() | nil,
            validation_requested: DateTime.t() | nil,
            identity_expires: DateTime.t() | nil,
            external_name: String.t() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "ms_syst"

  schema "syst_identities" do
    field(:account_identifier, :string)
    field(:validated, :utc_datetime)
    field(:validation_requested, :utc_datetime)
    field(:identity_expires, :utc_datetime)
    field(:external_name)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime)
    field(:diag_role_modified, :string)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer)

    belongs_to(:access_account, Data.SystAccessAccounts)
    belongs_to(:identity_type, MscmpSystEnums.Data.SystEnumItems)
    belongs_to(:validates_identity, Data.SystIdentities)
  end

  @spec insert_changeset(Types.identity_params()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(insert_params), to: Data.Validators.SystIdentities

  @spec update_changeset(Data.SystIdentities.t(), Types.identity_params()) :: Ecto.Changeset.t()
  defdelegate update_changeset(identity, update_params), to: Data.Validators.SystIdentities
end