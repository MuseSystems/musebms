# Source File: syst_instances.ex
# Location:    musebms/app_server/components/system/mscmp_syst_instance/lib/api/msdata/syst_instances.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystInstances do
  @moduledoc """
  Data definition describing known application Instances.

  Defined in `MscmpSystInstance`.
  """

  use MscmpSystDb.Schema

  alias MscmpSystInstance.Impl.Msdata.SystInstances.Validators
  alias MscmpSystInstance.Types

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: Types.instance_name() | nil,
            display_name: String.t() | nil,
            application_id: Ecto.UUID.t() | nil,
            application: Msdata.SystApplications.t() | Ecto.Association.NotLoaded.t() | nil,
            instance_type_id: Ecto.UUID.t() | nil,
            instance_type: Msdata.SystEnumItems.t() | Ecto.Association.NotLoaded.t() | nil,
            instance_state_id: Ecto.UUID.t() | nil,
            instance_state: Msdata.SystEnumItems.t() | Ecto.Association.NotLoaded.t() | nil,
            owner_id: Ecto.UUID.t() | nil,
            owner: Msdata.SystOwners.t() | Ecto.Association.NotLoaded.t() | nil,
            owning_instance_id: Ecto.UUID.t() | nil,
            owning_instance: Msdata.SystInstances.t() | Ecto.Association.NotLoaded.t() | nil,
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

  @schema_prefix "ms_syst"

  schema "syst_instances" do
    field(:internal_name, :string)
    field(:display_name, :string)
    field(:dbserver_name, :string)
    field(:instance_code, :binary)
    field(:instance_options, :map)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)

    belongs_to(:application, Msdata.SystApplications)
    belongs_to(:instance_type, Msdata.SystEnumItems)
    belongs_to(:instance_state, Msdata.SystEnumItems)
    belongs_to(:owner, Msdata.SystOwners)
    belongs_to(:owning_instance, Msdata.SystInstances)

    has_many(:owned_instances, Msdata.SystInstances, foreign_key: :owning_instance_id)

    has_many(:instance_contexts, Msdata.SystInstanceContexts, foreign_key: :instance_id)
  end

  @doc """
  Creates a changeset for inserting a new Instance record.

  ## Parameters

    - `insert_params`: A map of parameters for creating a new Instance.

    - `opts`: Optional keyword list of options.

  ## Options

    #{Validators.get_insert_changeset_opts_docs()}

  ## Returns

  An `t:Ecto.Changeset.t/0` for the new Instance.
  """
  @spec insert_changeset(Types.instance_params()) :: Ecto.Changeset.t()
  @spec insert_changeset(Types.instance_params(), Keyword.t()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(insert_params, opts \\ []), to: Validators

  @doc """
  Creates a changeset for updating an existing Instance record.

  ## Parameters

    - `instance`: The existing Instance to update.

    - `update_params`: A map of parameters to update the Instance.

    - `opts`: Optional keyword list of options.

  ## Options

    #{Validators.get_update_changeset_opts_docs()}

  ## Returns

  An `t:Ecto.Changeset.t/0` for the updated Instance.
  """
  @spec update_changeset(Msdata.SystInstances.t()) :: Ecto.Changeset.t()
  @spec update_changeset(Msdata.SystInstances.t(), Types.instance_params()) :: Ecto.Changeset.t()
  @spec update_changeset(Msdata.SystInstances.t(), Types.instance_params(), Keyword.t()) ::
          Ecto.Changeset.t()
  defdelegate update_changeset(instance, update_params \\ %{}, opts \\ []), to: Validators
end
