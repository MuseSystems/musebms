# Source File: syst_instance_contexts.ex
# Location:    musebms/app_server/components/system/mscmp_syst_instance/lib/api/msdata/syst_instance_contexts.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystInstanceContexts do
  @moduledoc """
  Defines the data structure of the Application Context.

  Applications are written with certain security and connection characteristics
  in mind which correlate to database roles used by the application for
  establishing connections.  This data type defines the datastore contexts the
  application is expecting so that Instance records can be validated against the
  application expectations.

  Defined in `MscmpSystInstance`.
  """

  use MscmpSystDb.Schema

  alias MscmpSystInstance.Impl.Msdata.SystInstanceContexts.Validators
  alias MscmpSystInstance.Types

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: Types.instance_context_name() | nil,
            instance_id: Ecto.UUID.t() | nil,
            instance: Msdata.SystInstances.t() | Ecto.Association.NotLoaded.t() | nil,
            application_context_id: Ecto.UUID.t() | nil,
            application_context:
              Msdata.SystApplicationContexts.t() | Ecto.Association.NotLoaded.t() | nil,
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

  @schema_prefix "ms_syst"

  schema "syst_instance_contexts" do
    field(:internal_name, :string)
    field(:start_context, :boolean)
    field(:db_pool_size, :integer)
    field(:context_code, :binary)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)

    belongs_to(:instance, Msdata.SystInstances, foreign_key: :instance_id)

    belongs_to(:application_context, Msdata.SystApplicationContexts,
      foreign_key: :application_context_id
    )
  end

  @doc """
  Validates update Instance Context parameters for use in updating an existing
  Instance Context record.

  ## Parameters

    - `application_context`: The existing Instance Context struct to be
      updated.

    - `update_params`: A map containing the parameters for updating the
      Instance Context.

    - `opts`: Optional keyword list of validation options.

  ## Options

    #{Validators.get_update_changeset_opts_docs()}

  ## Returns

    An `Ecto.Changeset` struct representing the validation result.
  """
  @spec update_changeset(Msdata.SystInstanceContexts.t()) :: Ecto.Changeset.t()
  @spec update_changeset(Msdata.SystInstanceContexts.t(), Types.instance_context_params()) ::
          Ecto.Changeset.t()
  @spec update_changeset(
          Msdata.SystInstanceContexts.t(),
          Types.instance_context_params(),
          Keyword.t()
        ) :: Ecto.Changeset.t()
  defdelegate update_changeset(instance_context, update_params \\ %{}, opts \\ []), to: Validators
end
