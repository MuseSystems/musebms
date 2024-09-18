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
          {:ok, Msdata.SystOwners.t()} | {:error, MscmpSystError.t()}
  def create_owner(owner_params) do
    owner_params
    |> Msdata.SystOwners.insert_changeset()
    |> MscmpSystDb.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{code: :undefined_error, message: "Failure creating Owner.", cause: error}}
  end

  ##############################################################################
  #
  # update_owner
  #
  #

  @spec update_owner(Types.owner_id() | Msdata.SystOwners.t(), Types.owner_params()) ::
          {:ok, Msdata.SystOwners.t()} | {:error, MscmpSystError.t()}
  def update_owner(owner_id, owner_params) when is_binary(owner_id) do
    MscmpSystDb.get!(Msdata.SystOwners, owner_id)
    |> update_owner(owner_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure updating Owner by ID.",
         cause: error
       }}
  end

  def update_owner(%Msdata.SystOwners{} = owner, owner_params) do
    owner
    |> Msdata.SystOwners.update_changeset(owner_params)
    |> MscmpSystDb.update!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{code: :undefined_error, message: "Failure updating Owner.", cause: error}}
  end

  ##############################################################################
  #
  # get_owner_state_by_name
  #
  #

  @spec get_owner_state_by_name(Types.owner_state_name()) :: Msdata.SystEnumItems.t() | nil
  def get_owner_state_by_name(owner_state_name) when is_binary(owner_state_name),
    do: MscmpSystEnums.get_enum_item_by_name("owner_states", owner_state_name)

  ##############################################################################
  #
  # get_owner_state_default
  #
  #

  @spec get_owner_state_default(Types.owner_state_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  def get_owner_state_default(nil), do: MscmpSystEnums.get_default_enum_item("owner_states")

  def get_owner_state_default(functional_type) when is_atom(functional_type) do
    MscmpSystEnums.get_default_enum_item("owner_states",
      functional_type_name: Atom.to_string(functional_type)
    )
  end

  ##############################################################################
  #
  # get_owner_by_name
  #
  #

  @spec get_owner_by_name(Types.owner_name()) ::
          {:ok, Msdata.SystOwners.t()} | {:error, MscmpSystError.t()}
  def get_owner_by_name(owner_name) when is_binary(owner_name) do
    from(
      o in Msdata.SystOwners,
      join: os in assoc(o, :owner_state),
      join: osft in assoc(os, :functional_type),
      where: o.internal_name == ^owner_name,
      preload: [owner_state: {os, functional_type: osft}]
    )
    |> MscmpSystDb.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure retrieving Owner data.",
         cause: error
       }}
  end

  ##############################################################################
  #
  # get_owner_id_by_name
  #
  #

  @spec get_owner_id_by_name(Types.owner_name()) ::
          {:ok, Types.owner_id()} | {:error, MscmpSystError.t()}
  def get_owner_id_by_name(owner_name) when is_binary(owner_name) do
    from(o in Msdata.SystOwners, select: o.id, where: o.internal_name == ^owner_name)
    |> MscmpSystDb.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure retrieving Owner ID.",
         cause: error
       }}
  end

  ##############################################################################
  #
  # purge_owner
  #
  #

  @spec purge_owner(Types.owner_id() | Msdata.SystOwners.t()) ::
          :ok | {:error, MscmpSystError.t()}
  def purge_owner(owner_id) when is_binary(owner_id) do
    from(
      o in Msdata.SystOwners,
      join: os in assoc(o, :owner_state),
      join: osft in assoc(os, :functional_type),
      where: o.id == ^owner_id,
      preload: [owner_state: {os, functional_type: osft}]
    )
    |> MscmpSystDb.one!()
    |> purge_owner()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure purging Owner by ID.",
         cause: error
       }}
  end

  def purge_owner(
        %Msdata.SystOwners{
          owner_state: %Msdata.SystEnumItems{
            functional_type: %Msdata.SystEnumFunctionalTypes{
              internal_name: functional_type
            }
          }
        } = owner
      ) do
    case functional_type do
      "owner_states_purge_eligible" ->
        MscmpSystDb.delete!(owner)
        :ok

      _ ->
        raise MscmpSystError,
          code: :invalid_parameter,
          message: "Invalid Owner State Functional Type for purge.",
          cause: %{parameters: [functional_type: functional_type]}
    end
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{code: :undefined_error, message: "Failure deleting Owner.", cause: error}}
  end

  def purge_owner(%Msdata.SystOwners{id: owner_id}), do: purge_owner(owner_id)

  ##############################################################################
  #
  # owner_id_exists?
  #
  #

  @spec owner_id_exists?(Types.owner_id()) :: boolean() | {:error, MscmpSystError.t()}
  def owner_id_exists?(owner_id) when is_binary(owner_id) do
    Msdata.SystOwners
    |> where(id: ^owner_id)
    |> MscmpSystDb.exists?()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure testing if owner exists by ID.",
         cause: error
       }}
  end

  ##############################################################################
  #
  # owner_name_exists?
  #
  #

  @spec owner_name_exists?(Types.owner_name()) :: boolean() | {:error, MscmpSystError.t()}
  def owner_name_exists?(owner_name) when is_binary(owner_name) do
    Msdata.SystOwners
    |> where(internal_name: ^owner_name)
    |> MscmpSystDb.exists?()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure testing if owner exists by name.",
         cause: error
       }}
  end

  ##############################################################################
  #
  # owners_exist?
  #
  #

  @spec owners_exist?() :: boolean() | {:error, MscmpSystError.t()}
  def owners_exist? do
    Msdata.SystOwners |> MscmpSystDb.exists?()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure testing if any owners exist.",
         cause: error
       }}
  end
end
