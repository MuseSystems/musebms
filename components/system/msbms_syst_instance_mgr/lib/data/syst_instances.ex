# Source File: syst_instances.ex
# Location:    musebms/components/system/msbms_syst_instance_mgr/lib/data/syst_instances.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystInstanceMgr.Data.SystInstances do
  use MsbmsSystDatastore.Schema

  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Types

  @moduledoc """
  Data definition describing known application Instances.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: Types.instance_name() | nil,
            display_name: String.t() | nil,
            application_id: Ecto.UUID.t() | nil,
            application: Data.SystApplications.t() | Ecto.Association.NotLoaded.t() | nil,
            instance_type_id: Ecto.UUID.t() | nil,
            instance_type:
              MsbmsSystEnums.Data.SystEnumItems.t() | Ecto.Association.NotLoaded.t() | nil,
            instance_state_id: Ecto.UUID.t() | nil,
            instance_state:
              MsbmsSystEnums.Data.SystEnumItems.t() | Ecto.Association.NotLoaded.t() | nil,
            owner_id: Ecto.UUID.t() | nil,
            owner: Data.SystOwners.t() | Ecto.Association.NotLoaded.t() | nil,
            owning_instance_id: Ecto.UUID.t() | nil,
            owning_instance: Data.SystInstances.t() | Ecto.Association.NotLoaded.t() | nil,
            dbserver_name: String.t() | nil,
            instance_code: binary() | nil,
            instance_options: map() | nil,
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
    field(:instance_code, :binary)
    field(:instance_options, :map)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime)
    field(:diag_role_modified, :string)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer)

    belongs_to(:application, Data.SystApplications)
    belongs_to(:instance_type, MsbmsSystEnums.Data.SystEnumItems)
    belongs_to(:instance_state, MsbmsSystEnums.Data.SystEnumItems)
    belongs_to(:owner, Data.SystOwners)
    belongs_to(:owning_instance, Data.SystInstances)

    has_many(:owned_instances, Data.SystInstances, foreign_key: :owning_instance_id)

    has_many(:instance_contexts, Data.SystInstanceContexts, foreign_key: :instance_id)
  end

  @spec insert_changeset(Types.instance_params(), Keyword.t()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(insert_params, opts \\ []), to: Data.Validators.SystInstances

  @spec update_changeset(Data.SystInstances.t(), Types.instance_params(), Keyword.t()) ::
          Ecto.Changeset.t()
  defdelegate update_changeset(instance, update_params \\ %{}, opts \\ []),
    to: Data.Validators.SystInstances
end
