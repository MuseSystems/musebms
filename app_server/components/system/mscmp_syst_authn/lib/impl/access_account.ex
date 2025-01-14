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

  ##############################################################################
  #
  # create_access_account
  #
  #

  @spec create_access_account(Types.access_account_params()) ::
          {:ok, Msdata.SystAccessAccounts.t()} | {:error, term()}
  def create_access_account(access_account_params) do
    access_account_params
    |> Msdata.SystAccessAccounts.insert_changeset()
    |> MscmpSystDb.insert(returning: true)
  end

  ##############################################################################
  #
  # get_access_account_state_by_name
  #
  #

  @spec get_access_account_state_by_name(Types.access_account_state_name()) ::
          Msdata.SystEnumItems.t() | nil
  def get_access_account_state_by_name(access_account_state_name),
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
          {:ok, Msdata.SystAccessAccounts.t()} | {:error, :not_found} | {:error, term()}
  def update_access_account(access_account_id, access_account_params)
      when is_binary(access_account_id) do
    MscmpSystDb.get(Msdata.SystAccessAccounts, access_account_id)
    |> case do
      nil -> {:error, :not_found}
      access_account -> update_access_account(access_account, access_account_params)
    end
  end

  def update_access_account(%Msdata.SystAccessAccounts{} = access_account, access_account_params) do
    access_account
    |> Msdata.SystAccessAccounts.update_changeset(access_account_params)
    |> MscmpSystDb.update(returning: true)
  end

  ##############################################################################
  #
  # get_access_account_id_by_name
  #
  #

  @spec get_access_account_id_by_name(Types.access_account_name()) ::
          {:ok, Types.access_account_id()} | {:error, :not_found} | {:error, term()}
  def get_access_account_id_by_name(access_account_name) when is_binary(access_account_name) do
    from(aa in Msdata.SystAccessAccounts,
      select: aa.id,
      where: aa.internal_name == ^access_account_name
    )
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      access_account_id -> {:ok, access_account_id}
    end
  end

  ##############################################################################
  #
  # get_access_account_by_name
  #
  #

  @spec get_access_account_by_name(Types.access_account_name()) ::
          {:ok, Msdata.SystAccessAccounts.t()} | {:error, :not_found} | {:error, term()}
  def get_access_account_by_name(access_account_name) do
    from(
      aa in Msdata.SystAccessAccounts,
      join: aas in assoc(aa, :access_account_state),
      join: aasft in assoc(aas, :functional_type),
      where: aa.internal_name == ^access_account_name,
      preload: [access_account_state: {aas, functional_type: aasft}]
    )
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      access_account -> {:ok, access_account}
    end
  end

  ##############################################################################
  #
  # purge_access_account
  #
  #

  @spec purge_access_account(Types.access_account_id() | Msdata.SystAccessAccounts.t()) ::
          :ok | {:error, :not_found} | {:error, term()}
  def purge_access_account(access_account_id) when is_binary(access_account_id) do
    from(
      aa in Msdata.SystAccessAccounts,
      join: aas in assoc(aa, :access_account_state),
      join: aasft in assoc(aas, :functional_type),
      where: aa.id == ^access_account_id,
      preload: [access_account_state: {aas, functional_type: aasft}]
    )
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      access_account -> purge_access_account(access_account)
    end
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
    with :ok <- maybe_purge_eligible(functional_type) do
      MscmpSystDb.delete(access_account)
      |> case do
        {:ok, _} -> :ok
        error -> {:error, {:database_error, error}}
      end
    end
  end

  def purge_access_account(%Msdata.SystAccessAccounts{id: access_account_id}),
    do: purge_access_account(access_account_id)

  defp maybe_purge_eligible("access_account_states_purge_eligible"), do: :ok
  defp maybe_purge_eligible(functional_type), do: {:error, {:purge_ineligible, functional_type}}

  ##############################################################################
  #
  # access_accounts_exist?
  #
  #

  @spec access_accounts_exist?() :: boolean()
  def access_accounts_exist? do
    Msdata.SystAccessAccounts
    |> MscmpSystDb.exists?()
  end

  ##############################################################################
  #
  # access_account_name_exists?
  #
  #

  @spec access_account_name_exists?(Types.access_account_name()) :: boolean()
  def access_account_name_exists?(access_account_name) when is_binary(access_account_name) do
    Msdata.SystAccessAccounts
    |> where(internal_name: ^access_account_name)
    |> MscmpSystDb.exists?()
  end

  ##############################################################################
  #
  # access_account_id_exists?
  #
  #

  @spec access_account_id_exists?(Types.access_account_id()) :: boolean()
  def access_account_id_exists?(access_account_id) when is_binary(access_account_id) do
    Msdata.SystAccessAccounts
    |> where(id: ^access_account_id)
    |> MscmpSystDb.exists?()
  end
end
