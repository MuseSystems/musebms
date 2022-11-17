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
  import Ecto.Query

  alias MscmpSystAuthn.Data
  alias MscmpSystAuthn.Types

  require Logger

  @moduledoc false

  @spec create_access_account(Types.access_account_params()) ::
          {:ok, Data.SystAccessAccounts.t()} | {:error, MscmpSystError.t()}
  def create_access_account(access_account_params) do
    access_account_params
    |> Data.SystAccessAccounts.insert_changeset()
    |> MscmpSystDb.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure creating Access Account.",
          cause: error
        }
      }
  end

  @spec update_access_account(
          Types.access_account_id() | Data.SystAccessAccounts.t(),
          Types.access_account_params()
        ) ::
          {:ok, Data.SystAccessAccounts.t()} | {:error, MscmpSystError.t()}
  def update_access_account(access_account_id, access_account_params)
      when is_binary(access_account_id) do
    MscmpSystDb.get!(Data.SystAccessAccounts, access_account_id)
    |> update_access_account(access_account_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure updating Access Account by ID.",
          cause: error
        }
      }
  end

  def update_access_account(%Data.SystAccessAccounts{} = access_account, access_account_params) do
    access_account
    |> Data.SystAccessAccounts.update_changeset(access_account_params)
    |> MscmpSystDb.update!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure updating Access Account.",
          cause: error
        }
      }
  end

  @spec get_access_account_id_by_name(Types.access_account_name()) ::
          {:ok, Types.access_account_id()} | {:error, MscmpSystError.t()}
  def get_access_account_id_by_name(access_account_name) when is_binary(access_account_name) do
    from(aa in Data.SystAccessAccounts,
      select: aa.id,
      where: aa.internal_name == ^access_account_name
    )
    |> MscmpSystDb.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure retrieving Access Account ID by internal name.",
          cause: error
        }
      }
  end

  @spec get_access_account_by_name(Types.access_account_name()) ::
          Data.SystAccessAccounts.t() | {:error, MscmpSystError.t()}
  def get_access_account_by_name(access_account_name) do
    from(
      aa in Data.SystAccessAccounts,
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

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure retrieving Access Account data.",
          cause: error
        }
      }
  end

  @spec purge_access_account(Types.access_account_id() | Data.SystAccessAccounts.t()) ::
          :ok | {:error, MscmpSystError.t()}
  def purge_access_account(access_account_id) when is_binary(access_account_id) do
    from(
      aa in Data.SystAccessAccounts,
      join: aas in assoc(aa, :access_account_state),
      join: aasft in assoc(aas, :functional_type),
      where: aa.id == ^access_account_id,
      preload: [access_account_state: {aas, functional_type: aasft}]
    )
    |> MscmpSystDb.one!()
    |> purge_access_account()
  end

  def purge_access_account(
        %Data.SystAccessAccounts{
          access_account_state: %MscmpSystEnums.Data.SystEnumItems{
            functional_type: %MscmpSystEnums.Data.SystEnumFunctionalTypes{
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

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure purging Access Account.",
          cause: error
        }
      }
  end

  def purge_access_account(%Data.SystAccessAccounts{id: access_account_id}),
    do: purge_access_account(access_account_id)
end
