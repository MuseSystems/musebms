# Source File: syst_credentials.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/syst_credentials.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.SystCredentials do
  use MsbmsSystDatastore.Schema

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Types

  @moduledoc """
  Hosts the credentials by which a user or external system will prove its
  identity.

  Note that not all credential types are available for authentication with all
  identity types.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            access_account_id: Types.access_account_id() | nil,
            access_account: Data.SystAccessAccounts.t() | Ecto.Association.NotLoaded.t() | nil,
            credential_type_id: Types.credential_type_id() | nil,
            credential_type: Data.SystCredentials.t() | Ecto.Association.NotLoaded.t() | nil,
            credential_for_identity_id: Types.identity_id() | nil,
            credential_for_identity:
              Data.SystIdentities.t() | Ecto.Association.NotLoaded.t() | nil,
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

  @schema_prefix "msbms_syst"

  schema "syst_credentials" do
    field(:credential_data, :string)
    field(:last_updated, :utc_datetime)
    field(:force_reset, :utc_datetime)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime)
    field(:diag_role_modified, :string)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer)

    belongs_to(:access_account, Data.SystAccessAccounts)
    belongs_to(:credential_type, MsbmsSystEnums.Data.SystEnumItems)
    belongs_to(:credential_for_identity, Data.SystIdentities)
  end

  @spec insert_changeset(Types.credential_params()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(insert_params), to: Data.Validators.SystCredentials

  @spec update_changeset(Data.SystCredentials.t(), Types.credential_params()) ::
          Ecto.Changeset.t()
  defdelegate update_changeset(credential, update_params), to: Data.Validators.SystCredentials
end
