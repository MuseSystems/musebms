# Source File: owner.ex
# Location:    musebms/components/system/msbms_syst_instance_mgr/lib/impl/owner.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystInstanceMgr.Impl.Owner do
  import Ecto.Query

  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Types

  require Logger

  @moduledoc false

  @spec create_owner(Types.owner_params()) ::
          {:ok, Data.SystOwners.t()} | {:error, MscmpSystError.t()}
  def create_owner(owner_params) do
    owner_params
    |> Data.SystOwners.insert_changeset()
    |> MsbmsSystDatastore.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure creating Owner.",
          cause: error
        }
      }
  end

  @spec update_owner(Types.owner_id() | Data.SystOwners.t(), Types.owner_params()) ::
          {:ok, Data.SystOwners.t()} | {:error, MscmpSystError.t()}
  def update_owner(owner_id, owner_params) when is_binary(owner_id) do
    MsbmsSystDatastore.get!(Data.SystOwners, owner_id)
    |> update_owner(owner_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure updating Owner by ID.",
          cause: error
        }
      }
  end

  def update_owner(%Data.SystOwners{} = owner, owner_params) do
    owner
    |> Data.SystOwners.update_changeset(owner_params)
    |> MsbmsSystDatastore.update!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure updating Owner.",
          cause: error
        }
      }
  end

  @spec get_owner_by_name(Types.owner_name()) ::
          {:ok, Data.SystOwners.t()} | {:error, MscmpSystError.t()}
  def get_owner_by_name(owner_name) when is_binary(owner_name) do
    from(
      o in Data.SystOwners,
      join: os in assoc(o, :owner_state),
      join: osft in assoc(os, :functional_type),
      where: o.internal_name == ^owner_name,
      preload: [owner_state: {os, functional_type: osft}]
    )
    |> MsbmsSystDatastore.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure retrieving Owner data.",
          cause: error
        }
      }
  end

  @spec get_owner_id_by_name(Types.owner_name()) ::
          {:ok, Types.owner_id()} | {:error, MscmpSystError.t()}
  def get_owner_id_by_name(owner_name) when is_binary(owner_name) do
    from(o in Data.SystOwners, select: o.id, where: o.internal_name == ^owner_name)
    |> MsbmsSystDatastore.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure retrieving Owner ID.",
          cause: error
        }
      }
  end

  @spec purge_owner(Types.owner_id() | Data.SystOwners.t()) :: :ok | {:error, MscmpSystError.t()}
  def purge_owner(owner_id) when is_binary(owner_id) do
    from(
      o in Data.SystOwners,
      join: os in assoc(o, :owner_state),
      join: osft in assoc(os, :functional_type),
      where: o.id == ^owner_id,
      preload: [owner_state: {os, functional_type: osft}]
    )
    |> MsbmsSystDatastore.one!()
    |> purge_owner()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure purging Owner by ID.",
          cause: error
        }
      }
  end

  def purge_owner(
        %Data.SystOwners{
          owner_state: %MsbmsSystEnums.Data.SystEnumItems{
            functional_type: %MsbmsSystEnums.Data.SystEnumFunctionalTypes{
              internal_name: functional_type
            }
          }
        } = owner
      ) do
    case functional_type do
      "owner_states_purge_eligible" ->
        MsbmsSystDatastore.delete!(owner)
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

      {
        :error,
        %MscmpSystError{
          code: :undefined_error,
          message: "Failure deleting Owner.",
          cause: error
        }
      }
  end

  def purge_owner(%Data.SystOwners{id: owner_id}), do: purge_owner(owner_id)
end
