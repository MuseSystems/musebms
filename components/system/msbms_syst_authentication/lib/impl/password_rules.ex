# Source File: password_rules.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/impl/password_rules.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Impl.PasswordRules do
  import Ecto.Query

  use Pathex

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl
  alias MsbmsSystAuthentication.Types
  alias MsbmsSystDatastore.DbTypes

  require Logger

  @moduledoc false

  @spec create_disallowed_password(Types.credential()) ::
          :ok | {:error, MsbmsSystError.t() | Exception.t()}
  def create_disallowed_password(password) do
    create_disallowed_password!(password)
  rescue
    error -> {:error, error}
  end

  @spec create_disallowed_password!(Types.credential()) :: :ok
  def create_disallowed_password!(password) when is_binary(password) do
    password
    |> Impl.Hash.weak_hash()
    |> Data.SystDisallowedPasswords.insert_changeset()
    |> MsbmsSystDatastore.insert!()

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      raise MsbmsSystError,
        code: :undefined_error,
        message: "Failure adding Disallowed Password.",
        cause: error
  end

  @spec password_disallowed(Types.credential()) ::
          {:ok, boolean()} | {:error, MsbmsSystError.t()}
  def password_disallowed(password) when is_binary(password) do
    {:ok, password_disallowed?(password)}
  rescue
    error -> {:error, error}
  end

  @spec password_disallowed?(Types.credential()) :: boolean()
  def password_disallowed?(password) when is_binary(password) do
    pwd_hash = Impl.Hash.weak_hash(password)

    from(dp in Data.SystDisallowedPasswords, where: dp.password_hash == ^pwd_hash)
    |> MsbmsSystDatastore.exists?()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      raise MsbmsSystError,
        code: :undefined_error,
        message: "Failure testing if password is disallowed.",
        cause: error
  end

  @spec delete_disallowed_password(Types.credential()) ::
          {:ok, :deleted | :not_found} | {:error, MsbmsSystError.t() | Exception.t()}
  def delete_disallowed_password(password) do
    {:ok, delete_disallowed_password!(password)}
  rescue
    error -> {:error, error}
  end

  @spec delete_disallowed_password!(Types.credential()) :: :deleted | :not_found
  def delete_disallowed_password!(password) when is_binary(password) do
    pwd_hash = Impl.Hash.weak_hash(password)

    from(dp in Data.SystDisallowedPasswords, where: dp.password_hash == ^pwd_hash)
    |> MsbmsSystDatastore.delete_all()
    |> case do
      {1, _} ->
        :deleted

      {0, _} ->
        :not_found

      error ->
        raise MsbmsSystError,
          code: :undefined_error,
          message: "Unexpected result from delete of disallowed password.",
          cause: error
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      raise MsbmsSystError,
        code: :undefined_error,
        message: "Failure deleting Disallowed Password.",
        cause: error
  end

  @spec create_owner_password_rules(
          MsbmsSystInstanceMgr.Types.owner_id(),
          Types.password_rule_params()
        ) ::
          {:ok, Data.SystOwnerPasswordRules.t()} | {:error, MsbmsSystError.t() | Exception.t()}
  def create_owner_password_rules(owner_id, insert_params) when is_binary(owner_id) do
    {:ok, create_owner_password_rules!(owner_id, insert_params)}
  rescue
    error -> {:error, error}
  end

  @spec create_owner_password_rules!(
          MsbmsSystInstanceMgr.Types.owner_id(),
          Types.password_rule_params()
        ) ::
          Data.SystOwnerPasswordRules.t()
  def create_owner_password_rules!(owner_id, insert_params) when is_binary(owner_id) do
    default_rules = get_global_password_rules!() |> Map.from_struct()

    insert_params
    |> Map.put(:owner_id, owner_id)
    |> Map.merge(default_rules, fn _k, v1, v2 -> if v1 != nil, do: v1, else: v2 end)
    |> Data.SystOwnerPasswordRules.insert_changeset()
    |> MsbmsSystDatastore.insert!(returning: true)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      raise MsbmsSystError,
        code: :undefined_error,
        message: "Failure creating Owner Password Rules.",
        cause: error
  end

  @spec update_global_password_rules(Types.password_rule_params()) ::
          {:ok, Data.SystGlobalPasswordRules.t()} | {:error, MsbmsSystError.t() | Exception.t()}
  def update_global_password_rules(update_params) do
    {:ok, update_global_password_rules!(update_params)}
  rescue
    error -> {:error, error}
  end

  @spec update_global_password_rules!(Types.password_rule_params()) ::
          Data.SystGlobalPasswordRules.t()
  def update_global_password_rules!(update_params) do
    get_global_password_rules!()
    |> update_global_password_rules!(update_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      raise MsbmsSystError,
        code: :undefined_error,
        message: "Failure retrieving or updating Global Password Rules.",
        cause: error
  end

  @spec update_global_password_rules(
          Data.SystGlobalPasswordRules.t(),
          Types.password_rule_params()
        ) ::
          {:ok, Data.SystGlobalPasswordRules.t()} | {:error, MsbmsSystError.t() | Exception.t()}
  def update_global_password_rules(global_password_rules, update_params) do
    {:ok, update_global_password_rules!(global_password_rules, update_params)}
  rescue
    error -> {:error, error}
  end

  @spec update_global_password_rules!(
          Data.SystGlobalPasswordRules.t(),
          Types.password_rule_params()
        ) ::
          Data.SystGlobalPasswordRules.t()
  def update_global_password_rules!(global_password_rules, update_params) do
    global_password_rules
    |> Data.SystGlobalPasswordRules.update_changeset(update_params)
    |> MsbmsSystDatastore.update!(returning: true)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      raise MsbmsSystError,
        code: :undefined_error,
        message: "Failure updating Global Password Rules.",
        cause: error
  end

  @spec update_owner_password_rules(
          MsbmsSystInstanceMgr.Types.owner_id(),
          Types.password_rule_params()
        ) ::
          {:ok, Data.SystOwnerPasswordRules.t()} | {:error, MsbmsSystError.t() | Exception.t()}
  def update_owner_password_rules(owner_id, update_params) do
    {:ok, update_owner_password_rules!(owner_id, update_params)}
  rescue
    error -> {:error, error}
  end

  @spec update_owner_password_rules!(
          MsbmsSystInstanceMgr.Types.owner_id(),
          Types.password_rule_params()
        ) ::
          Data.SystOwnerPasswordRules.t()
  def update_owner_password_rules!(owner_id, update_params) do
    from(opwr in Data.SystOwnerPasswordRules, where: opwr.owner_id == ^owner_id)
    |> MsbmsSystDatastore.one!()
    |> Data.SystOwnerPasswordRules.update_changeset(update_params)
    |> MsbmsSystDatastore.update!(returning: true)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      raise MsbmsSystError,
        code: :undefined_error,
        message: "Failure updating Owner Password Rules.",
        cause: error
  end

  @spec get_global_password_rules() ::
          {:ok, Data.SystGlobalPasswordRules.t()} | {:error, MsbmsSystError.t()}
  def get_global_password_rules do
    {:ok, get_global_password_rules!()}
  rescue
    error -> {:error, error}
  end

  @spec get_global_password_rules!() :: Data.SystGlobalPasswordRules.t()
  def get_global_password_rules! do
    # There should only ever be one SystGlobalPasswordRules record and always
    # one.
    from(gpwr in Data.SystGlobalPasswordRules)
    |> MsbmsSystDatastore.one!()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      raise MsbmsSystError,
        code: :undefined_error,
        message: "Failure retrieving Global Password Rules.",
        cause: error
  end

  @spec get_owner_password_rules(MsbmsSystInstanceMgr.Types.owner_id()) ::
          {:ok, Data.SystOwnerPasswordRules.t()}
          | {:ok, :not_found}
          | {:error, MsbmsSystError.t() | Exception.t()}
  def get_owner_password_rules(owner_id) do
    {:ok, get_owner_password_rules!(owner_id)}
  rescue
    error -> {:error, error}
  end

  @spec get_owner_password_rules!(MsbmsSystInstanceMgr.Types.owner_id()) ::
          Data.SystOwnerPasswordRules.t() | :not_found
  def get_owner_password_rules!(owner_id) do
    from(opwr in Data.SystOwnerPasswordRules, where: opwr.owner_id == ^owner_id)
    |> MsbmsSystDatastore.one()
    |> case do
      %Data.SystOwnerPasswordRules{} = result -> result
      nil -> :not_found
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      raise MsbmsSystError,
        code: :undefined_error,
        message: "Failure retrieving Owner Password Rules.",
        cause: error
  end

  @spec get_access_account_password_rule(Types.access_account_id()) ::
          {:ok, Types.password_rule()} | {:error, MsbmsSystError.t() | Exception.t()}
  def get_access_account_password_rule(access_account_id) when is_binary(access_account_id) do
    {:ok, get_access_account_password_rule!(access_account_id)}
  rescue
    error -> {:error, error}
  end

  @spec get_access_account_password_rule!(Types.access_account_id()) :: Types.password_rule()
  def get_access_account_password_rule!(access_account_id) when is_binary(access_account_id) do
    global_rule =
      get_global_password_rules!() |> parse_data_struct_to_generic_rule(access_account_id)

    owner_rule = maybe_get_owner_rule(access_account_id) || global_rule

    verify_password_rules!(owner_rule, global_rule)
    |> Enum.reduce(owner_rule, fn {rule_violation, required_value}, result_rule ->
      set_required_rule_value(rule_violation, required_value, result_rule)
    end)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      raise MsbmsSystError,
        code: :undefined_error,
        message: "Failure retrieving Access Account effective Password Rules.",
        cause: error
  end

  defp maybe_get_owner_rule(access_account_id) do
    from(
      aa in Data.SystAccessAccounts,
      join: opwr in Data.SystOwnerPasswordRules,
      on: opwr.owner_id == aa.owning_owner_id,
      where: aa.id == ^access_account_id,
      select: opwr
    )
    |> MsbmsSystDatastore.one()
    |> parse_data_struct_to_generic_rule(access_account_id)
  end

  defp parse_data_struct_to_generic_rule(nil = _rule, _access_account_id), do: nil

  defp parse_data_struct_to_generic_rule(rule, access_account_id) when is_struct(rule) do
    rule
    |> Map.from_struct()
    |> Map.put(:access_account_id, access_account_id)
    |> Map.put_new(:owner_id, nil)
    |> Map.filter(fn {key, _value} ->
      key in [
        :access_account_id,
        :owner_id,
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
      ]
    end)
  end

  defp set_required_rule_value(:required_rule_min_length, req_value, rule) do
    update_value_path = path(:password_length / :lower, :map)
    update_inclusivity_path = path(:password_length / :lower_inclusive, :map)

    rule
    |> Pathex.over!(update_value_path, fn _ -> req_value end)
    |> Pathex.over!(update_inclusivity_path, fn _ -> true end)
  end

  defp set_required_rule_value(:required_rule_max_length, req_value, rule) do
    update_value_path = path(:password_length / :upper, :map)
    update_inclusivity_path = path(:password_length / :upper_inclusive, :map)

    rule
    |> Pathex.over!(update_value_path, fn _ -> req_value end)
    |> Pathex.over!(update_inclusivity_path, fn _ -> true end)
  end

  defp set_required_rule_value(:required_rule_max_age, req_value, rule) do
    update_path = path(:max_age, :map)
    Pathex.over!(rule, update_path, fn _ -> req_value end)
  end

  defp set_required_rule_value(:required_rule_upper_case, req_value, rule) do
    update_path = path(:require_upper_case, :map)
    Pathex.over!(rule, update_path, fn _ -> req_value end)
  end

  defp set_required_rule_value(:required_rule_lower_case, req_value, rule) do
    update_path = path(:require_lower_case, :map)
    Pathex.over!(rule, update_path, fn _ -> req_value end)
  end

  defp set_required_rule_value(:required_rule_numbers, req_value, rule) do
    update_path = path(:require_numbers, :map)
    Pathex.over!(rule, update_path, fn _ -> req_value end)
  end

  defp set_required_rule_value(:required_rule_symbols, req_value, rule) do
    update_path = path(:require_symbols, :map)
    Pathex.over!(rule, update_path, fn _ -> req_value end)
  end

  defp set_required_rule_value(:required_rule_disallow_recent, req_value, rule) do
    update_path = path(:disallow_recently_used, :map)
    Pathex.over!(rule, update_path, fn _ -> req_value end)
  end

  defp set_required_rule_value(:required_rule_no_compromised, req_value, rule) do
    update_path = path(:disallow_compromised, :map)
    Pathex.over!(rule, update_path, fn _ -> req_value end)
  end

  defp set_required_rule_value(:required_rule_require_mfa, req_value, rule) do
    update_path = path(:require_mfa, :map)
    Pathex.over!(rule, update_path, fn _ -> req_value end)
  end

  @spec verify_password_rules(Types.password_rule(), Types.password_rule()) ::
          {:ok, Keyword.t(Types.password_rule_violations())}
          | {:error, MsbmsSystError.t() | Exception.t()}
  def verify_password_rules(test_rules, standard_rules) do
    verify_password_rules!(test_rules, standard_rules)
    |> then(&{:ok, &1})
  rescue
    error -> {:error, error}
  end

  @spec verify_password_rules!(
          Types.password_rule(),
          Data.SystGlobalPasswordRules.t() | Types.password_rule()
        ) ::
          Keyword.t(Types.password_rule_violations())
  def verify_password_rules!(%{} = test_rules, nil = _standard_rules) do
    {:ok, standard_rules} = get_global_password_rules()
    verify_password_rules!(test_rules, standard_rules)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      raise MsbmsSystError,
        code: :undefined_error,
        message: "Failure verifying Password Rules or retrieving system Standard Rules.",
        cause: error
  end

  def verify_password_rules!(%{} = test_rules, %{} = standard_rules) do
    []
    |> verify_password_rule_length(test_rules, standard_rules)
    |> verify_password_rule_max_age(test_rules, standard_rules)
    |> verify_password_rule_req_upper_case(test_rules, standard_rules)
    |> verify_password_rule_req_lower_case(test_rules, standard_rules)
    |> verify_password_rule_req_numbers(test_rules, standard_rules)
    |> verify_password_rule_req_symbols(test_rules, standard_rules)
    |> verify_password_rule_recently_used(test_rules, standard_rules)
    |> verify_password_rule_no_compromised(test_rules, standard_rules)
    |> verify_password_rule_require_mfa(test_rules, standard_rules)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      raise MsbmsSystError,
        code: :undefined_error,
        message: "Failure verifying Test Password Rules against Standard Password Rules.",
        cause: error
  end

  defp verify_password_rule_length(failure_list, test_rules, std_rules) do
    compare_result =
      DbTypes.Range.bounds_compare(std_rules.password_length, test_rules.password_length)

    failure_list
    |> verify_rule_min_length(compare_result, std_rules)
    |> verify_rule_max_length(compare_result, std_rules)
  end

  defp verify_rule_min_length(failure_list, %{lower_comparison: :gt}, std_rules),
    do: [
      {:required_rule_min_length, DbTypes.Range.lower(std_rules.password_length)} | failure_list
    ]

  defp verify_rule_min_length(failure_list, _, _), do: failure_list

  defp verify_rule_max_length(failure_list, %{upper_comparison: :gt}, std_rules),
    do: [
      {:required_rule_max_length, DbTypes.Range.upper(std_rules.password_length)} | failure_list
    ]

  defp verify_rule_max_length(failure_list, _, _), do: failure_list

  defp verify_password_rule_max_age(failure_list, test_rules, std_rules) do
    compare_result = compare_max_age(std_rules.max_age, test_rules.max_age)
    verify_rule_max_age(failure_list, compare_result, std_rules.max_age)
  end

  defp compare_max_age(
         %DbTypes.Interval{months: 0, days: 0, secs: 0, microsecs: 0},
         _test_max_age
       ),
       do: :std_disabled

  defp compare_max_age(_std_max_age, %DbTypes.Interval{months: 0, days: 0, secs: 0, microsecs: 0}),
    do: :test_disabled

  defp compare_max_age(std_max_age, test_max_age), do: DbTypes.compare(std_max_age, test_max_age)

  defp verify_rule_max_age(failure_list, :std_disabled, _), do: failure_list

  defp verify_rule_max_age(failure_list, oper, std_max_age) when oper in [:lt, :test_disabled],
    do: [{:required_rule_max_age, std_max_age} | failure_list]

  defp verify_rule_max_age(failure_list, _, _), do: failure_list

  defp verify_password_rule_req_upper_case(failure_list, _test_rules, %{require_upper_case: 0}),
    do: failure_list

  defp verify_password_rule_req_upper_case(failure_list, test_rules, std_rules) do
    verify_rule_required_min(
      failure_list,
      :required_rule_upper_case,
      std_rules.require_upper_case,
      test_rules.require_upper_case
    )
  end

  defp verify_password_rule_req_lower_case(failure_list, test_rules, std_rules) do
    verify_rule_required_min(
      failure_list,
      :required_rule_lower_case,
      std_rules.require_lower_case,
      test_rules.require_lower_case
    )
  end

  defp verify_password_rule_req_numbers(failure_list, test_rules, std_rules) do
    verify_rule_required_min(
      failure_list,
      :required_rule_numbers,
      std_rules.require_numbers,
      test_rules.require_numbers
    )
  end

  defp verify_password_rule_req_symbols(failure_list, test_rules, std_rules) do
    verify_rule_required_min(
      failure_list,
      :required_rule_symbols,
      std_rules.require_symbols,
      test_rules.require_symbols
    )
  end

  defp verify_password_rule_recently_used(failure_list, test_rules, std_rules) do
    verify_rule_required_min(
      failure_list,
      :required_rule_disallow_recent,
      std_rules.disallow_recently_used,
      test_rules.disallow_recently_used
    )
  end

  defp verify_rule_required_min(failure_list, _rule, 0, _test_req), do: failure_list

  defp verify_rule_required_min(failure_list, rule, std_req, test_req)
       when is_atom(rule) and is_integer(std_req) and is_integer(test_req) and std_req > test_req,
       do: [{rule, std_req} | failure_list]

  defp verify_rule_required_min(failure_list, _rule, std_req, test_req)
       when is_integer(std_req) and is_integer(test_req),
       do: failure_list

  defp verify_password_rule_no_compromised(failure_list, test_rules, std_rules) do
    verify_rule_required_boolean(
      failure_list,
      :required_rule_no_compromised,
      std_rules.disallow_compromised,
      test_rules.disallow_compromised
    )
  end

  defp verify_password_rule_require_mfa(failure_list, test_rules, std_rules) do
    verify_rule_required_boolean(
      failure_list,
      :required_rule_require_mfa,
      std_rules.require_mfa,
      test_rules.require_mfa
    )
  end

  defp verify_rule_required_boolean(failure_list, _rule, std_req, test_req)
       when std_req == false or test_req == true,
       do: failure_list

  defp verify_rule_required_boolean(failure_list, rule, std_req, test_req)
       when std_req == true and test_req == false,
       do: [{rule, std_req} | failure_list]

  @spec delete_password_rules(MsbmsSystInstanceMgr.Types.owner_id()) ::
          :ok | {:error, MsbmsSystError.t() | Exception.t()}
  def delete_password_rules(owner_id) do
    delete_password_rules!(owner_id)
  rescue
    error -> {:error, error}
  end

  @spec delete_password_rules!(MsbmsSystInstanceMgr.Types.owner_id()) :: :ok
  def delete_password_rules!(owner_id) do
    from(opwr in Data.SystOwnerPasswordRules, where: opwr.owner_id == ^owner_id)
    |> MsbmsSystDatastore.delete_all()

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      raise MsbmsSystError,
        code: :undefined_error,
        message: "Failure deleting Owner Password Rules.",
        cause: error
  end
end
