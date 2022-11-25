# Source File: syst_global_password_rules.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/msdata/validators/syst_global_password_rules.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Msdata.Validators.SystGlobalPasswordRules do
  import Ecto.Changeset

  alias MscmpSystAuthn.Types

  alias MscmpSystDb.DbTypes

  @moduledoc false

  # The min and min/max password length constraints are derived from
  # NIST SP800-63B.  The absolute max constraint is an arbitrarily chosen value.
  #
  # TODO: Consider making these compile time configs since they are defined in
  #       multiple modules.

  @min_password_length 8
  @min_max_password_length 64
  @max_password_length 1024

  @spec update_changeset(Msdata.SystGlobalPasswordRules.t(), Types.password_rule_params()) ::
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
      :disallow_compromised,
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
      :disallow_compromised,
      :require_mfa,
      :allowed_mfa_types
    ])
    |> validate_password_length_min()
    |> validate_password_length_mix_max()
    |> validate_password_length_max()
    |> optimistic_lock(:diag_row_version)
  end

  defp validate_password_length_min(changeset) do
    password_length = get_field(changeset, :password_length)

    case DbTypes.Range.bounds_compare(@min_password_length, password_length) do
      %{lower_comparison: :gt} ->
        add_error(
          changeset,
          :password_length,
          "Password minimum length must be at least #{@min_password_length} characters."
        )

      _ ->
        changeset
    end
  end

  defp validate_password_length_mix_max(changeset) do
    password_length = get_field(changeset, :password_length)

    case DbTypes.Range.bounds_compare(@min_max_password_length, password_length) do
      %{upper_comparison: :gt} ->
        add_error(
          changeset,
          :password_length,
          "Password min. max. length must be at least #{@min_max_password_length} characters."
        )

      _ ->
        changeset
    end
  end

  defp validate_password_length_max(changeset) do
    password_length = get_field(changeset, :password_length)

    case DbTypes.Range.bounds_compare(@max_password_length, password_length) do
      %{upper_comparison: :lt} ->
        add_error(
          changeset,
          :password_length,
          "Password max length must be no more than #{@max_password_length} characters."
        )

      _ ->
        changeset
    end
  end
end
