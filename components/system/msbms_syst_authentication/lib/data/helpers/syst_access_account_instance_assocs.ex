# Source File: syst_access_account_instance_assocs.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/helpers/syst_access_account_instance_assocs.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.Helpers.SystAccessAccountInstanceAssocs do
  @moduledoc false

  alias MsbmsSystAuthentication.Data.Helpers

  def resolve_name_params(change_params, operation) do
    change_params
    |> Helpers.General.resolve_access_account_id()
    |> Helpers.General.resolve_instance_id()
  end
end
