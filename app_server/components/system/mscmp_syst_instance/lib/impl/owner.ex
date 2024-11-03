# Source File: owner.ex
# Location:    musebms/components/system/mscmp_syst_instance/lib/impl/owner.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Impl.Owner do
  @moduledoc false

  import Ecto.Query

  alias MscmpSystInstance.Types

  require Logger

  ##############################################################################
  #
  # create_owner
  #
  #

  @spec create_owner(Types.owner_params()) ::
          {:ok, Msdata.SystOwners.t()} | {:error, term()}
  def create_owner(owner_params) do
    owner_params
    |> Msdata.SystOwners.insert_changeset()
    |> MscmpSystDb.insert(returning: true)
  end

  ##############################################################################
  #
  # update_owner
  #
  #

  @spec update_owner(Types.owner_id() | Msdata.SystOwners.t(), Types.owner_params()) ::
          {:ok, Msdata.SystOwners.t()} | {:error, term()}
  def update_owner(owner_id, owner_params) when is_binary(owner_id) do
    case MscmpSystDb.get(Msdata.SystOwners, owner_id) do
      nil ->
        {:error, {:not_found, "Owner #{owner_id} not found."}}

      owner ->
        update_owner(owner, owner_params)
    end
  end

  def update_owner(%Msdata.SystOwners{} = owner, owner_params) do
    owner
    |> Msdata.SystOwners.update_changeset(owner_params)
    |> MscmpSystDb.update(returning: true)
  end

  ##############################################################################
  #
  # get_owner_state_by_name
  #
  #

  @spec get_owner_state_by_name(Types.owner_state_name()) :: Msdata.SystEnumItems.t() | nil
  def get_owner_state_by_name(owner_state_name) when is_binary(owner_state_name),
    do: MscmpSystEnums.get_item_by_name("owner_states", owner_state_name)

  ##############################################################################
  #
  # get_owner_state_default
  #
  #

  @spec get_owner_state_default(Types.owner_state_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  def get_owner_state_default(nil), do: MscmpSystEnums.get_default_item("owner_states")

  def get_owner_state_default(functional_type) when is_atom(functional_type) do
    MscmpSystEnums.get_default_item("owner_states",
      functional_type_name: Atom.to_string(functional_type)
    )
  end

  ##############################################################################
  #
  # get_owner_by_name
  #
  #

  @spec get_owner_by_name(Types.owner_name()) ::
          {:ok, Msdata.SystOwners.t()} | {:error, term()}
  def get_owner_by_name(owner_name) when is_binary(owner_name) do
    owner_qry =
      from(
        o in Msdata.SystOwners,
        join: os in assoc(o, :owner_state),
        join: osft in assoc(os, :functional_type),
        where: o.internal_name == ^owner_name,
        preload: [owner_state: {os, functional_type: osft}]
      )

    case MscmpSystDb.one(owner_qry) do
      nil ->
        {:error, {:not_found, "Owner #{owner_name} not found."}}

      owner ->
        {:ok, owner}
    end
  end

  ##############################################################################
  #
  # get_owner_id_by_name
  #
  #

  @spec get_owner_id_by_name(Types.owner_name()) ::
          {:ok, Types.owner_id()} | {:error, term()}
  def get_owner_id_by_name(owner_name) when is_binary(owner_name) do
    owner_qry = from(o in Msdata.SystOwners, select: o.id, where: o.internal_name == ^owner_name)

    case MscmpSystDb.one(owner_qry) do
      nil ->
        {:error, {:not_found, "Owner #{owner_name} not found."}}

      owner_id ->
        {:ok, owner_id}
    end
  end

  ##############################################################################
  #
  # purge_owner
  #
  #

  @spec purge_owner(Types.owner_id() | Msdata.SystOwners.t()) ::
          :ok | {:error, term()}

  def purge_owner(owner_id) when is_binary(owner_id) do
    owner_qry =
      from(
        o in Msdata.SystOwners,
        join: os in assoc(o, :owner_state),
        join: osft in assoc(os, :functional_type),
        where: o.id == ^owner_id,
        preload: [owner_state: {os, functional_type: osft}]
      )

    case MscmpSystDb.one(owner_qry) do
      nil ->
        {:error, {:not_found, "Owner #{owner_id} not found."}}

      owner ->
        purge_owner(owner)
    end
  end

  def purge_owner(
        %Msdata.SystOwners{
          owner_state: %Msdata.SystEnumItems{
            functional_type: %Msdata.SystEnumFunctionalTypes{
              internal_name: "owner_states_purge_eligible"
            }
          }
        } = owner
      ) do
    with {:ok, _} <- MscmpSystDb.delete(owner) do
      :ok
    end
  rescue
    Ecto.StaleEntryError ->
      {:error, {:not_found, owner}}

    error ->
      reraise error, __STACKTRACE__
  end

  def purge_owner(%Msdata.SystOwners{
        id: owner_id,
        owner_state: %Msdata.SystEnumItems{
          functional_type: %Msdata.SystEnumFunctionalTypes{
            internal_name: functional_type_name
          }
        }
      })
      when not is_nil(functional_type_name),
      do: {:error, {:not_allowed, "Owner #{owner_id} is not purge eligible."}}

  def purge_owner(%Msdata.SystOwners{id: owner_id}), do: purge_owner(owner_id)

  ##############################################################################
  #
  # owner_id_exists?
  #
  #

  @spec owner_id_exists?(Types.owner_id()) :: boolean()
  def owner_id_exists?(owner_id) do
    Msdata.SystOwners
    |> where(id: ^owner_id)
    |> MscmpSystDb.exists?()
  end

  ##############################################################################
  #
  # owner_name_exists?
  #
  #

  @spec owner_name_exists?(Types.owner_name()) :: boolean()
  def owner_name_exists?(owner_name) do
    Msdata.SystOwners
    |> where(internal_name: ^owner_name)
    |> MscmpSystDb.exists?()
  end

  ##############################################################################
  #
  # owners_exist?
  #
  #

  @spec owners_exist?() :: boolean()
  def owners_exist?, do: Msdata.SystOwners |> MscmpSystDb.exists?()
end
