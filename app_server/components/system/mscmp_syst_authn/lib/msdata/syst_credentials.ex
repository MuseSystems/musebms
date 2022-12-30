# Source File: syst_credentials.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/msdata/syst_credentials.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystCredentials do
  use MscmpSystDb.Schema

  alias MscmpSystAuthn.Msdata.Validators
  alias MscmpSystAuthn.Types

  @moduledoc """
  Hosts the credentials by which a user or external system will prove its
  identity.

  Note that not all credential types are available for authentication with all
  identity types.

  Defined in `MscmpSystAuthn`.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            access_account_id: Types.access_account_id() | nil,
            access_account: Msdata.SystAccessAccounts.t() | Ecto.Association.NotLoaded.t() | nil,
            credential_type_id: Types.credential_type_id() | nil,
            credential_type: Msdata.SystCredentials.t() | Ecto.Association.NotLoaded.t() | nil,
            credential_for_identity_id: Types.identity_id() | nil,
            credential_for_identity:
              Msdata.SystIdentities.t() | Ecto.Association.NotLoaded.t() | nil,
            credential_data: String.t() | nil,
            last_updated: DateTime.t() | nil,
            force_reset: DateTime.t() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "ms_syst"

  schema "syst_credentials" do
    field(:credential_data, :string)
    field(:last_updated, :utc_datetime)
    field(:force_reset, :utc_datetime)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)

    belongs_to(:access_account, Msdata.SystAccessAccounts)
    belongs_to(:credential_type, Msdata.SystEnumItems)
    belongs_to(:credential_for_identity, Msdata.SystIdentities)
  end

  @spec insert_changeset(Types.credential_params()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(insert_params), to: Validators.SystCredentials

  @spec update_changeset(Msdata.SystCredentials.t(), Types.credential_params()) ::
          Ecto.Changeset.t()
  defdelegate update_changeset(credential, update_params), to: Validators.SystCredentials
end
