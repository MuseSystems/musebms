# Source File: syst_credentials.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/helpers/syst_credentials.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.Helpers.SystCredentials do
  alias MsbmsSystAuthentication.Data.Helpers

  @moduledoc false

  def resolve_name_params(change_params, operation) do
    change_params
    |> Helpers.General.resolve_access_account_id()
    |> Helpers.General.resolve_credential_type_id(operation)
  end
end
