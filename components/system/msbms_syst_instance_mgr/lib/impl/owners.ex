# Source File: owners.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/owners.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.Owners do
  import Ecto.Query
  import MsbmsSystUtils

  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Types

  require Logger

  @moduledoc false

  ######
  #
  # Logic for managing and accessing SystOwners data.
  #
  ######

  @spec list_owners(
          Keyword.t(
            filters:
              Keyword.t(
                owner_state_functional_types: list(Types.owner_state_functional_types()) | []
              )
              | nil,
            extra_data: list(:owner_state | :owner_state_functional_type) | [] | nil,
            sorts: list(:owner_display_name) | [] | nil
          )
        ) ::
          {:ok, list(Data.SystOwners.t())} | {:error, MsbmsSystError.t()}
  def list_owners(opts) do
    opts = resolve_options(opts, filters: nil, extra_data: nil, sorts: nil)

    # TODO: The joins may be necessary or extraneous depending on the filters or
    # extra data.  Not critical path, but see if they can be made optional.
    from(o in Data.SystOwners,
      as: :owner,
      join: s in assoc(o, :owner_state),
      as: :owner_state,
      join: f in assoc(s, :functional_type),
      as: :owner_state_functional_type
    )
    |> maybe_add_filters(opts[:filters])
    |> maybe_add_sorts(opts[:sorts])
    |> maybe_add_extra_data(opts[:extra_data])
    |> MsbmsSystDatastore.all()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving owners list.",
          cause: error
        }
      }
  end

  defp maybe_add_filters(query, [_ | _] = filters) do
    Enum.reduce(filters, query, &add_filter(&1, &2))
  end

  defp maybe_add_filters(query, _filters), do: query

  defp add_filter({:owner_state_functional_types, functional_types}, query) do
    functional_types
    |> Enum.map(&Atom.to_string/1)
    |> then(&from([owner_state_functional_type: f] in query, where: f.internal_name in ^&1))
  end

  defp add_filter(filter, _query) do
    raise MsbmsSystError,
      code: :invalid_parameter,
      message: "Invalid filter requested.",
      cause: filter
  end

  defp maybe_add_sorts(query, [_ | _] = sorts) do
    Enum.reduce(sorts, query, &add_sort(&1, &2))
  end

  defp maybe_add_sorts(query, _sorts), do: query

  defp add_sort(:owner_display_name, query),
    do: from([owners: o] in query, order_by: o.display_name)

  defp add_sort(sort, _query) do
    raise MsbmsSystError,
      code: :invalid_parameter,
      message: "Invalid sort requested.",
      cause: sort
  end

  defp maybe_add_extra_data(query, [_ | _] = extra_data) do
    Enum.reduce(extra_data, query, &add_preload(&1, &2))
  end

  defp maybe_add_extra_data(query, _extra_data), do: query

  defp add_preload(:owner_state, query),
    do: from([owner_state: s] in query, preload: [owner_state: s])

  defp add_preload(:owner_state_functional_type, query) do
    from([owner_state: s, owner_state_functional_type: sft] in query,
      preload: [owner_state: {s, functional_type: sft}]
    )
  end

  defp add_preload(extra_data, _query) do
    raise MsbmsSystError,
      code: :invalid_parameter,
      message: "Invalid extra data requested.",
      cause: extra_data
  end

  @spec create_owner(Types.owner_name(), String.t(), Ecto.UUID.t()) ::
          {:ok, Data.SystOwners.t()} | {:error, MsbmsSystError.t()}
  def create_owner(owner_name, owner_display_name, owner_state_id) do
    %Data.SystOwners{}
    |> Data.SystOwners.changeset(%{
      internal_name: owner_name,
      display_name: owner_display_name,
      owner_state_id: owner_state_id
    })
    |> MsbmsSystDatastore.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure creating new owner.",
          cause: error
        }
      }
  end

  @spec get_owner_by_name(Types.owner_name()) ::
          {:ok, Data.SystOwners.t()} | {:error, MsbmsSystError.t()}
  def get_owner_by_name(owner_name) do
    from(o in Data.SystOwners,
      join: os in assoc(o, :owner_state),
      where: o.internal_name == ^owner_name,
      preload: [owner_state: os]
    )
    |> MsbmsSystDatastore.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving owner record.",
          cause: error
        }
      }
  end

  @spec set_owner_values(Types.owner_name(), Types.owner_params()) ::
          {:ok, Data.SystOwners.t()} | {:error, MsbmsSystError.t()}
  def set_owner_values(owner_name, owner_params) do
    from(o in Data.SystOwners, where: [internal_name: ^owner_name])
    |> MsbmsSystDatastore.one!()
    |> Data.SystOwners.changeset(owner_params)
    |> MsbmsSystDatastore.update!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure updating existing owner.",
          cause: error
        }
      }
  end

  @spec purge_owner(Types.owner_name()) ::
          {:ok, {non_neg_integer(), nil | [term()]}} | {:error, MsbmsSystError.t()}
  def purge_owner(owner_name) do
    from(o in Data.SystOwners,
      join: s in assoc(o, :owner_state),
      join: f in assoc(s, :functional_type),
      where: o.internal_name == ^owner_name and f.internal_name == "owner_states_purge_eligible"
    )
    |> MsbmsSystDatastore.delete_all(returning: true)
    |> maybe_owner_purged()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure purging an existing owner.",
          cause: error
        }
      }
  end

  defp maybe_owner_purged({1, _rows} = delete_result), do: delete_result

  defp maybe_owner_purged(delete_result) do
    raise MsbmsSystError,
      code: :database_error,
      message: "Failure to delete single owner.",
      cause: delete_result
  end

  @spec purge_all_eligible_owners ::
          {:ok, {non_neg_integer(), nil | [term()]}} | {:error, MsbmsSystError.t()}
  def purge_all_eligible_owners do
    from(o in Data.SystOwners,
      join: s in assoc(o, :owner_state),
      join: f in assoc(s, :functional_type),
      where: f.internal_name == "owner_states_purge_eligible"
    )
    |> MsbmsSystDatastore.delete_all(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure purging eligible owners.",
          cause: error
        }
      }
  end
end
