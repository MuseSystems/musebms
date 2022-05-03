# Source File: syst_instances.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/data/syst_instances.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Data.SystInstances do
  use MsbmsSystDatastore.Schema
  import Ecto.Changeset
  import MsbmsSystInstanceMgr.Impl.ChangesetHelpers

  @moduledoc """
  Data definition describing known application Instances.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: MsbmsSystInstanceMgr.Types.instance_name() | nil,
            display_name: String.t() | nil,
            application_id: Ecto.UUID.t() | nil,
            application:
              MsbmsSystInstanceMgr.Data.SystApplications.t()
              | Ecto.Association.NotLoaded.t()
              | nil,
            instance_type_id: Ecto.UUID.t() | nil,
            instance_type:
              MsbmsSystEnums.Data.SystEnumItems.t() | Ecto.Association.NotLoaded.t() | nil,
            instance_state_id: Ecto.UUID.t() | nil,
            instance_state:
              MsbmsSystEnums.Data.SystEnumItems.t() | Ecto.Association.NotLoaded.t() | nil,
            owner_id: Ecto.UUID.t() | nil,
            owner:
              MsbmsSystInstanceMgr.Data.SystOwners.t() | Ecto.Association.NotLoaded.t() | nil,
            owning_instance_id: Ecto.UUID.t() | nil,
            owning_instance:
              MsbmsSystInstanceMgr.Data.SystInstances.t() | Ecto.Association.NotLoaded.t() | nil,
            dbserver_name: String.t() | nil,
            db_app_context_pool_size: integer() | nil,
            db_api_context_pool_size: integer() | nil,
            instance_code: binary() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "msbms_syst"

  schema "syst_instances" do
    field(:internal_name, :string)
    field(:display_name, :string)
    field(:dbserver_name, :string)
    field(:db_app_context_pool_size, :integer)
    field(:db_api_context_pool_size, :integer)
    field(:instance_code, :binary)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime)
    field(:diag_role_modified, :string)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer)

    belongs_to(:application, MsbmsSystInstanceMgr.Data.SystApplications)
    belongs_to(:instance_type, MsbmsSystEnums.Data.SystEnumItems)
    belongs_to(:instance_state, MsbmsSystEnums.Data.SystEnumItems)
    belongs_to(:owner, MsbmsSystInstanceMgr.Data.SystOwners)
    belongs_to(:owning_instance, MsbmsSystInstanceMgr.Data.SystInstances)

    has_many(:owned_instances, MsbmsSystInstanceMgr.Data.SystInstances,
      foreign_key: :owning_instance_id
    )
  end

  @spec changeset(
          MsbmsSystInstanceMgr.Data.SystInstances.t(),
          MsbmsSystInstanceMgr.Types.instance_params(),
          Keyword.t()
        ) ::
          Ecto.Changeset.t()
  def changeset(instance, change_params \\ %{}, opts \\ []) do
    opts = resolve_options(opts)

    instance
    |> cast(change_params, [
      :internal_name,
      :display_name,
      :dbserver_name,
      :db_app_context_pool_size,
      :db_api_context_pool_size,
      :instance_code_id,
      :application_id,
      :instance_type_id,
      :instance_state_id,
      :owner_id,
      :owning_instance_id
    ])
    |> validate_required([
      :dbserver_name,
      :db_app_context_pool_size,
      :db_api_context_pool_size,
      :instance_code_id,
      :application_id,
      :instance_type_id,
      :instance_state_id
    ])
    |> validate_internal_name(opts)
    |> validate_display_name(opts)
  end
end
