# Source File: syst_password_history.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/syst_password_history.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.SystPasswordHistory do
  use MsbmsSystDatastore.Schema

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Types

  @moduledoc """
  A history of previous user passwords credentials kept for the purpose of
  enforcing the reused password exclusion rule.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            access_account_id: Types.access_account_id() | nil,
            access_account: Data.SystAccessAccounts.t() | Ecto.Association.NotLoaded.t() | nil,
            credential_data: String.t() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "msbms_syst"

  schema "syst_password_history" do
    field(:credential_data, :string)
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime)
    field(:diag_role_modified, :string)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer)

    belongs_to(:access_account, Data.SystAccessAccounts)
  end
end
