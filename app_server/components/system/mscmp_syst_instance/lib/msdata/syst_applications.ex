# Source File: syst_applications.ex
# Location:    musebms/components/system/mscmp_syst_instance/lib/msdata/syst_applications.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystApplications do
  use MscmpSystDb.Schema

  alias MscmpSystInstance.Msdata.Validators
  alias MscmpSystInstance.Types

  @moduledoc """
  Data structure describing the known applications for which instances may be
  hosted.

  Defined in `MscmpSystInstance`.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: Types.application_name() | nil,
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

  @schema_prefix "ms_syst"

  schema "syst_applications" do
    field(:internal_name, :string)
    field(:display_name, :string)
    field(:syst_description, :string)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)

    has_many(:instances, Msdata.SystInstances, foreign_key: :application_id)

    has_many(:application_contexts, Msdata.SystApplicationContexts, foreign_key: :application_id)
  end

  @doc """
  Validates presented Application parameters for inserting a new Application
  record.
  """
  @spec insert_changeset(Types.application_params(), Keyword.t()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(insert_params, opts \\ []), to: Validators.SystApplications

  @doc """
  Validates update Application parameters for use in updating an existing
  Application record.
  """
  @spec update_changeset(Msdata.SystApplications.t(), Types.application_params(), Keyword.t()) ::
          Ecto.Changeset.t()
  defdelegate update_changeset(application, update_params, opts \\ []),
    to: Validators.SystApplications
end
