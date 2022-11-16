# Source File: extended_auth_logic.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/impl/extended_auth_logic.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Impl.ExtendedAuthLogic do
  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Impl
  alias MsbmsSystAuthentication.Types
  alias MscmpSystDb.DbTypes

  # TODO: This whole module and approach feels too complex.  The flexibility
  #       built into the authentication flow is helpful in allowing us to
  #       consider interrupt-able workflows such as MFA validation or allowing
  #       late selection of target Instances by the user.  However, the real
  #       definition of the workflow is spread out across across many functions
  #       and depends on the ordering of the function calls.  I'd like to keep
  #       some of this flexibility and we might be able to do this by making an
  #       easier to understand definition of states that a state machine
  #       processor can read through.  There are currently no good candidate
  #       libraries for this that I've found (they all seem to want to model
  #       long-lived states via processes rather than targeting simple and
  #       more immediate action resolutions); I think such functionality
  #       wouldn't be too hard to build, but isn't currently critical path so
  #       solving this complexity will be a future problem.  For now rely on
  #       reasonable integration testing to prove out the flows.

  # While we want to collect logging including many values kept in `auth_state`,
  # care and attention is required.  `auth_state` may carry plaintext and other
  # security sensitive data that should not be logged.  Use `cleanse_auth_state`
  # to deal with any "not to be logged" data.
  #
  # TODO: Note explicit cleansing of sensitive data might not be sufficient as
  #       certain errors will log the complete auth_state map without being
  #       passed through a cleansing function.  This area needs some serious
  #       consideration once we've got more of an application together.

  require Logger

  # TODO: Consider a rate limit similar to the host limit based on identity.  If
  #       an attack is going after a specific account, but across different
  #       hosts, we'd only ever just rate limit it.  At some point flagging that
  #       suspicious activity would be good.
  #
  # Rate Limit is max attempts per time window in milliseconds expressed as:
  # {<attempts>, <milliseconds>}

  @identifier_default_rate_limit {5, 60_000 * 30}
  @host_ban_default_rate_limit {30, 60_000 * 60 * 2}
  @reset_rate_limit_statuses [:authenticated]

  @email_password_extended_auth_ops [
    :require_mfa,
    :require_mfa_setup,
    :require_instance,
    :require_credential_reset
  ]

  @email_password_operations [
    :check_global_network_rules,
    :check_identifier_rate_limit,
    :check_identity,
    :check_credential,
    :check_instance,
    :check_instance_network_rules
  ]

  @api_token_operations [
    :check_global_network_rules,
    :check_identifier_rate_limit,
    :check_identity,
    :check_credential,
    :check_instance,
    :check_instance_network_rules
  ]

  @validation_token_operations [
    :check_global_network_rules,
    :check_identifier_rate_limit,
    :check_identity,
    :check_credential
  ]

  @recovery_token_operations [
    :check_global_network_rules,
    :check_identifier_rate_limit,
    :check_identity,
    :check_credential
  ]

  @moduledoc false

  @spec authenticate_email_password(
          Types.account_identifier(),
          Types.credential(),
          IP.addr(),
          Keyword.t()
        ) ::
          {:ok, Types.authentication_state()} | {:error, MscmpSystError.t()}
  def authenticate_email_password(email_addr, pwd_text, host_addr, opts) do
    opts = MscmpSystUtils.resolve_options(opts, owning_owner_id: nil, instance_id: nil)

    %{id: identity_type_id} =
      MscmpSystEnums.get_enum_item_by_name("identity_types", "identity_types_sysdef_email")

    resolved_email_addr =
      email_addr
      |> Impl.Identity.Email.verify_email_address()
      |> Impl.Identity.Email.normalize_email_address()

    not_started_auth_state = %{
      status: :not_started,
      access_account_id: nil,
      instance_id: opts[:instance_id],
      identity_type_id: identity_type_id,
      host_address: host_addr,
      applied_network_rule: nil,
      identifier: resolved_email_addr,
      owning_owner_id: opts[:owning_owner_id],
      plaintext_credential: pwd_text,
      pending_operations: []
    }

    authenticate_email_password(not_started_auth_state, opts)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure authenticating Email/Password.",
         cause: error
       }}
  end

  @spec authenticate_email_password(Types.authentication_state(), Keyword.t()) ::
          {:ok, Types.authentication_state()} | {:error, MscmpSystError.t()}
  def authenticate_email_password(auth_state, opts) do
    preliminary_auth_state =
      auth_state
      |> maybe_start_email_password_authentication()
      |> maybe_clear_require_instance(opts[:instance_id])
      |> confirm_identifier_rate_limit(opts)
      |> confirm_global_network_rules()
      |> confirm_email_identity()
      |> confirm_password_credential()

    if extended_email_password_ops_required?(preliminary_auth_state) do
      {:ok, preliminary_auth_state}
    else
      preliminary_auth_state
      |> confirm_instance()
      |> confirm_instance_network_rules()
      |> confirm_host_rate_limit(opts)
      |> finalize_authentication()
      |> maybe_reset_rate_limits()
      |> cleanse_auth_state()
      |> then(&{:ok, &1})
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure authenticating Email/Password via Authentication State.",
         cause: error
       }}
  end

  defp maybe_start_email_password_authentication(%{status: :not_started} = auth_state) do
    base_ops = @email_password_operations

    all_ops = if auth_state.instance_id == nil, do: [:require_instance | base_ops], else: base_ops

    Map.merge(auth_state, %{status: :pending, pending_operations: all_ops})
  end

  defp maybe_start_email_password_authentication(auth_state), do: auth_state

  defp maybe_clear_require_instance(%{status: :pending} = auth_state, instance_id)
       when is_binary(instance_id) do
    case Enum.member?(auth_state.pending_operations, :require_instance) do
      true ->
        new_ops = List.delete(auth_state.pending_operations, :require_instance)
        Map.merge(auth_state, %{pending_operations: new_ops, instance_id: instance_id})

      false ->
        auth_state
    end
  end

  defp maybe_clear_require_instance(auth_state, _instance_id), do: auth_state

  defp extended_email_password_ops_required?(auth_state) do
    extended_operations = MapSet.new(@email_password_extended_auth_ops)

    auth_state.pending_operations
    |> MapSet.new()
    |> MapSet.intersection(extended_operations)
    |> MapSet.equal?(MapSet.new([]))
    |> then(&(&1 == false))
  end

  defp confirm_email_identity(auth_state) do
    if :check_identity in auth_state.pending_operations do
      identity =
        Impl.Identity.Email.identify_access_account(
          auth_state.identifier,
          auth_state.owning_owner_id
        )

      process_identity(auth_state, identity)
    else
      auth_state
    end
  end

  defp confirm_password_credential(auth_state) do
    if :check_credential in auth_state.pending_operations do
      confirm_result =
        Impl.Credential.Password.confirm_credential!(
          auth_state.access_account_id,
          auth_state.identity_id,
          auth_state.plaintext_credential
        )

      auth_state
      |> Map.delete(:plaintext_credential)
      |> process_credential_result(confirm_result)
    else
      Map.delete(auth_state, :plaintext_credential)
    end
  end

  @spec authenticate_api_token(
          Types.account_identifier(),
          Types.credential(),
          IP.addr(),
          MscmpSystInstance.Types.instance_id(),
          Keyword.t()
        ) ::
          {:ok, Types.authentication_state()} | {:error, MscmpSystError.t()}

  def authenticate_api_token(identifier, token, host_addr, instance_id, opts) do
    opts = MscmpSystUtils.resolve_options(opts, owning_owner_id: nil)

    %{id: identity_type_id} =
      MscmpSystEnums.get_enum_item_by_name("identity_types", "identity_types_sysdef_api")

    pending_auth_state = %{
      status: :pending,
      access_account_id: nil,
      instance_id: instance_id,
      identity_type_id: identity_type_id,
      host_address: host_addr,
      applied_network_rule: nil,
      identifier: identifier,
      owning_owner_id: opts[:owning_owner_id],
      plaintext_credential: token,
      pending_operations: @api_token_operations
    }

    authenticate_api_token(pending_auth_state, opts)
  end

  @spec authenticate_api_token(Types.authentication_state(), Keyword.t()) ::
          {:ok, Types.authentication_state()} | {:error, MscmpSystError.t()}
  def authenticate_api_token(auth_state, opts) do
    auth_state
    |> confirm_identifier_rate_limit(opts)
    |> confirm_global_network_rules()
    |> confirm_api_token_identity()
    |> confirm_api_token_credential()
    |> confirm_instance()
    |> confirm_instance_network_rules()
    |> confirm_host_rate_limit(opts)
    |> finalize_authentication()
    |> maybe_reset_rate_limits()
    |> cleanse_auth_state()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure authenticating API Token.",
         cause: error
       }}
  end

  defp confirm_api_token_identity(auth_state) do
    if :check_identity in auth_state.pending_operations do
      identity =
        Impl.Identity.ApiToken.identify_access_account(
          auth_state.identifier,
          auth_state.owning_owner_id
        )

      process_identity(auth_state, identity)
    else
      auth_state
    end
  end

  defp confirm_api_token_credential(auth_state) do
    if :check_credential in auth_state.pending_operations do
      confirm_result =
        Impl.Credential.ApiToken.confirm_credential!(
          auth_state.access_account_id,
          auth_state.identity_id,
          auth_state.plaintext_credential
        )

      auth_state
      |> Map.delete(:plaintext_credential)
      |> process_credential_result(confirm_result)
    else
      Map.delete(auth_state, :plaintext_credential)
    end
  end

  @spec authenticate_validation_token(
          Types.account_identifier(),
          Types.credential(),
          IP.addr(),
          Keyword.t()
        ) ::
          {:ok, Types.authentication_state()} | {:error, MscmpSystError.t()}

  def authenticate_validation_token(identifier, token, host_addr, opts) do
    opts = MscmpSystUtils.resolve_options(opts, owning_owner_id: nil)

    %{id: identity_type_id} =
      MscmpSystEnums.get_enum_item_by_name("identity_types", "identity_types_sysdef_validation")

    pending_auth_state = %{
      status: :pending,
      access_account_id: nil,
      instance_id: nil,
      identity_type_id: identity_type_id,
      host_address: host_addr,
      applied_network_rule: nil,
      identifier: identifier,
      owning_owner_id: opts[:owning_owner_id],
      plaintext_credential: token,
      pending_operations: @validation_token_operations
    }

    authenticate_validation_token(pending_auth_state, opts)
  end

  @spec authenticate_validation_token(Types.authentication_state(), Keyword.t()) ::
          {:ok, Types.authentication_state()} | {:error, MscmpSystError.t()}
  def authenticate_validation_token(auth_state, opts) do
    auth_state
    |> confirm_identifier_rate_limit(opts)
    |> confirm_global_network_rules()
    |> confirm_validation_identity()
    |> confirm_validation_credential()
    |> confirm_host_rate_limit(opts)
    |> finalize_authentication()
    |> confirm_successful_validation()
    |> maybe_reset_rate_limits()
    |> cleanse_auth_state()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure authenticating Validation Token.",
         cause: error
       }}
  end

  defp confirm_validation_identity(auth_state) do
    if :check_identity in auth_state.pending_operations do
      identity =
        Impl.Identity.Validation.identify_access_account(
          auth_state.identifier,
          auth_state.owning_owner_id
        )

      process_identity(auth_state, identity, true)
    else
      auth_state
    end
  end

  defp confirm_validation_credential(auth_state) do
    if :check_credential in auth_state.pending_operations do
      confirm_result =
        Impl.Credential.Validation.confirm_credential!(
          auth_state.access_account_id,
          auth_state.identity_id,
          auth_state.plaintext_credential
        )

      auth_state
      |> Map.delete(:plaintext_credential)
      |> process_credential_result(confirm_result)
    else
      Map.delete(auth_state, :plaintext_credential)
    end
  end

  defp confirm_successful_validation(%{status: :authenticated} = auth_state) do
    case Impl.Identity.Validation.confirm_identity_validation(auth_state.identity) do
      {:ok, _identity} ->
        auth_state

      error ->
        raise MscmpSystError,
          code: :undefined_error,
          message: "Failure confirming Validation success.",
          error: error
    end
  end

  defp confirm_successful_validation(auth_state), do: auth_state

  @spec authenticate_recovery_token(
          Types.account_identifier(),
          Types.credential(),
          IP.addr(),
          Keyword.t()
        ) ::
          {:ok, Types.authentication_state()} | {:error, MscmpSystError.t()}
  def authenticate_recovery_token(identifier, token, host_addr, opts) do
    opts = MscmpSystUtils.resolve_options(opts, owning_owner_id: nil)

    %{id: identity_type_id} =
      MscmpSystEnums.get_enum_item_by_name(
        "identity_types",
        "identity_types_sysdef_password_recovery"
      )

    pending_auth_state = %{
      status: :pending,
      access_account_id: nil,
      instance_id: nil,
      identity_type_id: identity_type_id,
      host_address: host_addr,
      applied_network_rule: nil,
      identifier: identifier,
      owning_owner_id: opts[:owning_owner_id],
      plaintext_credential: token,
      pending_operations: @recovery_token_operations
    }

    authenticate_recovery_token(pending_auth_state, opts)
  end

  @spec authenticate_recovery_token(Types.authentication_state(), Keyword.t()) ::
          {:ok, Types.authentication_state()} | {:error, MscmpSystError.t()}
  def authenticate_recovery_token(auth_state, opts) do
    auth_state
    |> confirm_identifier_rate_limit(opts)
    |> confirm_global_network_rules()
    |> confirm_credential_recovery()
    |> confirm_recovery_credential()
    |> confirm_host_rate_limit(opts)
    |> finalize_authentication()
    |> confirm_successful_recovery()
    |> maybe_reset_rate_limits()
    |> cleanse_auth_state()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure authenticating Recovery Token.",
         cause: error
       }}
  end

  defp confirm_credential_recovery(auth_state) do
    if :check_identity in auth_state.pending_operations do
      identity =
        Impl.Identity.Recovery.identify_access_account(
          auth_state.identifier,
          auth_state.owning_owner_id
        )

      process_identity(auth_state, identity, true)
    else
      auth_state
    end
  end

  defp confirm_recovery_credential(auth_state) do
    if :check_credential in auth_state.pending_operations do
      confirm_result =
        Impl.Credential.Recovery.confirm_credential!(
          auth_state.access_account_id,
          auth_state.identity_id,
          auth_state.plaintext_credential
        )

      auth_state
      |> Map.delete(:plaintext_credential)
      |> process_credential_result(confirm_result)
    else
      Map.delete(auth_state, :plaintext_credential)
    end
  end

  defp confirm_successful_recovery(%{status: :authenticated} = auth_state) do
    case Impl.Identity.Recovery.confirm_credential_recovery(auth_state.identity) do
      :ok ->
        auth_state

      error ->
        raise MscmpSystError,
          code: :undefined_error,
          message: "Failure confirming Validation success.",
          error: error
    end
  end

  defp confirm_successful_recovery(auth_state), do: auth_state

  @spec identify_access_account_by_code(
          Types.account_identifier(),
          MscmpSystInstance.Types.owner_id() | nil
        ) ::
          {:ok, Data.SystIdentities.t() | :not_found} | {:error, MscmpSystError.t()}
  def identify_access_account_by_code(account_code, owner_id) when is_binary(account_code) do
    account_code
    |> Impl.Identity.AccountCode.identify_access_account(owner_id)
    |> process_identify_account_code_result()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure identifying Account Code.",
         cause: error
       }}
  end

  defp process_identify_account_code_result(%Data.SystIdentities{} = identity),
    do: {:ok, identity}

  defp process_identify_account_code_result(nil), do: {:ok, :not_found}

  #
  # General Functionality
  #

  # Some Identity types are not subject to a validation process.  The
  # syst_identities record for those Identities will record a `validated` value
  # of NULL even though they are valid for use.  Forcing process_identity/3 to
  # assume such an Identity is validated is the purpose of the `validated`
  # parameter in `process_identity/3`.

  defp process_identity(auth_state, identity), do: process_identity(auth_state, identity, false)

  defp process_identity(auth_state, nil = _identity, _validated) do
    Impl.Hash.fake_credential_hash_verify()

    Map.merge(auth_state, %{
      status: :rejected,
      pending_operations: [:check_instance_network_rules, :check_host_rate_limit]
    })
  end

  defp process_identity(auth_state, %Data.SystIdentities{} = identity, validated) do
    identity_expired =
      if identity.identity_expires == nil,
        do: false,
        else: DbTypes.DateTime.compare(identity.identity_expires, DateTime.utc_now()) == :lt

    identity_validated = identity.validated || validated

    status =
      cond do
        identity_validated == false -> :rejected_validation
        identity_expired -> :rejected_identity_expired
        true -> auth_state.status
      end

    new_ops =
      case status do
        :pending ->
          List.delete(auth_state.pending_operations, :check_identity)

        sts when sts in [:rejected_validation, :rejected_identity_expired] ->
          [:check_host_rate_limit]

        _ ->
          auth_state.pending_operations
      end

    Map.merge(auth_state, %{
      identity_id: identity.id,
      identity: identity,
      access_account_id: identity.access_account_id,
      status: status,
      pending_operations: new_ops
    })
  end

  defp process_credential_result(auth_state, {:confirmed, cred_ext_state}) do
    new_ops = List.delete(auth_state.pending_operations, :check_credential)

    auth_state
    |> Map.put(:pending_operations, new_ops)
    |> maybe_add_mfa_operation(cred_ext_state)
    |> maybe_add_password_reset_operation(cred_ext_state)
  end

  defp process_credential_result(auth_state, {:no_credential, _}) do
    Impl.Hash.fake_credential_hash_verify()

    Map.merge(auth_state, %{
      status: :rejected,
      pending_operations: [:check_instance_network_rules, :check_host_rate_limit]
    })
  end

  defp process_credential_result(auth_state, {:wrong_credential, _}),
    do:
      Map.merge(auth_state, %{
        status: :rejected,
        pending_operations: [:check_instance_network_rules, :check_host_rate_limit]
      })

  defp maybe_add_mfa_operation(auth_state, cred_ext_state) do
    if :require_mfa in cred_ext_state do
      Map.put(auth_state, :pending_operations, [:require_mfa | auth_state.pending_operations])
    else
      auth_state
    end
  end

  defp maybe_add_password_reset_operation(auth_state, cred_ext_state) do
    cond do
      :reset_forced in cred_ext_state ->
        Map.merge(auth_state, %{
          pending_operations: [:require_credential_reset | auth_state.pending_operations],
          reset_reason: :reset_forced
        })

      :reset_age in cred_ext_state ->
        Map.merge(auth_state, %{
          pending_operations: [:require_credential_reset | auth_state.pending_operations],
          reset_reason: :reset_age
        })

      :reset_disallowed in cred_ext_state ->
        Map.merge(auth_state, %{
          pending_operations: [:require_credential_reset | auth_state.pending_operations],
          reset_reason: :reset_disallowed
        })

      true ->
        auth_state
    end
  end

  defp confirm_instance(auth_state) do
    if :check_instance in auth_state.pending_operations do
      process_check_instance(auth_state)
    else
      auth_state
    end
  end

  defp process_check_instance(%{instance_id: nil} = auth_state),
    do:
      Map.merge(auth_state, %{
        status: :rejected,
        pending_operations: [:check_instance_network_rules, :check_host_rate_limit]
      })

  defp process_check_instance(auth_state) do
    instance_access_granted =
      Impl.AccessAccountInstanceAssoc.instance_access_granted?(
        auth_state.access_account_id,
        auth_state.instance_id
      )

    if instance_access_granted do
      new_ops = List.delete(auth_state.pending_operations, :check_instance)
      Map.put(auth_state, :pending_operations, new_ops)
    else
      auth_state
      |> Map.put(:status, :rejected)
    end
  end

  defp confirm_global_network_rules(auth_state) do
    if :check_global_network_rules in auth_state.pending_operations do
      auth_state.host_address
      |> Impl.NetworkRules.get_applied_network_rule!()
      |> process_network_rule_result(auth_state, :check_global_network_rules)
    else
      auth_state
    end
  end

  defp confirm_instance_network_rules(auth_state) do
    if :check_instance_network_rules in auth_state.pending_operations do
      auth_state.host_address
      |> Impl.NetworkRules.get_applied_network_rule!(auth_state[:instance_id])
      |> process_network_rule_result(auth_state, :check_instance_network_rules)
    else
      auth_state
    end
  end

  defp process_network_rule_result(%{functional_type: :allow} = net_rule, auth_state, curr_op) do
    new_ops = List.delete(auth_state.pending_operations, curr_op)
    Map.merge(auth_state, %{applied_network_rule: net_rule, pending_operations: new_ops})
  end

  defp process_network_rule_result(%{functional_type: :deny} = net_rule, auth_state, _curr_op) do
    # It's possible that an early failure may still want to check the instance
    # network rules, so in those cases, the additional network rule denial here
    # should not supersede the earlier failed status, but should respect it.
    failed_status =
      if auth_state.status == :pending, do: :rejected_host_check, else: auth_state.status

    Map.merge(auth_state, %{
      applied_network_rule: net_rule,
      status: failed_status,
      pending_operations: []
    })
  end

  defp confirm_identifier_rate_limit(auth_state, opts) do
    if :check_identifier_rate_limit in auth_state.pending_operations do
      auth_state.identifier
      |> check_identifier_rate_limit(opts)
      |> process_identifier_rate_limit_result(auth_state)
    else
      auth_state
    end
  end

  defp process_identifier_rate_limit_result({:allow, _}, auth_state) do
    auth_state.pending_operations
    |> List.delete(:check_identifier_rate_limit)
    |> then(&Map.put(auth_state, :pending_operations, &1))
  end

  defp process_identifier_rate_limit_result({:deny, _}, auth_state) do
    Map.merge(auth_state, %{status: :rejected_rate_limited, pending_operations: []})
  end

  defp process_identifier_rate_limit_result(error, _auth_state) do
    raise MscmpSystError,
      code: :undefined_error,
      message: "Error processing Identifier Rate Limit",
      cause: error
  end

  # Getting to where confirm_host_rate_limit/2 actually performs a host rate
  # limit check means that something earlier has gone wrong and that the
  # authentication has already failed.  Even so, a failed host rate check here
  # will explicitly fail the authentication for resiliency's sake.

  defp confirm_host_rate_limit(auth_state, opts) do
    if :check_host_rate_limit in auth_state.pending_operations do
      new_ops = List.delete(auth_state.pending_operations, :check_host_rate_limit)

      auth_state
      |> Map.put(:pending_operations, new_ops)
      |> check_host_rate_limit(opts)
    else
      auth_state
    end
  end

  defp check_host_rate_limit(auth_state, opts) do
    net_rule = auth_state.applied_network_rule
    no_host_bypass = net_rule.precedence == :implied || net_rule.functional_type == :deny

    if no_host_bypass do
      # Check is required because the host has implied access rather than
      # explicit trust.
      auth_state.host_address
      |> check_host_ban_rate_limit(opts)
      |> process_host_rate_limit_result(auth_state)
    else
      # Check bypassed because host was explicitly trusted by a network rule.
      auth_state
    end
  end

  defp process_host_rate_limit_result({:allow, _}, auth_state), do: auth_state

  defp process_host_rate_limit_result({:deny, _}, auth_state) do
    _ = Impl.NetworkRules.create_disallowed_host(auth_state.host_address)

    Map.merge(auth_state, %{status: :rejected, pending_operations: []})
  end

  defp process_host_rate_limit_result(error, _auth_state) do
    raise MscmpSystError,
      code: :undefined_error,
      message: "Error processing Host Rate Limit",
      cause: error
  end

  defp check_identifier_rate_limit(identifier, opts) do
    opts =
      MscmpSystUtils.resolve_options(opts, identifier_rate_limit: @identifier_default_rate_limit)

    check_rate_limit(:identifier, identifier, opts[:identifier_rate_limit])
  end

  defp check_host_ban_rate_limit(host_addr, opts) do
    opts = MscmpSystUtils.resolve_options(opts, host_ban_rate_limit: @host_ban_default_rate_limit)

    check_rate_limit(:host_ban, IP.to_string(host_addr), opts[:host_ban_rate_limit])
  end

  defp check_rate_limit(counter_type, target, rate_limit) do
    {attempts, time_window} = rate_limit

    MscmpSystLimiter.check_rate(counter_type, target, time_window, attempts)
  end

  defp maybe_reset_rate_limits(%{status: status} = auth_state)
       when status in @reset_rate_limit_statuses do
    _ = reset_identifier_rate_limit(auth_state.identifier)
    _ = reset_host_ban_rate_limit(auth_state.host_address)
    auth_state
  end

  defp maybe_reset_rate_limits(auth_state), do: auth_state

  defp reset_identifier_rate_limit(identifier), do: reset_rate_limit(:identifier, identifier)

  defp reset_host_ban_rate_limit(host_addr),
    do: reset_rate_limit(:host_ban, IP.to_string(host_addr))

  defp reset_rate_limit(counter_type, target),
    do: MscmpSystLimiter.delete_counters(counter_type, target)

  defp finalize_authentication(%{status: :pending, pending_operations: []} = auth_state),
    do: Map.put(auth_state, :status, :authenticated)

  defp finalize_authentication(auth_state), do: auth_state

  defp cleanse_auth_state(auth_state) do
    # The credential clear should have happened at credential validation time,
    # but just in case, do it here, too.
    auth_state
    |> Map.delete(:plaintext_credential)
    |> Map.delete(:identity)
  end
end
