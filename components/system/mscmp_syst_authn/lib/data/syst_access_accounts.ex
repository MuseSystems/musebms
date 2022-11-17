# Source File: syst_access_accounts.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/data/syst_access_accounts.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Data.SystAccessAccounts do
  use MscmpSystDb.Schema

  alias MscmpSystAuthn.Data
  alias MscmpSystAuthn.Types

  @moduledoc """
  Contains the known login accounts which are used solely for the purpose of
  authentication of users.

  Authorization is handled on a per-instance basis within the application.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: Types.access_account_name() | nil,
            external_name: String.t() | nil,
            owning_owner_id: MscmpSystInstance.Types.owner_id() | nil,
            owning_owner:
              MscmpSystInstance.Data.SystOwners.t() | Ecto.Association.NotLoaded.t() | nil,
            allow_global_logins: boolean() | nil,
            access_account_state_id: Types.access_account_state_id() | nil,
            access_account_state:
              MscmpSystEnums.Data.SystEnumItems.t() | Ecto.Association.NotLoaded.t() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "ms_syst"

  schema "syst_access_accounts" do
    field(:internal_name, :string)
    field(:external_name, :string)
    field(:allow_global_logins, :boolean)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime)
    field(:diag_role_modified, :string)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer)

    belongs_to(:access_account_state, MscmpSystEnums.Data.SystEnumItems)
    belongs_to(:owning_owner, MscmpSystInstance.Data.SystOwners)

    has_many(:identities, Data.SystIdentities, foreign_key: :access_account_id)
    has_many(:credentials, Data.SystCredentials, foreign_key: :access_account_id)

    has_many(:access_account_instance_assocs, Data.SystAccessAccountInstanceAssocs,
      foreign_key: :access_account_id
    )

    has_many(:password_history, Data.SystPasswordHistory, foreign_key: :access_account_id)
  end

  @spec insert_changeset(Types.access_account_params(), Keyword.t()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(insert_params, opts \\ []), to: Data.Validators.SystAccessAccounts

  @spec update_changeset(Data.SystAccessAccounts.t(), Types.access_account_params(), Keyword.t()) ::
          Ecto.Changeset.t()
  defdelegate update_changeset(access_account, update_params, opts \\ []),
    to: Data.Validators.SystAccessAccounts
end
