# Source File: syst_global_password_rules.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/validators/syst_global_password_rules.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.Validators.SystGlobalPasswordRules do
  import Ecto.Changeset

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Types

  @moduledoc false

  @spec update_changeset(Data.SystGlobalPasswordRules.t(), Types.password_rule_params()) ::
          Ecto.Changeset.t()
  def update_changeset(global_password_rule, update_params) do
    global_password_rule
    |> cast(update_params, [
      :password_length,
      :max_age,
      :require_upper_case,
      :require_lower_case,
      :require_numbers,
      :require_symbols,
      :disallow_recently_used,
      :disallow_known_compromised,
      :require_mfa,
      :allowed_mfa_types
    ])
    |> validate_required([
      :password_length,
      :max_age,
      :require_upper_case,
      :require_lower_case,
      :require_numbers,
      :require_symbols,
      :disallow_recently_used,
      :disallow_known_compromised,
      :require_mfa,
      :allowed_mfa_types
    ])
    |> optimistic_lock(:diag_row_version)
  end
end
