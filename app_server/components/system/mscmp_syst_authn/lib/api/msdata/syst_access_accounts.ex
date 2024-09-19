# Source File: syst_access_accounts.ex
# Location:    musebms/app_server/components/system/mscmp_syst_authn/lib/api/msdata/syst_access_accounts.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystAccessAccounts do
  @moduledoc tags: [:mscmp_syst_authn]
  @moduledoc """
  Contains the known login accounts which are used solely for the purpose of
  authentication of users.

  Authorization is handled on a per-instance basis within the application.

  Defined in `MscmpSystAuthn`
  """

  use MscmpSystDb.Schema

  import Msutils.Data, only: [common_validator_options: 1]

  alias MscmpSystAuthn.Impl.Msdata.SystAccessAccounts.Validators
  alias MscmpSystAuthn.Types

  require Msutils.Data

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: Types.access_account_name() | nil,
            external_name: String.t() | nil,
            owning_owner_id: MscmpSystInstance.Types.owner_id() | nil,
            owning_owner: Msdata.SystOwners.t() | Ecto.Association.NotLoaded.t() | nil,
            allow_global_logins: boolean() | nil,
            access_account_state_id: Types.access_account_state_id() | nil,
            access_account_state: Msdata.SystEnumItems.t() | Ecto.Association.NotLoaded.t() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "ms_syst"
  @derive {Jason.Encoder,
           except: [
             :__meta__,
             :access_account_instance_assocs,
             :access_account_state,
             :owning_owner,
             :identities,
             :credentials,
             :password_history
           ]}

  schema "syst_access_accounts" do
    field(:internal_name, :string)
    field(:external_name, :string)
    field(:allow_global_logins, :boolean)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)

    belongs_to(:access_account_state, Msdata.SystEnumItems)
    belongs_to(:owning_owner, Msdata.SystOwners)

    has_many(:identities, Msdata.SystIdentities, foreign_key: :access_account_id)
    has_many(:credentials, Msdata.SystCredentials, foreign_key: :access_account_id)

    has_many(:access_account_instance_assocs, Msdata.SystAccessAccountInstanceAssocs,
      foreign_key: :access_account_id
    )

    has_many(:password_history, Msdata.SystPasswordHistory, foreign_key: :access_account_id)
  end

  ##############################################################################
  #
  # insert_changeset
  #
  #

  @insert_changeset_opts common_validator_options([
                           :internal_name,
                           :display_name
                         ])

  @doc """
  Produces a changeset for inserting a new Access Account.

  ## Parameters

    * `insert_params` - The parameters to be used to create the new Access Account.

    * `opts` - A keyword list of options which can customize the changeset
      creation process.

  ## Options

    #{NimbleOptions.docs(@insert_changeset_opts)}
  """
  @spec insert_changeset(Types.access_account_params()) :: Ecto.Changeset.t()
  @spec insert_changeset(Types.access_account_params(), Keyword.t()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params, opts \\ []) do
    opts = NimbleOptions.validate!(opts, @insert_changeset_opts)
    Validators.insert_changeset(insert_params, opts)
  end

  ##############################################################################
  #
  # update_changeset
  #
  #

  @update_changeset_opts common_validator_options([
                           :internal_name,
                           :external_name
                         ])

  @doc """
  Produces a changeset for inserting a new Access Account.

  ## Parameters

    * `access_account` - The Access Account to be updated.

    * `update_params` - The parameters to be used to update the Access Account.

    * `opts` - A keyword list of options which can customize the changeset
      update process.

  ## Options

    #{NimbleOptions.docs(@update_changeset_opts)}
  """

  @spec update_changeset(
          Msdata.SystAccessAccounts.t(),
          Types.access_account_params()
        ) ::
          Ecto.Changeset.t()
  @spec update_changeset(
          Msdata.SystAccessAccounts.t(),
          Types.access_account_params(),
          Keyword.t()
        ) ::
          Ecto.Changeset.t()
  def update_changeset(access_account, update_params, opts \\ []) do
    opts = NimbleOptions.validate!(opts, @update_changeset_opts)
    Validators.update_changeset(access_account, update_params, opts)
  end
end
