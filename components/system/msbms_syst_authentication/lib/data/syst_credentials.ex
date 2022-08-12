# Source File: syst_credentials.ex
# Location:    components/system/msbms_syst_authentication/lib/data/syst_credentials.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystAuthentication.Data.SystCredentials do
  use MsbmsSystDatastore.Schema

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Types

  @moduledoc """
  Hosts the credentials by which a user or external system will prove its
  identity.

  Note that not all credential types are available for authentication with all
  identity types.
  """

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            access_account_id: Types.access_account_id() | nil,
            access_account: Data.SystAccessAccounts.t() | Ecto.Association.NotLoaded.t() | nil,
            credential_type_id: Types.credential_type_id() | nil,
            credential_type: Data.SystCredential.t() | Ecto.Association.NotLoaded.t() | nil,
            credential_for_identity_id: Types.identity_id() | nil,
            credential_for_identity: Data.SystIdentity.t() | Ecto.Association.NotLoaded.t() | nil,
            credential_data: String.t() | nil,
            last_updated: DateTime.t() | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }
end
