# Source File: syst_instance_type_applications.ex
# Location:    musebms/app_server/components/system/mscmp_syst_instance/lib/api/msdata/syst_instance_type_applications.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystInstanceTypeApplications do
  @moduledoc """
  Associates SystApplications to SystInstanceTypes.

  The idea expressed here is that an Instance Type may support only a subset of
  the Applications known to the system.

  Defined in `MscmpSystInstance`.
  """

  use MscmpSystDb.Schema

  alias MscmpSystInstance.Impl.Msdata.SystInstanceTypeApplications.Validators
  alias MscmpSystInstance.Types

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            instance_type_id: Ecto.UUID.t() | nil,
            instance_type: Msdata.SystEnumItems.t() | Ecto.Association.NotLoaded.t() | nil,
            application_id: Ecto.UUID.t() | nil,
            application: Msdata.SystApplications.t() | Ecto.Association.NotLoaded.t() | nil,
            instance_type_contexts:
              Msdata.SystInstanceTypeContexts.t() | Ecto.Association.NotLoaded.t() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "ms_syst"

  schema "syst_instance_type_applications" do
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)

    belongs_to(:instance_type, Msdata.SystEnumItems, foreign_key: :instance_type_id)

    belongs_to(:application, Msdata.SystApplications, foreign_key: :application_id)

    has_many(:instance_type_contexts, Msdata.SystInstanceTypeContexts,
      foreign_key: :instance_type_application_id
    )
  end

  @spec insert_changeset(Types.instance_type_application_params()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(insert_params), to: Validators
end
