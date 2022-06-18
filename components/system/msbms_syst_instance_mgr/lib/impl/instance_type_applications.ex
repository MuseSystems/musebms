# Source File: instance_type_applications.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/instance_type_applications.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.InstanceTypeApplications do
  import Ecto.Query
  import MsbmsSystUtils

  require Logger

  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Types

  @moduledoc false

  ######
  #
  # Logic for managing and accessing Instance Type Application data.
  #
  # Instance Type Applications is the notion that not all types of defined
  # instance support all Applications; it's possible but not mandatory.
  #
  # In practice, the only possible operations with these records are creating
  # them, reading them, or deleting them.  Updating them after creation is not
  # valid.
  #
  ######

  @spec list_instance_type_applications(
          Keyword.t(
            filters:
              Keyword.t(
                application_id: Types.application_id() | nil,
                application_name: Types.application_name() | nil,
                instance_type_id: Types.instance_type_id() | nil,
                instance_type_name: Types.instance_type_name() | nil
              ),
            sorts: list(:application | :instance_type),
            extra_data: list(:application | :instance_type | :instance_type_contexts)
          )
        ) ::
          {:ok, [Data.SystInstanceTypeApplications.t()]} | {:error, MsbmsSystError.t()}
  def list_instance_type_applications(opts_given) do
    opts = resolve_options(opts_given, filters: nil, sorts: nil, extra_data: nil)

    from(ita in Data.SystInstanceTypeApplications, as: :instance_type_application)
    |> maybe_add_joins(opts)
    |> maybe_add_filters(opts[:filters])
    |> maybe_add_extra_data(opts[:extra_data])
    |> maybe_add_sorts(opts[:sorts])
    |> MsbmsSystDatastore.all()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving Instance Type Applications.",
          cause: error
        }
      }
  end

  # TODO: A fair amount of calls to Enum functions across the same lists,
  # probably can be more efficient but good enough for now.

  defp maybe_add_joins(query, [_ | _] = options) do
    ((options[:extra_data] || []) ++
       Enum.reduce(Keyword.keys(options[:filters] || []), [], &add_filter_join_item/2) ++
       (options[:sorts] || []))
    |> Enum.uniq()
    |> Enum.reduce(query, &add_join(&1, &2))
  end

  defp add_filter_join_item(:application_name, join_list), do: [:application | join_list]
  defp add_filter_join_item(:instance_type_name, join_list), do: [:instance_type | join_list]
  defp add_filter_join_item(_, join_list), do: join_list

  defp add_join(:application, query) do
    from([instance_type_application: ita] in query,
      join: a in assoc(ita, :application),
      as: :application
    )
  end

  defp add_join(:instance_type, query) do
    from([instance_type_application: ita] in query,
      join: it in assoc(ita, :instance_type),
      as: :instance_type
    )
  end

  # TODO: Revisit whether or not a JOIN here would be worthwhile given actual usage knowledge.
  # Meanwhile any preload will be a separate query.
  defp add_join(:instance_type_contexts, query), do: query

  defp maybe_add_filters(query, [_ | _] = filters) do
    Enum.reduce(filters, query, &add_filter(&1, &2))
  end

  defp maybe_add_filters(query, _filters), do: query

  defp add_filter({:application_name, application_name}, query)
       when is_binary(application_name) do
    from([application: a] in query, where: a.internal_name == ^application_name)
  end

  defp add_filter({:application_id, application_id}, query)
       when is_binary(application_id) do
    from([instance_type_application: ita] in query, where: ita.application_id == ^application_id)
  end

  defp add_filter({:instance_type_name, instance_type_name}, query)
       when is_binary(instance_type_name) do
    from([instance_type: it] in query, where: it.internal_name == ^instance_type_name)
  end

  defp add_filter({:instance_type_id, instance_type_id}, query)
       when is_binary(instance_type_id) do
    from([instance_type_application: ita] in query,
      where: ita.instance_type_id == ^instance_type_id
    )
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

  defp add_sort(:application, query) do
    from([application: a] in query, order_by: a.display_name)
  end

  defp add_sort(:instance_type, query) do
    from([instance_type: it] in query, order_by: it.sort_order)
  end

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

  defp add_preload(:application, query) do
    from([application: a] in query, preload: [application: a])
  end

  defp add_preload(:instance_type, query) do
    from([instance_type: it] in query, preload: [instance_type: it])
  end

  defp add_preload(:instance_type_contexts, query) do
    from([instance_type_application: ita] in query, preload: :instance_type_contexts)
  end

  defp add_preload(extra_data, _query) do
    raise MsbmsSystError,
      code: :invalid_parameter,
      message: "Invalid extra data requested.",
      cause: extra_data
  end

  @spec create_instance_type_application(Types.instance_type_id(), Types.application_id()) ::
          {:ok, Data.SystInstanceTypeApplications.t()} | {:error, MsbmsSystError.t()}
  def create_instance_type_application(instance_type_id, application_id)
      when is_binary(instance_type_id) and is_binary(application_id) do
    Data.SystInstanceTypeApplications.insert_changeset(%{
      instance_type_id: instance_type_id,
      application_id: application_id
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
          message: "Failure creating new Instance Type Application.",
          cause: error
        }
      }
  end

  @spec delete_instance_type_application(Types.instance_type_application_id()) ::
          {:ok, {non_neg_integer(), nil | [term()]}} | {:error, MsbmsSystError.t()}
  def delete_instance_type_application(instance_type_application_id)
      when is_binary(instance_type_application_id) do
    from(ita in Data.SystInstanceTypeApplications, where: ita.id == ^instance_type_application_id)
    |> MsbmsSystDatastore.delete_all(returning: true)
    |> maybe_instance_type_application_purged()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting Instance Type Application record.",
          cause: error
        }
      }
  end

  defp maybe_instance_type_application_purged({1, _rows} = delete_result), do: delete_result

  defp maybe_instance_type_application_purged(delete_result) do
    raise MsbmsSystError,
      code: :database_error,
      message: "Failure verifying Instance Type Application record.",
      cause: delete_result
  end
end
