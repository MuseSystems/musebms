# Source File: syst_instance_type_applications.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/data/syst_instance_type_applications.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Data.SystInstanceTypeApplications do
  use MsbmsSystDatastore.Schema

  import Ecto.Changeset

  alias MsbmsSystInstanceMgr.Types

  @moduledoc """
  Associates SystApplications to SystInstanceTypes.

  The idea expressed here is that an Instance Type may support only a subset of
  the Applications known to the system.
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
            application_id: Ecto.UUID.t() | nil,
            application:
              MsbmsSystInstanceMgr.Data.SystApplications.t()
              | Ecto.Association.NotLoaded.t()
              | nil,
            instance_type_contexts:
              MsbmsSystInstanceMgr.Data.SystInstanceTypeContexts.t()
              | Ecto.Association.NotLoaded.t()
              | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "msbms_syst"

  schema "syst_instance_type_applications" do
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime)
    field(:diag_role_modified, :string)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer)

    belongs_to(:instance_type, MsbmsSystEnums.Data.SystEnumItems, foreign_key: :instance_type_id)

    belongs_to(:application, MsbmsSystInstanceMgr.Data.SystApplications,
      foreign_key: :application_id
    )

    has_many(:instance_type_contexts, MsbmsSystInstanceMgr.Data.SystInstanceTypeContexts,
      foreign_key: :instance_type_application_id
    )
  end

  @spec insert_changeset(Types.instance_type_application_params()) :: Ecto.Changeset.t()
  def insert_changeset(instance_type_application_params) do
    %MsbmsSystInstanceMgr.Data.SystInstanceTypeApplications{}
    |> cast(instance_type_application_params, [:instance_type_id, :application_id])
    |> validate_required([:instance_type_id, :application_id])
  end
end
