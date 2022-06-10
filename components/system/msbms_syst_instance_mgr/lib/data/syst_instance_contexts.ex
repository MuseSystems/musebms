# Source File: syst_instance_contexts.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/data/syst_instance_contexts.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Data.SystInstanceContexts do
  use MsbmsSystDatastore.Schema

  import Ecto.Changeset
  import MsbmsSystInstanceMgr.Data.Helpers.OptionDefaults
  import MsbmsSystInstanceMgr.Data.Validators.General
  import MsbmsSystInstanceMgr.Data.Validators.SystInstanceContexts

  alias MsbmsSystInstanceMgr.Types

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
            internal_name: MsbmsSystInstanceMgr.Types.instance_context_name() | nil,
            instance_id: Ecto.UUID.t() | nil,
            instance:
              MsbmsSystInstanceMgr.Data.SystInstances.t()
              | Ecto.Association.NotLoaded.t()
              | nil,
            application_context_id: Ecto.UUID.t() | nil,
            application_context:
              MsbmsSystInstanceMgr.Data.SystApplicationContexts.t()
              | Ecto.Association.NotLoaded.t()
              | nil,
            start_context: boolean() | nil,
            db_pool_size: non_neg_integer() | nil,
            context_code: binary() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "msbms_syst"

  schema "syst_instance_contexts" do
    field(:internal_name, :string)
    field(:start_context, :boolean)
    field(:db_pool_size, :integer)
    field(:context_code, :binary)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime)
    field(:diag_role_modified, :string)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer)

    belongs_to(:instance, MsbmsSystInstanceMgr.Data.SystInstances, foreign_key: :instance_id)

    belongs_to(:application_context, MsbmsSystInstanceMgr.Data.SystApplicationContexts,
      foreign_key: :application_context_id
    )
  end

  @spec update_changeset(
          MsbmsSystInstanceMgr.Data.SystInstanceContexts.t(),
          Types.instance_context_params(),
          Keyword.t()
        ) :: Ecto.Changeset.t()
  def update_changeset(instance_context, update_params, opts \\ []) do
    opts = resolve_options(opts)

    instance_context
    |> cast(update_params, [
      :start_context,
      :db_pool_size,
      :context_code
    ])
    |> validate_context_code(opts)
    |> validate_required([
      :instance_id,
      :application_context_id,
      :start_context
    ])
    |> validate_number(:db_pool_size, greater_than_or_equal_to: 0)
  end
end
