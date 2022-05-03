# Source File: syst_applications.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/data/syst_applications.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Data.SystApplications do
  use MsbmsSystDatastore.Schema

  @moduledoc """
  Data structure describing the known applications for which instances may be
  hosted.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: MsbmsSystInstanceMgr.Types.application_name() | nil,
            display_name: String.t() | nil,
            syst_description: String.t() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "msbms_syst"

  schema "syst_applications" do
    field(:internal_name, :string)
    field(:display_name, :string)
    field(:syst_description, :string)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime)
    field(:diag_role_modified, :string)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer)

    has_many(:instances, MsbmsSystInstanceMgr.Data.SystInstances, foreign_key: :application_id)
  end

  # Note that there are no changeset functions here because the only way to add
  # new applications at this point is via the datastore migrations process.
end
