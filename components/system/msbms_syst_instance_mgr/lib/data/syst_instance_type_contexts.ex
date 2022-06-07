# Source File: syst_instance_type_contexts.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/data/syst_instance_type_contexts.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Data.SystInstanceTypeContexts do
  use MsbmsSystDatastore.Schema

  import Ecto.Changeset

  @moduledoc """
  Defines the data structure of the Instance Type Context.

  Establishes Instance Type defaults for each of an Application's defined
  datastore contexts.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            instance_type_id: Ecto.UUID.t() | nil,
            instance_type:
              MsbmsSystEnums.Data.SystEnumItems.t()
              | Ecto.Association.NotLoaded.t()
              | nil,
            application_context_id: Ecto.UUID.t() | nil,
            application_context:
              MsbmsSystInstanceMgr.Data.SystApplicationContexts.t()
              | Ecto.Association.NotLoaded.t()
              | nil,
            default_db_pool_size: non_neg_integer() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "msbms_syst"

  schema "syst_instance_type_contexts" do
    field(:default_db_pool_size, :integer)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime)
    field(:diag_role_modified, :string)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer)

    belongs_to(:instance_type, MsbmsSystEnums.Data.SystEnumItems, foreign_key: :instance_type_id)

    belongs_to(:application_context, MsbmsSystInstanceMgr.Data.SystApplicationContexts,
      foreign_key: :application_context_id
    )
  end

  @spec insert_changeset(MsbmsSystInstanceMgr.Types.instance_type_context_params()) ::
          Ecto.Changeset.t()
  def insert_changeset(insert_params) do
    %MsbmsSystInstanceMgr.Data.SystInstanceTypeContexts{}
    |> cast(insert_params, [
      :instance_type_id,
      :application_context_id,
      :default_db_pool_size
    ])
    |> validate_required([
      :instance_type_id,
      :application_context_id,
      :default_db_pool_size
    ])
  end

  @spec update_changeset(
          MsbmsSystInstanceMgr.Data.SystInstanceTypeContexts.t(),
          MsbmsSystInstanceMgr.Types.instance_type_context_params()
        ) ::
          Ecto.Changeset.t()
  def update_changeset(instance_type_context, update_params) do
    instance_type_context
    |> cast(update_params, [
      :default_db_pool_size
    ])
    |> validate_required([
      :instance_type_id,
      :application_context_id,
      :default_db_pool_size
    ])
    |> optimistic_lock(:diag_row_version)
  end
end
