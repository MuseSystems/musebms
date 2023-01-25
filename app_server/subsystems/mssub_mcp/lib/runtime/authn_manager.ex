# Source File: authn_manager.ex
# Location:    musebms/subsystems/mssub_mcp/lib/runtime/authn_manager.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcp.Runtime.AuthnManager do
  alias MscmpSystAuthn.Types, as: AuthnTypes

  @moduledoc false

  use MssubMcp.Macros

  mcp_constants()

  # ==============================================================================================
  #
  # Enumerations Data
  #
  # ==============================================================================================

  @spec get_identity_type_by_name(AuthnTypes.identity_type_name()) ::
          Msdata.SystEnumItems.t() | nil
  mcp_opfn get_identity_type_by_name(identity_type_name) do
    MscmpSystAuthn.get_identity_type_by_name(identity_type_name)
  end

  @spec get_identity_type_default(AuthnTypes.identity_type_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  mcp_opfn get_identity_type_default(functional_type) do
    MscmpSystAuthn.get_identity_type_default(functional_type)
  end

  @spec get_credential_type_by_name(AuthnTypes.credential_type_name()) ::
          Msdata.SystEnumItems.t() | nil
  mcp_opfn get_credential_type_by_name(credential_type_name) do
    MscmpSystAuthn.get_credential_type_by_name(credential_type_name)
  end

  @spec get_credential_type_default(AuthnTypes.credential_type_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  mcp_opfn get_credential_type_default(functional_type) do
    MscmpSystAuthn.get_credential_type_default(functional_type)
  end

  # ==============================================================================================
  #
  # Access Account Data
  #
  # ==============================================================================================

  @spec get_access_account_state_by_name(AuthnTypes.access_account_state_name()) ::
          Msdata.SystEnumItems.t() | nil
  mcp_opfn get_access_account_state_by_name(access_account_state_name) do
    MscmpSystAuthn.get_access_account_state_by_name(access_account_state_name)
  end

  @spec get_access_account_state_default(AuthnTypes.access_account_state_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  mcp_opfn get_access_account_state_default(functional_type) do
    MscmpSystAuthn.get_access_account_state_default(functional_type)
  end

  @spec create_access_account(AuthnTypes.access_account_params()) ::
          {:ok, Msdata.SystAccessAccounts.t()} | {:error, MscmpSystError.t()}
  mcp_opfn create_access_account(access_account_params) do
    MscmpSystAuthn.create_access_account(access_account_params)
  end

  @spec get_access_account_id_by_name(AuthnTypes.access_account_name()) ::
          {:ok, AuthnTypes.access_account_id()} | {:error, MscmpSystError.t()}
  mcp_opfn get_access_account_id_by_name(access_account_name) do
    MscmpSystAuthn.get_access_account_id_by_name(access_account_name)
  end

  @spec get_access_account_by_name(AuthnTypes.access_account_name()) ::
          Msdata.SystAccessAccounts.t() | {:error, MscmpSystError.t()}
  mcp_opfn get_access_account_by_name(access_account_name) do
    MscmpSystAuthn.get_access_account_by_name(access_account_name)
  end

  @spec update_access_account(
          AuthnTypes.access_account_id() | Msdata.SystAccessAccounts.t(),
          AuthnTypes.access_account_params()
        ) ::
          {:ok, Msdata.SystAccessAccounts.t()} | {:error, MscmpSystError.t()}
  mcp_opfn update_access_account(access_account, access_account_params) do
    MscmpSystAuthn.update_access_account(access_account, access_account_params)
  end

  @spec purge_access_account(AuthnTypes.access_account_id() | Msdata.SystAccessAccounts.t()) ::
          :ok | {:error, MscmpSystError.t()}
  mcp_opfn purge_access_account(access_account) do
    MscmpSystAuthn.purge_access_account(access_account)
  end

  # ==============================================================================================
  #
  # Access Account Instance Association Data
  #
  # ==============================================================================================

  @spec invite_to_instance(
          AuthnTypes.access_account_id(),
          MscmpSystInstance.Types.instance_id(),
          Keyword.t()
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, MscmpSystError.t()}
  mcp_opfn invite_to_instance(access_account_id, instance_id, opts) do
    MscmpSystAuthn.invite_to_instance(access_account_id, instance_id, opts)
  end

  @spec accept_instance_invite(
          AuthnTypes.access_account_instance_assoc_id()
          | Msdata.SystAccessAccountInstanceAssocs.t()
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, MscmpSystError.t()}
  mcp_opfn accept_instance_invite(access_account_instance_assoc) do
    MscmpSystAuthn.accept_instance_invite(access_account_instance_assoc)
  end

  @spec accept_instance_invite(
          AuthnTypes.access_account_id(),
          MscmpSystInstance.Types.instance_id()
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, MscmpSystError.t()}
  mcp_opfn accept_instance_invite(access_account_id, instance_id) do
    MscmpSystAuthn.accept_instance_invite(access_account_id, instance_id)
  end

  @spec decline_instance_invite(
          AuthnTypes.access_account_instance_assoc_id()
          | Msdata.SystAccessAccountInstanceAssocs.t()
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, MscmpSystError.t()}
  mcp_opfn decline_instance_invite(access_account_instance_assoc) do
    MscmpSystAuthn.decline_instance_invite(access_account_instance_assoc)
  end

  @spec decline_instance_invite(
          AuthnTypes.access_account_id(),
          MscmpSystInstance.Types.instance_id()
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, MscmpSystError.t()}
  mcp_opfn decline_instance_invite(access_account_id, instance_id) do
    MscmpSystAuthn.decline_instance_invite(access_account_id, instance_id)
  end

  @spec revoke_instance_access(
          AuthnTypes.access_account_instance_assoc_id()
          | Msdata.SystAccessAccountInstanceAssocs.t()
        ) :: :ok | {:error, MscmpSystError.t()}
  mcp_opfn revoke_instance_access(access_account_instance_assoc) do
    MscmpSystAuthn.revoke_instance_access(access_account_instance_assoc)
  end

  @spec revoke_instance_access(
          AuthnTypes.access_account_id(),
          MscmpSystInstance.Types.instance_id()
        ) :: {:ok, Msdata.SystAccessAccountInstanceAssocs.t()} | {:error, MscmpSystError.t()}
  mcp_opfn revoke_instance_access(access_account_id, instance_id) do
    MscmpSystAuthn.revoke_instance_access(access_account_id, instance_id)
  end

  # ==============================================================================================
  #
  # Password Rule Data
  #
  # ==============================================================================================

  @spec create_disallowed_password(AuthnTypes.credential()) :: :ok | {:error, MscmpSystError.t()}
  mcp_opfn create_disallowed_password(password) do
    MscmpSystAuthn.create_disallowed_password(password)
  end

  @spec password_disallowed(AuthnTypes.credential()) ::
          {:ok, boolean()} | {:error, MscmpSystError.t()}
  mcp_opfn password_disallowed(password) do
    MscmpSystAuthn.password_disallowed(password)
  end

  @spec password_disallowed?(AuthnTypes.credential()) :: boolean()
  mcp_opfn password_disallowed?(password) do
    MscmpSystAuthn.password_disallowed?(password)
  end

  @spec delete_disallowed_password(AuthnTypes.credential()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  mcp_opfn delete_disallowed_password(password) do
    MscmpSystAuthn.delete_disallowed_password(password)
  end

  @spec create_owner_password_rules(
          MscmpSystInstance.Types.owner_id(),
          AuthnTypes.password_rule_params()
        ) ::
          {:ok, Msdata.SystOwnerPasswordRules.t()} | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn create_owner_password_rules(owner_id, insert_params) do
    MscmpSystAuthn.create_owner_password_rules(owner_id, insert_params)
  end

  @spec update_global_password_rules(AuthnTypes.password_rule_params()) ::
          {:ok, Msdata.SystGlobalPasswordRules.t()} | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn update_global_password_rules(update_params) do
    MscmpSystAuthn.update_global_password_rules(update_params)
  end

  @spec update_global_password_rules(
          Msdata.SystGlobalPasswordRules.t(),
          AuthnTypes.password_rule_params()
        ) ::
          {:ok, Msdata.SystGlobalPasswordRules.t()} | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn update_global_password_rules(global_password_rules, update_params) do
    MscmpSystAuthn.update_global_password_rules(global_password_rules, update_params)
  end

  @spec update_owner_password_rules(
          MscmpSystInstance.Types.owner_id() | Msdata.SystOwnerPasswordRules.t(),
          AuthnTypes.password_rule_params()
        ) ::
          {:ok, Msdata.SystOwnerPasswordRules.t()} | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn update_owner_password_rules(owner, update_params) do
    MscmpSystAuthn.update_owner_password_rules(owner, update_params)
  end

  @spec get_global_password_rules() ::
          {:ok, Msdata.SystGlobalPasswordRules.t()} | {:error, MscmpSystError.t()}
  mcp_opfn get_global_password_rules do
    MscmpSystAuthn.get_global_password_rules()
  end

  @spec get_global_password_rules!() :: Msdata.SystGlobalPasswordRules.t()
  mcp_opfn get_global_password_rules! do
    MscmpSystAuthn.get_global_password_rules!()
  end

  @spec get_owner_password_rules(MscmpSystInstance.Types.owner_id()) ::
          {:ok, Msdata.SystOwnerPasswordRules.t()}
          | {:ok, :not_found}
          | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn get_owner_password_rules(owner_id) do
    MscmpSystAuthn.get_owner_password_rules(owner_id)
  end

  @spec get_owner_password_rules!(MscmpSystInstance.Types.owner_id()) ::
          Msdata.SystOwnerPasswordRules.t() | :not_found
  mcp_opfn get_owner_password_rules!(owner_id) do
    MscmpSystAuthn.get_owner_password_rules!(owner_id)
  end

  @spec get_access_account_password_rule(AuthnTypes.access_account_id()) ::
          {:ok, AuthnTypes.password_rules()} | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn get_access_account_password_rule(access_account_id) do
    MscmpSystAuthn.get_access_account_password_rule(access_account_id)
  end

  @spec get_access_account_password_rule!(AuthnTypes.access_account_id()) ::
          AuthnTypes.password_rules()
  mcp_opfn get_access_account_password_rule!(access_account_id) do
    MscmpSystAuthn.get_access_account_password_rule!(access_account_id)
  end

  @spec verify_password_rules(
          AuthnTypes.password_rules(),
          Msdata.SystGlobalPasswordRules.t() | AuthnTypes.password_rules() | nil
        ) ::
          {:ok, Keyword.t(AuthnTypes.password_rule_violations())}
          | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn verify_password_rules(test_rules, standard_rules) do
    MscmpSystAuthn.verify_password_rules(test_rules, standard_rules)
  end

  @spec verify_password_rules!(
          AuthnTypes.password_rules(),
          Msdata.SystGlobalPasswordRules.t() | AuthnTypes.password_rules() | nil
        ) ::
          Keyword.t(AuthnTypes.password_rule_violations())
  mcp_opfn verify_password_rules!(test_rules, standard_rules) do
    MscmpSystAuthn.verify_password_rules!(test_rules, standard_rules)
  end

  @spec delete_owner_password_rules(MscmpSystInstance.Types.owner_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn delete_owner_password_rules(owner_id) do
    MscmpSystAuthn.delete_owner_password_rules(owner_id)
  end

  @spec test_credential(
          AuthnTypes.access_account_id() | AuthnTypes.password_rules(),
          AuthnTypes.credential()
        ) ::
          {:ok, Keyword.t(AuthnTypes.password_rule_violations())}
          | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn test_credential(access_account_id, plaintext_pwd) do
    MscmpSystAuthn.test_credential(access_account_id, plaintext_pwd)
  end

  @spec load_disallowed_passwords(Enumerable.t(), Keyword.t()) ::
          :ok | {:error, MscmpSystError.t()}
  mcp_opfn load_disallowed_passwords(password_list, opts) do
    MscmpSystAuthn.load_disallowed_passwords(password_list, opts)
  end

  @spec disallowed_passwords_populated?() :: boolean()
  mcp_opfn disallowed_passwords_populated?() do
    MscmpSystAuthn.disallowed_passwords_populated?()
  end

  # ==============================================================================================
  #
  # Network Rule Data
  #
  # ==============================================================================================

  @spec host_disallowed(AuthnTypes.host_address()) ::
          {:ok, boolean()} | {:error, MscmpSystError.t()}
  mcp_opfn host_disallowed(host_address) do
    MscmpSystAuthn.host_disallowed(host_address)
  end

  @spec host_disallowed?(AuthnTypes.host_address()) :: boolean()
  mcp_opfn host_disallowed?(host_address) do
    MscmpSystAuthn.host_disallowed?(host_address)
  end

  @spec create_disallowed_host(AuthnTypes.host_address()) ::
          {:ok, Msdata.SystDisallowedHosts.t()} | {:error, MscmpSystError.t()}
  mcp_opfn create_disallowed_host(host_address) do
    MscmpSystAuthn.create_disallowed_host(host_address)
  end

  @spec get_disallowed_host_record_by_host(AuthnTypes.host_address()) ::
          {:ok, Msdata.SystDisallowedHosts.t() | nil} | {:error, MscmpSystError.t()}
  mcp_opfn get_disallowed_host_record_by_host(host_addr) do
    MscmpSystAuthn.get_disallowed_host_record_by_host(host_addr)
  end

  @spec get_disallowed_host_record_by_host!(AuthnTypes.host_address()) ::
          Msdata.SystDisallowedHosts.t() | nil
  mcp_opfn get_disallowed_host_record_by_host!(host_addr) do
    MscmpSystAuthn.get_disallowed_host_record_by_host!(host_addr)
  end

  @spec delete_disallowed_host_addr(AuthnTypes.host_address()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  mcp_opfn delete_disallowed_host_addr(host_addr) do
    MscmpSystAuthn.delete_disallowed_host_addr(host_addr)
  end

  @spec get_disallowed_host_record_by_id(AuthnTypes.disallowed_host_id()) ::
          {:ok, Msdata.SystDisallowedHosts.t()} | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn get_disallowed_host_record_by_id(disallowed_host_id) do
    MscmpSystAuthn.get_disallowed_host_record_by_id(disallowed_host_id)
  end

  @spec get_disallowed_host_record_by_id!(AuthnTypes.disallowed_host_id()) ::
          Msdata.SystDisallowedHosts.t()
  mcp_opfn get_disallowed_host_record_by_id!(disallowed_host_id) do
    MscmpSystAuthn.get_disallowed_host_record_by_id!(disallowed_host_id)
  end

  @spec delete_disallowed_host(AuthnTypes.disallowed_host_id() | Msdata.SystDisallowedHosts.t()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  mcp_opfn delete_disallowed_host(disallowed_host) do
    MscmpSystAuthn.delete_disallowed_host(disallowed_host)
  end

  @spec get_applied_network_rule(
          AuthnTypes.host_address(),
          MscmpSystInstance.Types.instance_id() | nil,
          MscmpSystInstance.Types.owner_id() | nil
        ) ::
          {:ok, AuthnTypes.applied_network_rule()} | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn get_applied_network_rule(host_address, instance_id, instance_owner_id) do
    MscmpSystAuthn.get_applied_network_rule(host_address, instance_id, instance_owner_id)
  end

  @spec get_applied_network_rule!(
          AuthnTypes.host_address(),
          MscmpSystInstance.Types.instance_id() | nil,
          MscmpSystInstance.Types.owner_id() | nil
        ) :: AuthnTypes.applied_network_rule()
  mcp_opfn get_applied_network_rule!(host_address, instance_id, instance_owner_id) do
    MscmpSystAuthn.get_applied_network_rule!(host_address, instance_id, instance_owner_id)
  end

  @spec create_global_network_rule(AuthnTypes.global_network_rule_params()) ::
          {:ok, Msdata.SystGlobalNetworkRules.t()} | {:error, MscmpSystError.t()}
  mcp_opfn create_global_network_rule(insert_params) do
    MscmpSystAuthn.create_global_network_rule(insert_params)
  end

  @spec create_owner_network_rule(
          MscmpSystInstance.Types.owner_id(),
          AuthnTypes.owner_network_rule_params()
        ) ::
          {:ok, Msdata.SystOwnerNetworkRules.t()} | {:error, MscmpSystError.t()}
  mcp_opfn create_owner_network_rule(owner_id, insert_params) do
    MscmpSystAuthn.create_owner_network_rule(owner_id, insert_params)
  end

  @spec create_instance_network_rule(
          MscmpSystInstance.Types.instance_id(),
          AuthnTypes.instance_network_rule_params()
        ) ::
          {:ok, Msdata.SystInstanceNetworkRules.t()} | {:error, MscmpSystError.t()}
  mcp_opfn create_instance_network_rule(instance_id, insert_params) do
    MscmpSystAuthn.create_instance_network_rule(instance_id, insert_params)
  end

  @spec update_global_network_rule(
          Ecto.UUID.t() | Msdata.SystGlobalNetworkRules.t(),
          AuthnTypes.global_network_rule_params()
        ) ::
          {:ok, Msdata.SystGlobalNetworkRules.t()} | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn update_global_network_rule(global_network_rule, update_params) do
    MscmpSystAuthn.update_global_network_rule(global_network_rule, update_params)
  end

  @spec update_owner_network_rule(
          Ecto.UUID.t() | Msdata.SystOwnerNetworkRules.t(),
          AuthnTypes.owner_network_rule_params()
        ) ::
          {:ok, Msdata.SystOwnerNetworkRules.t()} | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn update_owner_network_rule(owner_network_rule, update_params) do
    MscmpSystAuthn.update_owner_network_rule(owner_network_rule, update_params)
  end

  @spec update_instance_network_rule(
          Ecto.UUID.t() | Msdata.SystInstanceNetworkRules.t(),
          AuthnTypes.instance_network_rule_params()
        ) ::
          {:ok, Msdata.SystInstanceNetworkRules.t()}
          | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn update_instance_network_rule(instance_network_rule, update_params) do
    MscmpSystAuthn.update_instance_network_rule(instance_network_rule, update_params)
  end

  @spec get_global_network_rule(Ecto.UUID.t()) ::
          {:ok, Msdata.SystGlobalNetworkRules.t()}
          | {:ok, :not_found}
          | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn get_global_network_rule(global_network_rule_id) do
    MscmpSystAuthn.get_global_network_rule(global_network_rule_id)
  end

  @spec get_global_network_rule!(Ecto.UUID.t()) :: Msdata.SystGlobalNetworkRules.t() | :not_found
  mcp_opfn get_global_network_rule!(global_network_rule_id) do
    MscmpSystAuthn.get_global_network_rule!(global_network_rule_id)
  end

  @spec get_owner_network_rule(Ecto.UUID.t()) ::
          {:ok, Msdata.SystOwnerNetworkRules.t()}
          | {:ok, :not_found}
          | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn get_owner_network_rule(owner_network_rule_id) do
    MscmpSystAuthn.get_owner_network_rule(owner_network_rule_id)
  end

  @spec get_owner_network_rule!(Ecto.UUID.t()) :: Msdata.SystOwnerNetworkRules.t() | :not_found
  mcp_opfn get_owner_network_rule!(owner_network_rule_id) do
    MscmpSystAuthn.get_owner_network_rule!(owner_network_rule_id)
  end

  @spec get_instance_network_rule(Ecto.UUID.t()) ::
          {:ok, Msdata.SystInstanceNetworkRules.t()}
          | {:ok, :not_found}
          | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn get_instance_network_rule(instance_network_rule_id) do
    MscmpSystAuthn.get_instance_network_rule(instance_network_rule_id)
  end

  @spec get_instance_network_rule!(Ecto.UUID.t()) ::
          Msdata.SystInstanceNetworkRules.t() | :not_found
  mcp_opfn get_instance_network_rule!(instance_network_rule_id) do
    MscmpSystAuthn.get_instance_network_rule!(instance_network_rule_id)
  end

  @spec delete_global_network_rule(Ecto.UUID.t()) ::
          :ok | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn delete_global_network_rule(global_network_rule_id) do
    MscmpSystAuthn.delete_global_network_rule(global_network_rule_id)
  end

  @spec delete_owner_network_rule(Ecto.UUID.t()) ::
          :ok | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn delete_owner_network_rule(owner_network_rule_id) do
    MscmpSystAuthn.delete_owner_network_rule(owner_network_rule_id)
  end

  @spec delete_instance_network_rule(Ecto.UUID.t()) ::
          :ok | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn delete_instance_network_rule(instance_network_rule_id) do
    MscmpSystAuthn.delete_instance_network_rule(instance_network_rule_id)
  end

  # ==============================================================================================
  #
  # Account Code Identity Management
  #
  # ==============================================================================================

  @spec create_or_reset_account_code(AuthnTypes.access_account_id(), Keyword.t()) ::
          {:ok, AuthnTypes.authenticator_result()} | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn create_or_reset_account_code(access_account_id, opts) do
    MscmpSystAuthn.create_or_reset_account_code(access_account_id, opts)
  end

  @spec identify_access_account_by_code(
          AuthnTypes.account_identifier(),
          MscmpSystInstance.Types.owner_id() | nil
        ) ::
          {:ok, Msdata.SystIdentities.t() | :not_found} | {:error, MscmpSystError.t()}
  mcp_opfn identify_access_account_by_code(account_code, owner_id) do
    MscmpSystAuthn.identify_access_account_by_code(account_code, owner_id)
  end

  @spec get_account_code_by_access_account_id(AuthnTypes.access_account_id()) ::
          {:ok, Msdata.SystIdentities.t() | :not_found} | {:error, MscmpSystError.t()}
  mcp_opfn get_account_code_by_access_account_id(access_account_id) do
    MscmpSystAuthn.get_account_code_by_access_account_id(access_account_id)
  end

  @spec revoke_account_code(AuthnTypes.access_account_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  mcp_opfn revoke_account_code(access_account_id) do
    MscmpSystAuthn.revoke_account_code(access_account_id)
  end

  # ==============================================================================================
  #
  # Extended Logic / Authenticator Management
  #
  # ==============================================================================================

  @spec create_authenticator_email_password(
          AuthnTypes.access_account_id(),
          AuthnTypes.account_identifier(),
          AuthnTypes.credential(),
          Keyword.t()
        ) ::
          {:ok, AuthnTypes.authenticator_result()}
          | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn create_authenticator_email_password(
             access_account_id,
             email_address,
             plaintext_pwd,
             opts
           ) do
    MscmpSystAuthn.create_authenticator_email_password(
      access_account_id,
      email_address,
      plaintext_pwd,
      opts
    )
  end

  @spec request_identity_validation(
          AuthnTypes.identity_id() | Msdata.SystIdentities.t(),
          Keyword.t()
        ) ::
          {:ok, AuthnTypes.authenticator_result()} | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn request_identity_validation(target_identity, opts) do
    MscmpSystAuthn.request_identity_validation(target_identity, opts)
  end

  @spec revoke_validator_for_identity_id(AuthnTypes.identity_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn revoke_validator_for_identity_id(target_identity_id) do
    MscmpSystAuthn.revoke_validator_for_identity_id(target_identity_id)
  end

  @spec access_account_credential_recoverable!(AuthnTypes.access_account_id()) ::
          :ok | :not_found | :existing_recovery
  mcp_opfn access_account_credential_recoverable!(access_account_id) do
    MscmpSystAuthn.access_account_credential_recoverable!(access_account_id)
  end

  @spec request_password_recovery(AuthnTypes.access_account_id(), Keyword.t()) ::
          {:ok, AuthnTypes.authenticator_result()} | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn request_password_recovery(access_account_id, opts) do
    MscmpSystAuthn.request_password_recovery(access_account_id, opts)
  end

  @spec revoke_password_recovery(AuthnTypes.access_account_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn revoke_password_recovery(access_account_id) do
    MscmpSystAuthn.revoke_password_recovery(access_account_id)
  end

  @spec create_authenticator_api_token(AuthnTypes.access_account_id(), Keyword.t()) ::
          {:ok, AuthnTypes.authenticator_result()} | {:error, MscmpSystError.t() | Exception.t()}
  mcp_opfn create_authenticator_api_token(access_account_id, opts) do
    MscmpSystAuthn.create_authenticator_api_token(access_account_id, opts)
  end

  @spec update_api_token_external_name(
          AuthnTypes.identity_id() | Msdata.SystIdentities.t(),
          String.t() | nil
        ) ::
          {:ok, Msdata.SystIdentities.t()} | {:error, MscmpSystError.t()}
  mcp_opfn update_api_token_external_name(identity, external_name) do
    MscmpSystAuthn.update_api_token_external_name(identity, external_name)
  end

  @spec revoke_api_token(AuthnTypes.identity_id() | Msdata.SystIdentities.t()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  mcp_opfn revoke_api_token(identity) do
    MscmpSystAuthn.revoke_api_token(identity)
  end

  # ==============================================================================================
  #
  # Extended Logic / Authentication
  #
  # ==============================================================================================

  @spec authenticate_email_password(
          AuthnTypes.account_identifier(),
          AuthnTypes.credential(),
          IP.addr(),
          Keyword.t()
        ) ::
          {:ok, AuthnTypes.authentication_state()} | {:error, MscmpSystError.t()}
  mcp_opfn authenticate_email_password(email_address, plaintext_pwd, host_address, opts) do
    MscmpSystAuthn.authenticate_email_password(email_address, plaintext_pwd, host_address, opts)
  end

  @spec authenticate_email_password(AuthnTypes.authentication_state(), Keyword.t()) ::
          {:ok, AuthnTypes.authentication_state()} | {:error, MscmpSystError.t()}
  mcp_opfn authenticate_email_password(authentication_state, opts) do
    MscmpSystAuthn.authenticate_email_password(authentication_state, opts)
  end

  @spec authenticate_validation_token(
          AuthnTypes.account_identifier(),
          AuthnTypes.credential(),
          IP.addr(),
          Keyword.t()
        ) ::
          {:ok, AuthnTypes.authentication_state()} | {:error, MscmpSystError.t()}
  mcp_opfn authenticate_validation_token(identifier, plaintext_token, host_address, opts) do
    MscmpSystAuthn.authenticate_validation_token(identifier, plaintext_token, host_address, opts)
  end

  @spec authenticate_recovery_token(
          AuthnTypes.account_identifier(),
          AuthnTypes.credential(),
          IP.addr(),
          Keyword.t()
        ) ::
          {:ok, AuthnTypes.authentication_state()} | {:error, MscmpSystError.t()}
  mcp_opfn authenticate_recovery_token(identifier, plaintext_token, host_addr, opts) do
    MscmpSystAuthn.authenticate_recovery_token(identifier, plaintext_token, host_addr, opts)
  end

  @spec authenticate_api_token(
          AuthnTypes.account_identifier(),
          AuthnTypes.credential(),
          IP.addr(),
          MscmpSystInstance.Types.instance_id(),
          Keyword.t()
        ) ::
          {:ok, AuthnTypes.authentication_state()} | {:error, MscmpSystError.t()}
  mcp_opfn authenticate_api_token(identifier, plaintext_token, host_addr, instance_id, opts) do
    MscmpSystAuthn.authenticate_api_token(
      identifier,
      plaintext_token,
      host_addr,
      instance_id,
      opts
    )
  end
end
