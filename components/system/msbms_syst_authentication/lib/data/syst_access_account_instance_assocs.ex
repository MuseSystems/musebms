# Source File: syst_access_account_instance_assocs.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/syst_access_account_instance_assocs.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.SystAccessAccountInstanceAssocs do
  use MsbmsSystDatastore.Schema

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Types

  @moduledoc """
  Associates access accounts with the instances for which they are allowed to
  authenticate to.

  Note that being able to authenticate to an instance is not the same as having
  authorized rights within the instance; authorization is handled by the
  instance directly.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            access_account_id: Types.access_account_id() | nil,
            access_account: Data.SystAccessAccounts.t() | Ecto.Association.NotLoaded.t() | nil,
            credential_type_id: Types.credential_type_id() | nil,
            credential_type:
              MsbmsSystEnums.Data.SystEnumItems.t() | Ecto.Association.NotLoaded.t() | nil,
            instance_id: MsbmsSystInstanceMgr.Types.instance_id() | nil,
            instance:
              MsbmsSystInstanceMgr.Data.SystInstances.t() | Ecto.Association.NotLoaded.t() | nil,
            access_granted: DateTime.t() | nil,
            invitation_issued: DateTime.t() | nil,
            invitation_expires: DateTime.t() | nil,
            invitation_declined: DateTime.t() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "msbms_syst"

  schema "syst_access_account_instance_assocs" do
    field(:access_granted, :utc_datetime)
    field(:invitation_issued, :utc_datetime)
    field(:invitation_expires, :utc_datetime)
    field(:invitation_declined, :utc_datetime)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime)
    field(:diag_role_modified, :string)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer)

    belongs_to(:access_account, Data.SystAccessAccounts)
    belongs_to(:credential_type, MsbmsSystEnums.Data.SystEnumItems)
    belongs_to(:instance, MsbmsSystInstanceMgr.Data.SystInstances)
  end

  @spec insert_changeset(Types.access_account_instance_assoc_params()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(insert_params), to: Data.Validators.SystAccessAccountInstanceAssocs

  @spec update_changeset(
          Data.SystAccessAccountInstanceAssocs.t(),
          Types.access_account_instance_assoc_params()
        ) :: Ecto.Changeset.t()
  defdelegate update_changeset(access_account_instance_assoc, update_params),
    to: Data.Validators.SystAccessAccountInstanceAssocs
end
