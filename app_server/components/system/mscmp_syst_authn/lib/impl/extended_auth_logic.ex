# Source File: extended_auth_logic.ex
# Location:    musebms/app_server/components/system/mscmp_syst_authn/lib/impl/extended_auth_logic.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.ExtendedAuthLogic do
  @moduledoc false

  alias MscmpSystAuthn.Impl
  alias MscmpSystAuthn.Types
  alias MscmpSystAuthn.Types.AuthenticationState
  alias MscmpSystDb.DbTypes
  alias MscmpSystNetwork.Types, as: NetTypes

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

  # TODO: Consider a rate limit similar to the host limit based on identity.  If
  #       an attack is going after a specific account, but across different
  #       hosts, we'd only ever just rate limit it.  At some point flagging that
  #       suspicious activity would be good.
  #
  # Rate Limit is max attempts per time window in milliseconds expressed as:
  # {<attempts>, <milliseconds>}

  @reset_rate_limit_statuses [:authenticated]

  @email_password_extended_auth_ops [
    :require_mfa,
    :require_mfa_setup,
    :require_instance,
    :require_credential_reset
  ]

  @email_password_operations [
    :check_global_network_rules,
    :check_identifier_limit,
    :check_identity,
    :check_credential,
    :check_instance,
    :check_instance_network_rules
  ]

  @email_password_instance_bypass_operations [
    :check_global_network_rules,
    :check_identifier_limit,
    :check_identity,
    :check_credential
  ]

  @api_token_operations [
    :check_global_network_rules,
    :check_identifier_limit,
    :check_identity,
    :check_credential,
    :check_instance,
    :check_instance_network_rules
  ]

  @api_token_instance_bypass_operations [
    :check_global_network_rules,
    :check_identifier_limit,
    :check_identity,
    :check_credential
  ]

  @validation_token_operations [
    :check_global_network_rules,
    :check_identifier_limit,
    :check_identity,
    :check_credential
  ]

  @recovery_token_operations [
    :check_global_network_rules,
    :check_identifier_limit,
    :check_identity,
    :check_credential
  ]

  ##############################################################################
  #
  # authenticate_email_password
  #
  #

  @spec authenticate_email_password(
          Types.account_identifier(),
          Types.credential(),
          NetTypes.addr_structs(),
          Keyword.t()
        ) ::
          {:ok, AuthenticationState.t()}
  def authenticate_email_password(email_addr, pwd_text, host_addr, opts) do
    authentication_deadline = DateTime.utc_now() |> DateTime.add(opts[:deadline_minutes], :minute)

    %{id: identity_type_id} =
      Impl.Identity.get_identity_type_by_name("identity_types_sysdef_email")

    initial_auth_state =
      case Impl.Identity.Email.verify_email_address(email_addr) do
        {:ok, validated_email} ->
          normalized_email = Impl.Identity.Email.normalize_email_address(validated_email)

          %AuthenticationState{
            status: :not_started,
            deadline: authentication_deadline,
            access_account_id: nil,
            instance_id: opts[:instance_id],
            identity_type_id: identity_type_id,
            host_address: host_addr,
            applied_network_rule: nil,
            identifier: normalized_email,
            owning_owner_id: opts[:owning_owner_id],
            plaintext_credential: pwd_text,
            pending_operations: []
          }

        {:error, _} ->
          Impl.Hash.fake_credential_hash_verify()

          %AuthenticationState{
            status: :rejected,
            deadline: authentication_deadline,
            access_account_id: nil,
            instance_id: opts[:instance_id],
            identity_type_id: identity_type_id,
            host_address: host_addr,
            applied_network_rule: nil,
            identifier: email_addr,
            owning_owner_id: opts[:owning_owner_id],
            plaintext_credential: pwd_text,
            pending_operations: [:check_instance_network_rules, :check_host_rate_limit]
          }
      end

    authenticate_email_password(initial_auth_state, opts)
  end

  @spec authenticate_email_password(AuthenticationState.t(), Keyword.t()) ::
          {:ok, AuthenticationState.t()}
  def authenticate_email_password(auth_state, opts) do
    identifier_limit_opts = Keyword.take(opts, [:identifier_limit])
    host_rate_limit_opts = Keyword.take(opts, [:host_limit])

    preliminary_auth_state =
      %{
        auth_state
        | instance_id: auth_state.instance_id || opts[:instance_id],
          owning_owner_id: auth_state.owning_owner_id || opts[:owning_owner_id]
      }
      |> maybe_start_email_password_authentication()
      |> confirm_deadline()
      |> confirm_instance_identified()
      |> confirm_identifier_limit(identifier_limit_opts)
      |> confirm_global_network_rules()
      |> confirm_email_identity()
      |> confirm_password_credential()

    if extended_email_password_ops_required?(preliminary_auth_state) do
      {:ok, preliminary_auth_state}
    else
      preliminary_auth_state
      |> confirm_instance()
      |> confirm_instance_network_rules()
      |> confirm_host_rate_limit(host_rate_limit_opts)
      |> finalize_authentication()
      |> maybe_reset_limits()
      |> cleanse_auth_state()
      |> then(&{:ok, &1})
    end
  end

  defp maybe_start_email_password_authentication(
         %AuthenticationState{status: :not_started} = auth_state
       ) do
    resolved_ops = resolve_email_password_operations(auth_state)

    %AuthenticationState{auth_state | status: :pending, pending_operations: resolved_ops}
  end

  defp maybe_start_email_password_authentication(auth_state), do: auth_state

  defp resolve_email_password_operations(%AuthenticationState{instance_id: nil}),
    do: [:require_instance | @email_password_operations]

  defp resolve_email_password_operations(%AuthenticationState{instance_id: :bypass}),
    do: @email_password_instance_bypass_operations

  defp resolve_email_password_operations(_),
    do: @email_password_operations

  defp confirm_instance_identified(%AuthenticationState{instance_id: nil} = auth_state),
    do: auth_state

  defp confirm_instance_identified(auth_state) do
    new_ops = List.delete(auth_state.pending_operations, :require_instance)
    %AuthenticationState{auth_state | pending_operations: new_ops}
  end

  defp extended_email_password_ops_required?(auth_state) do
    extended_ops = MapSet.new(@email_password_extended_auth_ops)
    Enum.any?(auth_state.pending_operations, &(&1 in extended_ops))
  end

  defp confirm_email_identity(auth_state) do
    if :check_identity in auth_state.pending_operations do
      Impl.Identity.Email.identify_access_account(
        auth_state.identifier,
        auth_state.owning_owner_id
      )
      |> case do
        {:ok, identity} -> process_identity(auth_state, identity)
        {:error, :not_found} -> process_identity(auth_state, nil)
        _error -> raise "Failure confirming Email identity."
      end
    else
      auth_state
    end
  end

  defp confirm_password_credential(auth_state) do
    if :check_credential in auth_state.pending_operations do
      Impl.Credential.Password.confirm_credential(
        auth_state.access_account_id,
        auth_state.identity_id,
        auth_state.plaintext_credential
      )
      |> case do
        {:ok, result} ->
          process_credential_result(%{auth_state | plaintext_credential: nil}, result)

        _error ->
          raise "Failure confirming Password credential."
      end
    else
      %AuthenticationState{auth_state | plaintext_credential: nil}
    end
  end

  ##############################################################################
  #
  # authenticate_api_token
  #
  #

  @spec authenticate_api_token(
          Types.account_identifier(),
          Types.credential(),
          NetTypes.addr_structs(),
          MscmpSystInstance.Types.instance_id(),
          Keyword.t()
        ) :: {:ok, AuthenticationState.t()}

  def authenticate_api_token(identifier, token, host_addr, instance_id, opts) do
    authentication_deadline = DateTime.utc_now() |> DateTime.add(opts[:deadline_minutes], :minute)

    %{id: identity_type_id} = Impl.Identity.get_identity_type_by_name("identity_types_sysdef_api")

    pending_auth_state = %AuthenticationState{
      status: :pending,
      deadline: authentication_deadline,
      access_account_id: nil,
      instance_id: instance_id,
      identity_type_id: identity_type_id,
      host_address: host_addr,
      applied_network_rule: nil,
      identifier: identifier,
      owning_owner_id: opts[:owning_owner_id],
      plaintext_credential: token,
      pending_operations: resolve_api_token_operations(instance_id)
    }

    authenticate_api_token(pending_auth_state, opts)
  end

  @spec authenticate_api_token(AuthenticationState.t(), Keyword.t()) ::
          {:ok, AuthenticationState.t()}
  def authenticate_api_token(auth_state, opts) do
    identifier_limit_opts = Keyword.take(opts, [:identifier_limit])
    host_rate_limit_opts = Keyword.take(opts, [:host_limit])

    auth_state
    |> struct!(owning_owner_id: auth_state.owning_owner_id || opts[:owning_owner_id])
    |> confirm_deadline()
    |> confirm_identifier_limit(identifier_limit_opts)
    |> confirm_global_network_rules()
    |> confirm_api_token_identity()
    |> confirm_api_token_credential()
    |> confirm_instance()
    |> confirm_instance_network_rules()
    |> confirm_host_rate_limit(host_rate_limit_opts)
    |> finalize_authentication()
    |> maybe_reset_limits()
    |> cleanse_auth_state()
    |> then(&{:ok, &1})
  end

  defp resolve_api_token_operations(:bypass), do: @api_token_instance_bypass_operations
  defp resolve_api_token_operations(_), do: @api_token_operations

  defp confirm_api_token_identity(auth_state) do
    if :check_identity in auth_state.pending_operations do
      Impl.Identity.ApiToken.identify_access_account(
        auth_state.identifier,
        auth_state.owning_owner_id
      )
      |> case do
        {:ok, identity} -> process_identity(auth_state, identity)
        _error -> raise "Failure confirming API Token identity."
      end
    else
      auth_state
    end
  end

  defp confirm_api_token_credential(auth_state) do
    if :check_credential in auth_state.pending_operations do
      Impl.Credential.ApiToken.confirm_credential(
        auth_state.access_account_id,
        auth_state.identity_id,
        auth_state.plaintext_credential
      )
      |> case do
        {:ok, result} ->
          process_credential_result(%{auth_state | plaintext_credential: nil}, result)

        _error ->
          raise "Failure confirming API Token credential."
      end
    else
      %{auth_state | plaintext_credential: nil}
    end
  end

  ##############################################################################
  #
  # authenticate_validation_token
  #
  #

  @spec authenticate_validation_token(
          Types.account_identifier(),
          Types.credential(),
          NetTypes.addr_structs(),
          Keyword.t()
        ) :: {:ok, AuthenticationState.t()}

  def authenticate_validation_token(identifier, token, host_addr, opts) do
    authentication_deadline = DateTime.utc_now() |> DateTime.add(opts[:deadline_minutes], :minute)

    %{id: identity_type_id} =
      Impl.Identity.get_identity_type_by_name("identity_types_sysdef_validation")

    pending_auth_state = %AuthenticationState{
      status: :pending,
      deadline: authentication_deadline,
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

  @spec authenticate_validation_token(AuthenticationState.t(), Keyword.t()) ::
          {:ok, AuthenticationState.t()}
  def authenticate_validation_token(auth_state, opts) do
    identifier_limit_opts = Keyword.take(opts, [:identifier_limit])
    host_rate_limit_opts = Keyword.take(opts, [:host_limit])

    auth_state
    |> confirm_deadline()
    |> confirm_identifier_limit(identifier_limit_opts)
    |> confirm_global_network_rules()
    |> confirm_validation_identity()
    |> confirm_validation_credential()
    |> confirm_host_rate_limit(host_rate_limit_opts)
    |> finalize_authentication()
    |> confirm_successful_validation()
    |> maybe_reset_limits()
    |> cleanse_auth_state()
    |> then(&{:ok, &1})
  end

  defp confirm_validation_identity(auth_state) do
    if :check_identity in auth_state.pending_operations do
      Impl.Identity.Validation.identify_access_account(
        auth_state.identifier,
        auth_state.owning_owner_id
      )
      |> case do
        {:ok, identity} -> process_identity(auth_state, identity, true)
        _error -> process_identity(auth_state, nil, true)
      end
    else
      auth_state
    end
  end

  defp confirm_validation_credential(auth_state) do
    if :check_credential in auth_state.pending_operations do
      Impl.Credential.Validation.confirm_credential(
        auth_state.access_account_id,
        auth_state.identity_id,
        auth_state.plaintext_credential
      )
      |> case do
        {:ok, result} ->
          process_credential_result(%{auth_state | plaintext_credential: nil}, result)

        _error ->
          raise "Failure confirming Validation Token credential."
      end
    else
      %{auth_state | plaintext_credential: nil}
    end
  end

  defp confirm_successful_validation(%{status: :authenticated} = auth_state) do
    case Impl.Identity.Validation.confirm_identity_validation(auth_state.identity) do
      {:ok, _validated_identity} -> auth_state
      _error -> raise "Failure confirming Validation success."
    end
  end

  defp confirm_successful_validation(auth_state), do: auth_state

  ##############################################################################
  #
  # authenticate_recovery_token
  #
  #

  @spec authenticate_recovery_token(
          Types.account_identifier(),
          Types.credential(),
          NetTypes.addr_structs(),
          Keyword.t()
        ) :: {:ok, AuthenticationState.t()} | {:error, term()}
  def authenticate_recovery_token(identifier, token, host_addr, opts) do
    authentication_deadline = DateTime.utc_now() |> DateTime.add(opts[:deadline_minutes], :minute)

    %{id: identity_type_id} =
      Impl.Identity.get_identity_type_by_name("identity_types_sysdef_password_recovery")

    pending_auth_state = %AuthenticationState{
      status: :pending,
      deadline: authentication_deadline,
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

  @spec authenticate_recovery_token(AuthenticationState.t(), Keyword.t()) ::
          {:ok, AuthenticationState.t()} | {:error, term()}
  def authenticate_recovery_token(auth_state, opts) do
    identifier_limit_opts = Keyword.take(opts, [:identifier_limit])
    host_rate_limit_opts = Keyword.take(opts, [:host_limit])

    auth_state
    |> confirm_deadline()
    |> confirm_identifier_limit(identifier_limit_opts)
    |> confirm_global_network_rules()
    |> confirm_credential_recovery()
    |> confirm_recovery_credential()
    |> confirm_host_rate_limit(host_rate_limit_opts)
    |> finalize_authentication()
    |> confirm_successful_recovery()
    |> maybe_reset_limits()
    |> cleanse_auth_state()
    |> then(&{:ok, &1})
  rescue
    error -> {:error, {:authenticate_recovery_token, error}}
  end

  defp confirm_credential_recovery(auth_state) do
    if :check_identity in auth_state.pending_operations do
      Impl.Identity.Recovery.identify_access_account(
        auth_state.identifier,
        auth_state.owning_owner_id
      )
      |> case do
        {:ok, identity} -> process_identity(auth_state, identity, true)
        {:error, :not_found} -> process_identity(auth_state, nil, nil)
      end
    else
      auth_state
    end
  end

  defp confirm_recovery_credential(auth_state) do
    if :check_credential in auth_state.pending_operations do
      Impl.Credential.Recovery.confirm_credential(
        auth_state.access_account_id,
        auth_state.identity_id,
        auth_state.plaintext_credential
      )
      |> case do
        {:ok, result} ->
          process_credential_result(%{auth_state | plaintext_credential: nil}, result)

        _error ->
          raise "Failure confirming Recovery Token credential."
      end
    else
      %{auth_state | plaintext_credential: nil}
    end
  end

  defp confirm_successful_recovery(%{status: :authenticated} = auth_state) do
    case Impl.Identity.Recovery.confirm_credential_recovery(auth_state.identity) do
      :ok -> auth_state
      _error -> raise "Failure confirming Recovery success."
    end
  end

  defp confirm_successful_recovery(auth_state), do: auth_state

  ##############################################################################
  #
  # identify_access_account_by_code
  #
  #

  @spec identify_access_account_by_code(
          Types.account_identifier(),
          MscmpSystInstance.Types.owner_id() | nil
        ) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, :not_found} | {:error, term()}
  def identify_access_account_by_code(account_code, owner_id),
    do: Impl.Identity.AccountCode.identify_access_account(account_code, owner_id)

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

    %AuthenticationState{
      auth_state
      | status: :rejected,
        pending_operations: [:check_instance_network_rules, :check_host_rate_limit]
    }
  end

  defp process_identity(auth_state, %Msdata.SystIdentities{} = identity, validated) do
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

    %AuthenticationState{
      auth_state
      | identity_id: identity.id,
        identity: identity,
        access_account_id: identity.access_account_id,
        status: status,
        pending_operations: new_ops
    }
  end

  defp process_credential_result(auth_state, {:confirmed, cred_ext_state}) do
    new_ops = List.delete(auth_state.pending_operations, :check_credential)

    auth_state
    |> struct!(pending_operations: new_ops)
    |> maybe_add_mfa_operation(cred_ext_state)
    |> maybe_add_password_reset_operation(cred_ext_state)
  end

  defp process_credential_result(auth_state, {:no_credential, _}) do
    Impl.Hash.fake_credential_hash_verify()

    %AuthenticationState{
      auth_state
      | status: :rejected,
        pending_operations: [:check_instance_network_rules, :check_host_rate_limit]
    }
  end

  defp process_credential_result(auth_state, {:wrong_credential, _}) do
    %AuthenticationState{
      auth_state
      | status: :rejected,
        pending_operations: [:check_instance_network_rules, :check_host_rate_limit]
    }
  end

  defp maybe_add_mfa_operation(auth_state, cred_ext_state) do
    if :require_mfa in cred_ext_state do
      %AuthenticationState{
        auth_state
        | pending_operations: [:require_mfa | auth_state.pending_operations]
      }
    else
      auth_state
    end
  end

  defp maybe_add_password_reset_operation(auth_state, cred_ext_state) do
    cond do
      :reset_forced in cred_ext_state ->
        %AuthenticationState{
          auth_state
          | pending_operations: [:require_credential_reset | auth_state.pending_operations],
            reset_reason: :reset_forced
        }

      :reset_age in cred_ext_state ->
        %AuthenticationState{
          auth_state
          | pending_operations: [:require_credential_reset | auth_state.pending_operations],
            reset_reason: :reset_age
        }

      :reset_disallowed in cred_ext_state ->
        %AuthenticationState{
          auth_state
          | pending_operations: [:require_credential_reset | auth_state.pending_operations],
            reset_reason: :reset_disallowed
        }

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

  defp process_check_instance(%{instance_id: nil} = auth_state) do
    %AuthenticationState{
      auth_state
      | status: :rejected,
        pending_operations: [:check_instance_network_rules, :check_host_rate_limit]
    }
  end

  defp process_check_instance(auth_state) do
    instance_access_granted =
      Impl.AccessAccountInstanceAssoc.instance_access_granted?(
        auth_state.access_account_id,
        auth_state.instance_id
      )

    if instance_access_granted do
      new_ops = List.delete(auth_state.pending_operations, :check_instance)
      %AuthenticationState{auth_state | pending_operations: new_ops}
    else
      %AuthenticationState{auth_state | status: :rejected}
    end
  end

  defp confirm_global_network_rules(auth_state) do
    if :check_global_network_rules in auth_state.pending_operations do
      with {:ok, net_rule} <-
             Impl.NetworkRules.get_applied_network_rule(auth_state.host_address) do
        process_network_rule_result(net_rule, auth_state, :check_global_network_rules)
      end
    else
      auth_state
    end
  end

  defp confirm_instance_network_rules(auth_state) do
    if :check_instance_network_rules in auth_state.pending_operations do
      with {:ok, net_rule} <-
             Impl.NetworkRules.get_applied_network_rule(
               auth_state.host_address,
               auth_state.instance_id
             ) do
        process_network_rule_result(net_rule, auth_state, :check_instance_network_rules)
      end
    else
      auth_state
    end
  end

  defp process_network_rule_result(%{functional_type: :allow} = net_rule, auth_state, curr_op) do
    new_ops = List.delete(auth_state.pending_operations, curr_op)
    %AuthenticationState{auth_state | applied_network_rule: net_rule, pending_operations: new_ops}
  end

  defp process_network_rule_result(%{functional_type: :deny} = net_rule, auth_state, _curr_op) do
    # It's possible that an early failure may still want to check the instance
    # network rules, so in those cases, the additional network rule denial here
    # should not supersede the earlier failed status, but should respect it.
    failed_status =
      if auth_state.status == :pending, do: :rejected_host_check, else: auth_state.status

    %AuthenticationState{
      auth_state
      | applied_network_rule: net_rule,
        status: failed_status,
        pending_operations: []
    }
  end

  defp confirm_identifier_limit(auth_state, opts) do
    if :check_identifier_limit in auth_state.pending_operations do
      auth_state
      |> check_identifier_limit(opts)
      |> process_identifier_limit_result(auth_state)
    else
      auth_state
    end
  end

  defp process_identifier_limit_result({:allow, _, limiter_instance}, auth_state) do
    auth_state.pending_operations
    |> List.delete(:check_identifier_limit)
    |> then(
      &%AuthenticationState{
        auth_state
        | pending_operations: &1,
          identifier_limiter: limiter_instance
      }
    )
  end

  defp process_identifier_limit_result({:deny, _, limiter_instance}, auth_state),
    do: %AuthenticationState{
      auth_state
      | status: :rejected_limits_exceeded,
        pending_operations: [],
        identifier_limiter: limiter_instance
    }

  # Getting to where confirm_host_rate_limit/2 actually performs a host rate
  # limit check means that something earlier has gone wrong and that the
  # authentication has already failed.  Even so, a failed host rate check here
  # will explicitly fail the authentication for resiliency's sake.

  defp confirm_host_rate_limit(auth_state, opts) do
    if :check_host_rate_limit in auth_state.pending_operations do
      new_ops = List.delete(auth_state.pending_operations, :check_host_rate_limit)

      auth_state
      |> struct!(pending_operations: new_ops)
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
      auth_state
      |> check_host_limit(opts)
      |> process_host_rate_limit_result(auth_state)
    else
      # Check bypassed because host was explicitly trusted by a network rule.
      auth_state
    end
  end

  defp process_host_rate_limit_result({:allow, _, limiter_instance}, auth_state) do
    %AuthenticationState{auth_state | host_limiter: limiter_instance}
  end

  defp process_host_rate_limit_result({:deny, _, limiter_instance}, auth_state) do
    _ = Impl.NetworkRules.create_disallowed_host(auth_state.host_address)

    %AuthenticationState{
      auth_state
      | status: :rejected,
        pending_operations: [],
        host_limiter: limiter_instance
    }
  end

  defp check_identifier_limit(%AuthenticationState{identifier_limiter: nil} = auth_state, opts) do
    limiter_instance =
      new_limiter_instance(:identifier, auth_state.identifier, opts[:identifier_limit])

    auth_state = %AuthenticationState{auth_state | identifier_limiter: limiter_instance}

    check_identifier_limit(auth_state, opts)
  end

  defp check_identifier_limit(%AuthenticationState{identifier_limiter: limiter_instance}, _opts)
       when not is_nil(limiter_instance),
       do: check_limit(limiter_instance)

  defp check_host_limit(%AuthenticationState{host_limiter: nil} = auth_state, opts) do
    host_addr_str = MscmpSystNetwork.to_string(auth_state.host_address)

    limiter_instance =
      new_limiter_instance(:host_ban, host_addr_str, opts[:host_limit])

    auth_state = %AuthenticationState{auth_state | host_limiter: limiter_instance}

    check_host_limit(auth_state, opts)
  end

  defp check_host_limit(%AuthenticationState{host_limiter: limiter_instance}, _opts) do
    check_limit(limiter_instance)
  end

  defp new_limiter_instance(type, id, rate_limit_config) do
    limiter_opts = [
      max_permits: rate_limit_config.max_attempts,
      time_to_live: rate_limit_config.time_window,
      time_scale: rate_limit_config.time_scale
    ]

    case MscmpSystLimiter.new(:semaphore, :mscmp_syst_authn, type, id, limiter_opts) do
      {:ok, limiter_instance} -> limiter_instance
      error -> raise "Failed creating rate limiting instance. #{inspect(error)}"
    end
  end

  defp check_limit(limiter_instance) do
    case MscmpSystLimiter.use(limiter_instance, 1) do
      {:ok, result} -> result
      error -> raise "Failed using authentication rate limit: #{inspect(error)}"
    end
  end

  defp maybe_reset_limits(%AuthenticationState{status: status} = auth_state)
       when status in @reset_rate_limit_statuses do
    auth_state
    |> maybe_reset_identifier_limits()
    |> maybe_reset_host_limits()
  end

  defp maybe_reset_limits(auth_state), do: auth_state

  defp maybe_reset_identifier_limits(%AuthenticationState{identifier_limiter: nil} = auth_state),
    do: auth_state

  defp maybe_reset_identifier_limits(%AuthenticationState{} = auth_state) do
    case MscmpSystLimiter.reset(auth_state.identifier_limiter) do
      {:ok, {:allow, _, limiter_instance}} ->
        %AuthenticationState{auth_state | identifier_limiter: limiter_instance}

      error ->
        raise "Failed to reset identifier limiter: #{inspect(error)}"
    end
  end

  defp maybe_reset_host_limits(%AuthenticationState{host_limiter: nil} = auth_state),
    do: auth_state

  defp maybe_reset_host_limits(%AuthenticationState{} = auth_state) do
    case MscmpSystLimiter.reset(auth_state.host_limiter) do
      {:ok, {:allow, _, limiter_instance}} ->
        %AuthenticationState{auth_state | host_limiter: limiter_instance}

      error ->
        raise "Failed to reset host limiter: #{inspect(error)}"
    end
  end

  defp finalize_authentication(
         %AuthenticationState{status: :pending, pending_operations: []} = auth_state
       ),
       do: %AuthenticationState{auth_state | status: :authenticated}

  defp finalize_authentication(auth_state), do: auth_state

  # Unlike most other confirm steps where we check to see if the operation is
  # in the pending_operations, for confirm_deadline we always check for any
  # pending status authentication state.  This is because the expiration is
  # an absolute check which shouldn't be bypassed unless the authentication
  # state has already been resolved to a different state.

  defp confirm_deadline(%AuthenticationState{status: :pending} = auth_state) do
    %{deadline: deadline} = auth_state
    is_deadline_expired = DateTime.compare(DateTime.utc_now(), deadline) == :gt

    case is_deadline_expired do
      true ->
        auth_state
        |> struct!(status: :rejected_deadline_expired, pending_operations: [])
        |> cleanse_auth_state()

      false ->
        auth_state
    end
  end

  defp confirm_deadline(auth_state), do: auth_state

  # The credential clear should have happened at credential validation time, but
  # just in case, do it here, too.

  defp cleanse_auth_state(auth_state),
    do: %AuthenticationState{auth_state | plaintext_credential: nil, identity: nil}
end
