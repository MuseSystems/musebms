# Source File: access_account.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/impl/access_account.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.AccessAccount do
  @moduledoc false

  import Ecto.Query

  alias MscmpSystAuthn.Types

  require Logger

  ##############################################################################
  #
  # create_access_account
  #
  #

  @spec create_access_account(Types.access_account_params()) ::
          {:ok, Msdata.SystAccessAccounts.t()} | {:error, MscmpSystError.t()}
  def create_access_account(access_account_params) do
    access_account_params
    |> Msdata.SystAccessAccounts.insert_changeset()
    |> MscmpSystDb.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure creating Access Account.",
         cause: error
       }}
  end

  ##############################################################################
  #
  # get_access_account_state_by_name
  #
  #

  @spec get_access_account_state_by_name(Types.access_account_state_name()) ::
          Msdata.SystEnumItems.t() | nil
  def get_access_account_state_by_name(access_account_state_name)
      when is_binary(access_account_state_name),
      do: MscmpSystEnums.get_item_by_name("access_account_states", access_account_state_name)

  ##############################################################################
  #
  # get_access_account_state_default
  #
  #

  @spec get_access_account_state_default(Types.access_account_state_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  def get_access_account_state_default(nil),
    do: MscmpSystEnums.get_default_item("access_account_states")

  def get_access_account_state_default(functional_type) when is_atom(functional_type) do
    MscmpSystEnums.get_default_item("access_account_states",
      functional_type_name: Atom.to_string(functional_type)
    )
  end

  ##############################################################################
  #
  # update_access_account
  #
  #

  @spec update_access_account(
          Types.access_account_id() | Msdata.SystAccessAccounts.t(),
          Types.access_account_params()
        ) ::
          {:ok, Msdata.SystAccessAccounts.t()} | {:error, MscmpSystError.t()}
  def update_access_account(access_account_id, access_account_params)
      when is_binary(access_account_id) do
    MscmpSystDb.get!(Msdata.SystAccessAccounts, access_account_id)
    |> update_access_account(access_account_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure updating Access Account by ID.",
         cause: error
       }}
  end

  def update_access_account(%Msdata.SystAccessAccounts{} = access_account, access_account_params) do
    access_account
    |> Msdata.SystAccessAccounts.update_changeset(access_account_params)
    |> MscmpSystDb.update!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure updating Access Account.",
         cause: error
       }}
  end

  ##############################################################################
  #
  # get_access_account_id_by_name
  #
  #

  @spec get_access_account_id_by_name(Types.access_account_name()) ::
          {:ok, Types.access_account_id()} | {:error, MscmpSystError.t()}
  def get_access_account_id_by_name(access_account_name) when is_binary(access_account_name) do
    from(aa in Msdata.SystAccessAccounts,
      select: aa.id,
      where: aa.internal_name == ^access_account_name
    )
    |> MscmpSystDb.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure retrieving Access Account ID by internal name.",
         cause: error
       }}
  end

  ##############################################################################
  #
  # get_access_account_by_name
  #
  #

  @spec get_access_account_by_name(Types.access_account_name()) ::
          Msdata.SystAccessAccounts.t() | {:error, MscmpSystError.t()}
  def get_access_account_by_name(access_account_name) do
    from(
      aa in Msdata.SystAccessAccounts,
      join: aas in assoc(aa, :access_account_state),
      join: aasft in assoc(aas, :functional_type),
      where: aa.internal_name == ^access_account_name,
      preload: [access_account_state: {aas, functional_type: aasft}]
    )
    |> MscmpSystDb.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure retrieving Access Account data.",
         cause: error
       }}
  end

  ##############################################################################
  #
  # purge_access_account
  #
  #

  @spec purge_access_account(Types.access_account_id() | Msdata.SystAccessAccounts.t()) ::
          :ok | {:error, MscmpSystError.t()}
  def purge_access_account(access_account_id) when is_binary(access_account_id) do
    from(
      aa in Msdata.SystAccessAccounts,
      join: aas in assoc(aa, :access_account_state),
      join: aasft in assoc(aas, :functional_type),
      where: aa.id == ^access_account_id,
      preload: [access_account_state: {aas, functional_type: aasft}]
    )
    |> MscmpSystDb.one!()
    |> purge_access_account()
  end

  def purge_access_account(
        %Msdata.SystAccessAccounts{
          access_account_state: %Msdata.SystEnumItems{
            functional_type: %Msdata.SystEnumFunctionalTypes{
              internal_name: functional_type
            }
          }
        } = access_account
      ) do
    case functional_type do
      "access_account_states_purge_eligible" ->
        MscmpSystDb.delete!(access_account)
        :ok

      _ ->
        raise MscmpSystError,
          code: :invalid_parameter,
          message: "Invalid Access Account State Functional Type for purge.",
          cause: %{parameters: [functional_type: functional_type]}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure purging Access Account.",
         cause: error
       }}
  end

  def purge_access_account(%Msdata.SystAccessAccounts{id: access_account_id}),
    do: purge_access_account(access_account_id)

  ##############################################################################
  #
  # access_accounts_exist?
  #
  #

  @spec access_accounts_exist?() :: boolean() | {:error, MscmpSystError.t()}
  def access_accounts_exist? do
    Msdata.SystAccessAccounts
    |> MscmpSystDb.exists?()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure testing if any Access Accounts exist.",
         cause: error
       }}
  end

  ##############################################################################
  #
  # access_account_name_exists?
  #
  #

  @spec access_account_name_exists?(Types.access_account_name()) ::
          boolean() | {:error, MscmpSystError.t()}
  def access_account_name_exists?(access_account_name) when is_binary(access_account_name) do
    Msdata.SystAccessAccounts
    |> where(internal_name: ^access_account_name)
    |> MscmpSystDb.exists?()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure testing if Access Account by Internal Name exists.",
         cause: error
       }}
  end

  ##############################################################################
  #
  # access_account_id_exists?
  #
  #

  @spec access_account_id_exists?(Types.access_account_id()) ::
          boolean() | {:error, MscmpSystError.t()}
  def access_account_id_exists?(access_account_id) when is_binary(access_account_id) do
    Msdata.SystAccessAccounts
    |> where(id: ^access_account_id)
    |> MscmpSystDb.exists?()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure testing if Access Account by ID exists.",
         cause: error
       }}
  end
end
