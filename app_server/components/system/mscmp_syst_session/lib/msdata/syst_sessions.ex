# Source File: syst_sessions.ex
# Location:    musebms/app_server/components/system/mscmp_syst_session/lib/msdata/syst_sessions.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystSessions do
  use MscmpSystDb.Schema

  alias MscmpSystSession.Msdata.Validators
  alias MscmpSystSession.Types

  @moduledoc """
  User interface session data.
  """

  @moduledoc tags: [:mscmp_syst_session]

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            internal_name: Types.session_name() | nil,
            session_data: map() | nil,
            session_expires: DateTime.t() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "ms_syst"

  schema "syst_sessions" do
    field(:internal_name, :string)
    field(:session_data, :map)
    field(:session_expires, :utc_datetime)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)
  end

  @spec insert_changeset(Types.session_params()) :: Ecto.Changeset.t()
  defdelegate insert_changeset(insert_params), to: Validators.SystSessions

  @spec update_changeset(Msdata.SystSessions.t(), Types.session_params()) :: Ecto.Changeset.t()
  defdelegate update_changeset(session, update_params), to: Validators.SystSessions
end
