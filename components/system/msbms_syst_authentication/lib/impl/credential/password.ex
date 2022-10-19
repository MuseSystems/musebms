# Source File: password.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/impl/credential/password.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Impl.Credential.Password do
  import Ecto.Query

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl
  alias MsbmsSystAuthentication.Types

  alias MsbmsSystDatastore.DbTypes

  require Logger

  @behaviour MsbmsSystAuthentication.Impl.Credential

  @moduledoc false

  @spec test_credential(Types.access_account_id() | Types.password_rule(), Types.credential()) ::
          Keyword.t(Types.password_rule_violations())
  def test_credential(access_account_id, pwd_plaintext)
      when is_binary(access_account_id) do
    access_account_id
    |> Impl.PasswordRules.get_access_account_password_rule()
    |> test_credential(pwd_plaintext)
  end

  def test_credential(%{access_account_id: _} = pwd_rules, pwd_plaintext) do
    []
    |> verify_password_length(pwd_rules, pwd_plaintext)
    |> verify_password_req_upper_case(pwd_rules, pwd_plaintext)
    |> verify_password_req_lower_case(pwd_rules, pwd_plaintext)
    |> verify_password_req_numbers(pwd_rules, pwd_plaintext)
    |> verify_password_req_symbols(pwd_rules, pwd_plaintext)
    |> verify_password_no_compromised(pwd_rules, pwd_plaintext)
    |> verify_password_recently_used(pwd_rules, pwd_plaintext)
  end

  defp verify_password_length(violations_list, pwd_rules, pwd_text) do
    length_rule = pwd_rules.password_length
    compare_result = DbTypes.Range.bounds_compare(String.length(pwd_text), length_rule)

    violations_list
    |> verify_min_length(compare_result, DbTypes.Range.lower(length_rule))
    |> verify_max_length(compare_result, DbTypes.Range.upper(length_rule))
  end

  defp verify_min_length(violations_list, %{lower_comparison: :lt}, min_length),
    do: [{:password_rule_length_min, min_length} | violations_list]

  defp verify_min_length(violations_list, _, _), do: violations_list

  defp verify_max_length(violations_list, %{upper_comparison: :gt}, max_length),
    do: [{:password_rule_length_max, max_length} | violations_list]

  defp verify_max_length(violations_list, _, _), do: violations_list

  defp verify_password_req_upper_case(violations_list, pwd_rules, pwd_text) do
    if count_requirement_met(~r/[^[:upper:]]/u, pwd_rules.require_upper_case, pwd_text) do
      violations_list
    else
      [{:password_rule_required_upper, pwd_rules.require_upper_case} | violations_list]
    end
  end

  defp verify_password_req_lower_case(violations_list, pwd_rules, pwd_text) do
    if count_requirement_met(~r/[^[:lower:]]/u, pwd_rules.require_lower_case, pwd_text) do
      violations_list
    else
      [{:password_rule_required_lower, pwd_rules.require_lower_case} | violations_list]
    end
  end

  defp verify_password_req_numbers(violations_list, pwd_rules, pwd_text) do
    if count_requirement_met(~r/[^[:digit:]]/u, pwd_rules.require_numbers, pwd_text) do
      violations_list
    else
      [{:password_rule_required_numbers, pwd_rules.require_numbers} | violations_list]
    end
  end

  defp verify_password_req_symbols(violations_list, pwd_rules, pwd_text) do
    # TODO: The regex below could probably be more precise.  I think there are
    #       some emoji, for example, that get excluded from the count; all the
    #       emoji I informally tested were caught, but word has it that some
    #       may be missed.  For now the net seems sufficiently wide to cover the
    #       expected common cases so let's not over-bake this until reason pops
    #       up to do so.

    if count_requirement_met(~r/[^\p{So}|[:punct:]]/u, pwd_rules.require_symbols, pwd_text) do
      violations_list
    else
      [{:password_rule_required_symbols, pwd_rules.require_symbols} | violations_list]
    end
  end

  defp count_requirement_met(_expression, 0 = _required, _pwd_text), do: true

  defp count_requirement_met(expression, required, pwd_text) do
    count = Regex.replace(expression, pwd_text, "") |> String.length()

    count >= required
  end

  # Prefer to call verify_password_no_compromised/3 near the end of the password
  # verification process.  It will not make the relatively expensive database
  # search if some prior criteria was violated.  This call is expected to be
  # less expensive than verify_password_recently_used/4 and so should be called
  # before verify_password_recently_used/4, but after all others.
  defp verify_password_no_compromised(violations_list, pwd_rules, pwd_text) do
    violation_found =
      pwd_rules.disallow_compromised && violations_list == [] && check_compromised_pwd(pwd_text)

    if violation_found do
      [{:password_rule_disallowed_password, true} | violations_list]
    else
      violations_list
    end
  end

  # Prefer to call verify_password_recently_used/4 at the end of the password
  # verification process.  It will not make the relatively expensive database
  # search if some prior criteria was violated.  This call is expected to be
  # more expensive than verify_password_no_compromised/3 and so should be run
  # after that function.
  defp verify_password_recently_used(violations_list, pwd_rules, pwd_text) do
    %{access_account_id: access_account_id} = pwd_rules

    violation_found =
      pwd_rules.disallow_compromised && violations_list == [] &&
        check_recent_pwd(access_account_id, pwd_text)

    if violation_found do
      [{:password_rule_recent_password, true} | violations_list]
    else
      violations_list
    end
  end

  defp check_recent_pwd(access_account_id, pwd_text) do
    from(ph in Data.SystPasswordHistory,
      where: ph.access_account_id == ^access_account_id,
      select: ph.credential_data
    )
    |> MsbmsSystDatastore.all()
    |> Enum.reduce(false, fn hash, found ->
      found || Impl.Hash.verify_credential_hash(hash, pwd_text)
    end)
  end

  @spec confirm_credential(
          Types.access_account_id(),
          Types.identity_id() | nil,
          Types.credential()
        ) ::
          Types.credential_confirm_result()
  def confirm_credential(access_account_id, _identity_id \\ nil, pwd_text) do
    cred = get_credential_record(access_account_id)

    credential_state = get_credential_state(cred, pwd_text)

    credential_extended_state =
      maybe_get_extended_confirmation_state(credential_state, cred, pwd_text)

    {credential_state, credential_extended_state}
  end

  defp get_credential_state(cred, pwd_text) do
    with :ok <- maybe_confirm_credential_exists(cred),
         :ok <- maybe_confirm_password_hash(cred, pwd_text) do
      :confirmed
    end
  end

  defp maybe_get_extended_confirmation_state(:confirmed = _credential_state, cred, pwd_text) do
    pwd_rules = Impl.PasswordRules.get_access_account_password_rule(cred.access_account_id)

    []
    |> maybe_require_mfa(pwd_rules)
    |> maybe_get_reset_reason(cred, pwd_rules, pwd_text)
  end

  defp maybe_get_extended_confirmation_state(_credential_state, _cred, _pwd_text), do: []

  defp maybe_get_reset_reason(extended_state, cred, pwd_rules, pwd_text) do
    # Checks below are ordered by cost; only return the cheapest reset reason
    # since a reset will have to satisfy all other possible issues below anyway.
    with :ok <- maybe_confirm_force_reset(cred),
         :ok <- maybe_confirm_rule_password_age(pwd_rules, cred),
         :ok <- maybe_confirm_rule_disallowed(pwd_rules, pwd_text) do
      extended_state
    else
      reset_reason -> [reset_reason | extended_state]
    end
  end

  # Reject if the credential doesn't exist as not to disclose that setting it is
  # pending.  The principle should be that we only disclose a more detailed
  # result once we have some sort of positive authentication.
  defp maybe_confirm_credential_exists(%Data.SystCredentials{}), do: :ok
  defp maybe_confirm_credential_exists(_), do: :no_credential

  defp maybe_confirm_password_hash(cred, pwd_text) do
    hash_verified = Impl.Hash.verify_credential_hash(cred.credential_data, pwd_text)

    if hash_verified, do: :ok, else: :wrong_credential
  end

  defp maybe_confirm_force_reset(%{force_reset: force_reset}) when is_nil(force_reset), do: :ok
  defp maybe_confirm_force_reset(_), do: :reset_forced

  defp maybe_confirm_rule_password_age(
         %{max_age: %DbTypes.Interval{months: 0, days: 0, secs: 0, microsecs: 0}},
         _
       ),
       do: :ok

  defp maybe_confirm_rule_password_age(rules, cred) do
    bypass_check = DbTypes.compare(rules.max_age, %DbTypes.Interval{}) == :eq
    shift_by = DbTypes.Interval.to_timex_shift_options(rules.max_age)
    last_valid_date = Timex.shift(cred.last_updated, shift_by)
    still_valid = Date.compare(Date.utc_today(), last_valid_date) in [:lt, :eq]

    if bypass_check or still_valid, do: :ok, else: :reset_age
  end

  defp maybe_confirm_rule_disallowed(%{disallow_compromised: true}, pwd_text) do
    pwd_disallowed = check_compromised_pwd(pwd_text)

    if pwd_disallowed, do: :reset_disallowed, else: :ok
  end

  defp maybe_confirm_rule_disallowed(_rules, _pwd_text), do: :ok

  defp maybe_require_mfa(extended_state, %{require_mfa: true}),
    do: [:require_mfa | extended_state]

  defp maybe_require_mfa(extended_state, _rules), do: extended_state

  defp check_compromised_pwd(pwd_text) do
    pwd_hash = Impl.Hash.weak_hash(pwd_text)

    from(dp in Data.SystDisallowedPasswords, where: dp.password_hash == ^pwd_hash)
    |> MsbmsSystDatastore.exists?()
  end

  @spec set_credential(
          Types.access_account_id(),
          Types.identity_id() | nil,
          Types.credential(),
          Keyword.t()
        ) ::
          {:ok, nil} | Types.credential_set_failures() | {:error, MsbmsSystError.t()}
  def set_credential(access_account_id, _identity_id \\ nil, pwd_text, _opts) do
    with :ok <- maybe_test_credential(access_account_id, pwd_text) do
      cred = get_credential_record(access_account_id)
      set_credential_data(cred, access_account_id, pwd_text)
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure setting Password Credential.",
          cause: error
        }
      }
  end

  defp maybe_test_credential(access_account_id, pwd_text) do
    test_result = test_credential(access_account_id, pwd_text)

    if test_result == [], do: :ok, else: {:invalid_credential, test_result}
  end

  # TODO: set_credential_data/3 could be simplified via an upsert type
  #       DML action, but currently PostgreSQL 14 doesn't allow us to create the
  #       correct uniqueness constraint.  PostgreSQL 15 is suppose to add a
  #       feature which would make this possible and so the function below may
  #       be worth revisiting at that time.

  defp set_credential_data(nil = _cred, access_account_id, pwd_text) do
    %{id: credential_type_id} =
      MsbmsSystEnums.get_enum_item_by_name("credential_types", "credential_types_sysdef_password")

    password_hash = Impl.Hash.create_credential_hash(pwd_text)

    %{
      access_account_id: access_account_id,
      credential_type_id: credential_type_id,
      credential_data: password_hash
    }
    |> Data.SystCredentials.insert_changeset()
    |> MsbmsSystDatastore.insert!()

    {:ok, nil}
  end

  defp set_credential_data(cred, _access_account_id, pwd_text) do
    password_hash = Impl.Hash.create_credential_hash(pwd_text)

    cred
    |> Data.SystCredentials.update_changeset(%{credential_data: password_hash})
    |> MsbmsSystDatastore.update!()

    {:ok, nil}
  end

  @spec get_credential_record(Types.access_account_id(), Types.identity_id() | nil) ::
          Data.SystCredentials.t() | nil
  def get_credential_record(access_account_id, _identity_id \\ nil) do
    from(
      c in Data.SystCredentials,
      join: ct in assoc(c, :credential_type),
      where:
        ct.internal_name == "credential_types_sysdef_password" and
          c.access_account_id == ^access_account_id,
      select: c
    )
    |> MsbmsSystDatastore.one()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving Password Credential record.",
          cause: error
        }
      }
  end

  @spec delete_credential(Types.credential_id() | Data.SystCredentials.t()) ::
          :ok | {:error, MsbmsSystError.t()}

  def delete_credential(access_account_id) when is_binary(access_account_id) do
    get_credential_record(access_account_id)
    |> delete_credential()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting Password Credential by ID.",
          cause: error
        }
      }
  end

  def delete_credential(%Data.SystCredentials{} = cred) do
    case MsbmsSystDatastore.delete(cred) do
      {:ok, _} ->
        :ok

      error ->
        raise MsbmsSystError,
          code: :undefined_error,
          message: "Database failure deleting Password Credential",
          cause: error
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting Password Credential.",
          cause: error
        }
      }
  end
end
