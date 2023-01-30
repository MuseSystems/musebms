# Source File: mcp_bootstrap.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/lib/msdata_api/validators/mcp_bootstrap.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsdataApi.Validators.McpBootstrap do
  import Ecto.Changeset

  alias MsappMcp.Types

  @spec changeset(MsdataApi.McpBootstrap.t(), Types.mcp_bootstrap_params()) :: Ecto.Changeset.t()
  def changeset(mcp_bootstrap, change_params) do
    mcp_bootstrap
    |> cast(change_params, [
      :owner_name,
      :owner_display_name,
      :admin_access_account_display_name,
      :admin_identifier,
      :admin_credential,
      :admin_credential_verify
    ])
    |> validate_required([
      :owner_name,
      :owner_display_name,
      :admin_access_account_display_name,
      :admin_identifier,
      :admin_credential,
      :admin_credential_verify
    ])
    |> validate_length(:owner_name, min: 6, max: 6)
    |> validate_length(:owner_display_name, min: 3, max: 40)
    |> validate_length(:admin_access_account_display_name, min: 3, max: 40)
    |> validate_format(:admin_identifier, ~r/@/)
    |> validate_credential()
    |> validate_credential_verify()
  end

  defp validate_credential(changeset) do
    changeset
    |> get_change(:admin_credential)
    |> maybe_validate_password(changeset)
  end

  defp maybe_validate_password(nil, changeset), do: changeset
  defp maybe_validate_password("", changeset), do: changeset

  defp maybe_validate_password(password, changeset) do
    MssubMcp.get_global_password_rules!()
    |> MssubMcp.get_generic_password_rules()
    |> MssubMcp.test_credential(password)
    |> case do
      {:ok, []} ->
        changeset

      {:ok, validation_errors} ->
        validation_errors
        |> Enum.reduce(
          changeset,
          &add_error(&2, :admin_credential, password_violation_text(&1))
        )

      {:error, error} ->
        raise MscmpSystError,
          code: :undefined_error,
          message: "Failure testing Platform Administrator credentials.",
          cause: error
    end
  end

  # Note: a number of the rules below should not be possible
  # (e.g. :password_rule_recent_password).  However, inventive uses of the
  # system or later changes to the way this bootstrap process works might make
  # such a rule violation possible.  For security related stuff, just best to
  # be complete and cover all the cases... expected or not.

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

  defp validate_credential_verify(changeset) do
    password = get_change(changeset, :admin_credential)
    password_verify = get_change(changeset, :admin_credential_verify)

    if password == password_verify,
      do: changeset,
      else: add_error(changeset, :admin_credential_verify, "must match the password value")
  end
end
