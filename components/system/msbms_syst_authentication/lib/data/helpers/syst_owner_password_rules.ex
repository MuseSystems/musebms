# Source File: syst_owner_password_rules.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/helpers/syst_owner_password_rules.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.Helpers.SystOwnerPasswordRules do
  alias MsbmsSystAuthentication.Data.Helpers

  @moduledoc false

  def resolve_name_params(password_rule_params, _operation) do
    password_rule_params
    |> Helpers.General.resolve_owner_id()
  end
end
