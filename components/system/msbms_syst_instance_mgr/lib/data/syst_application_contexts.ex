# Source File: syst_application_contexts.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/data/syst_application_contexts.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Data.SystApplicationContexts do
  use MsbmsSystDatastore.Schema
  import Ecto.Changeset

  @moduledoc """
  Defines the data structure of the Application Context.

  Applications are written with certain security and connection characteristics
  in mind which correlate to database roles used by the application for
  establishing connections.  This data type defines the datastore contexts the
  application is expecting so that Instance records can be validated against the
  application expectations.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: MsbmsSystInstanceMgr.Types.application_context_name() | nil,
            display_name: String.t() | nil,
            application_id: Ecto.UUID.t() | nil,
            application:
              MsbmsSystInstanceMgr.Data.SystApplications.t()
              | Ecto.Association.NotLoaded.t()
              | nil,
            description: String.t() | nil,
            start_context: boolean() | nil,
            login_context: boolean() | nil,
            database_owner_context: boolean() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "msbms_syst"

  schema "syst_application_contexts" do
    field(:internal_name, :string)
    field(:display_name, :string)
    field(:description, :string)
    field(:start_context, :boolean)
    field(:login_context, :boolean)
    field(:database_owner_context, :boolean)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime)
    field(:diag_role_modified, :string)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer)

    belongs_to(:application, MsbmsSystInstanceMgr.Data.SystApplications)
  end

  @spec update_changeset(MsbmsSystInstanceMgr.Data.SystApplicationContexts.t(), boolean()) ::
          Ecto.Changeset.t()
  def update_changeset(application_context, start_context) when is_boolean(start_context) do
    application_context
    |> cast(%{start_context: start_context}, [:start_context])
    |> validate_required([:start_context])
    |> optimistic_lock(:diag_row_version)
  end
end
