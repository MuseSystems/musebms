# Source File: syst_owner_password_rules.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/validators/syst_owner_password_rules.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.Validators.SystOwnerPasswordRules do
  import Ecto.Changeset

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Data.Helpers
  alias MsbmsSystAuthentication.Types

  @moduledoc false

  @spec insert_changeset(Types.password_rule_params()) ::
          Ecto.Changeset.t()
  def insert_changeset(insert_params) do
    resolved_insert_params =
      Helpers.SystOwnerPasswordRules.resolve_name_params(insert_params, :insert)

    %Data.SystOwnerPasswordRules{}
    |> cast(resolved_insert_params, [
      :owner_id,
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
    |> validate_common()
    |> optimistic_lock(:diag_row_version)
  end

  @spec update_changeset(Data.SystOwnerPasswordRules.t(), Types.password_rule_params()) ::
          Ecto.Changeset.t()
  def update_changeset(owner_password_rule, update_params) do
    owner_password_rule
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
    |> validate_common()
    |> optimistic_lock(:diag_row_version)
  end

  defp validate_common(changeset) do
    validate_required(changeset, [
      :owner_id,
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
  end
end
