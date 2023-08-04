# Source File: data.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/msform/auth_password_reset/data.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msform.AuthPasswordReset.Data do
  import Ecto.Changeset

  alias Msform.AuthPasswordReset.Types

  @spec validate_save(Msform.AuthPasswordReset.t(), Types.parameters()) :: Ecto.Changeset.t()
  def validate_save(original_data, current_data),
    do: validate_post(original_data, current_data)

  @spec validate_post(Msform.AuthPasswordReset.t(), Types.parameters()) :: Ecto.Changeset.t()
  def validate_post(original_data, current_data) do
    original_data
    |> cast(current_data, [:credential, :new_credential, :verify_credential])
    |> validate_required([:credential, :new_credential, :verify_credential])
    |> validate_credential()
    |> validate_current_new_different()
    |> validate_credential_verify()
  end

  defp validate_credential(changeset) do
    password = get_change(changeset, :new_credential)
    access_account_id = get_field(changeset, :access_account_id)
    maybe_validate_password(access_account_id, password, changeset)
  end

  defp maybe_validate_password(_, nil, changeset), do: changeset
  defp maybe_validate_password(_, "", changeset), do: changeset

  defp maybe_validate_password(access_account_id, password, changeset) do
    access_account_id
    |> MssubMcp.test_credential(password)
    |> case do
      {:ok, []} ->
        changeset

      {:ok, validation_errors} ->
        validation_errors
        |> Enum.reduce(
          changeset,
          &add_error(&2, :new_credential, password_violation_text(&1))
        )

      {:error, error} ->
        IO.inspect(error, label: :maybe_validate_password_error)

        raise MscmpSystError,
          code: :undefined_error,
          message: "Failure testing password credentials.",
          cause: error
    end
  end

  defp password_violation_text({:password_rule_length_min, value}),
    do: "should be at least #{value} character(s)"

  defp password_violation_text({:password_rule_length_max, value}),
    do: "should be at least #{value} character(s)"

  defp password_violation_text({:password_rule_required_upper, value}),
    do: "must have #{value} upper case characters"

  defp password_violation_text({:password_rule_required_lower, value}),
    do: "must have #{value} lower case characters"

  defp password_violation_text({:password_rule_required_numbers, value}),
    do: "must have #{value} numeric characters"

  defp password_violation_text({:password_rule_required_symbols, value}),
    do: "must have #{value} symbol characters"

  defp password_violation_text({:password_rule_disallowed_password, _value}),
    do: "password has been disallowed"

  defp password_violation_text({:password_rule_recent_password, _value}),
    do: "password used too recently"

  # This is required so that a password reset to the same password doesn't cause
  # a forced credential reset to be valid without an actual change of 
  # credential.  Other than for this case, we wouldn't care unless a password
  # rule demanded no credential reuse.

  defp validate_current_new_different(changeset) do
    password = get_change(changeset, :credential)
    password_new = get_change(changeset, :new_credential)

    unless password == password_new,
      do: changeset,
      else: add_error(changeset, :new_credential, "must be different from current password")
  end

  defp validate_credential_verify(changeset) do
    password_new = get_change(changeset, :new_credential)
    password_verify = get_change(changeset, :verify_credential)

    if password_new == password_verify,
      do: changeset,
      else: add_error(changeset, :verify_credential, "must match the password value")
  end
end
