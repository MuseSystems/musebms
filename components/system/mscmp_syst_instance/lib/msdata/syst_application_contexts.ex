# Source File: syst_application_contexts.ex
# Location:    musebms/components/system/mscmp_syst_instance/lib/msdata/syst_application_contexts.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystApplicationContexts do
  use MscmpSystDb.Schema

  alias MscmpSystInstance.Msdata.Validators
  alias MscmpSystInstance.Types

  @moduledoc """
  Defines the data structure of the Application Context.

  Applications are written with certain security and connection characteristics
  in mind which correlate to database roles used by the application for
  establishing connections.  This data type defines the Datastore contexts the
  application is expecting so that Instance records can be validated against the
  application expectations.

  Defined in `MscmpSystInstance`.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: Types.application_context_name() | nil,
            display_name: String.t() | nil,
            application_id: Ecto.UUID.t() | nil,
            application: Msdata.SystApplications.t() | Ecto.Association.NotLoaded.t() | nil,
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

  @schema_prefix "ms_syst"

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

    belongs_to(:application, Msdata.SystApplications)
  end

  @doc """
  Validates presented Application Context parameters for inserting a new
  Application Context record.
  """
  @spec insert_changeset(Types.application_context_params(), Keyword.t()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(insert_params, opts \\ []), to: Validators.SystApplicationContexts

  @doc """
  Validates update Application Context parameters for use in updating an
  existing Application Context record.
  """
  @spec update_changeset(
          Msdata.SystApplicationContexts.t(),
          Types.application_context_params(),
          Keyword.t()
        ) :: Ecto.Changeset.t()
  defdelegate update_changeset(application_context, update_params, opts \\ []),
    to: Validators.SystApplicationContexts
end
