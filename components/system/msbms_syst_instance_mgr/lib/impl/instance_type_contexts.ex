# Source File: instance_type_contexts.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/instance_type_contexts.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.InstanceTypeContexts do
  import Ecto.Query
  import MsbmsSystUtils

  require Logger

  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Types

  @moduledoc false

  ######
  #
  # Logic for managing and accessing SystInstanceTypeContexts data.
  #
  # Note that SystInstanceTypeContexts records are created and destroyed
  # automatically in the database when SystInstanceTypeApplications records are
  # created or destroyed.  This happens via database trigger on
  # msbms_syst_data.syst_instance_type_applications and foreign key constraints
  # on msbms_syst_data.syst_instance_type_contexts.
  #
  ######

  @spec list_instance_type_contexts(
          Keyword.t(
            filters:
              Keyword.t(
                instance_type_name: Types.instance_type_name(),
                instance_type_id: Ecto.UUID.t(),
                login_context: boolean(),
                database_owner_context: boolean(),
                application_name: Types.application_name()
              )
              | []
              | nil,
            extra_data: list(:instance_type | :application_context),
            sorts: list(:instance_type | :application_context)
          )
        ) ::
          {:ok, [Data.SystInstanceTypeContexts.t()]} | {:error, MsbmsSystError.t()}
  def list_instance_type_contexts(opts_given) do
    opts = resolve_options(opts_given, filters: nil, extra_data: nil, sorts: nil)

    instance_type_context_base_query()
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
          message: "Failure retrieving Instance Type Contexts.",
          cause: error
        }
      }
  end

  @spec get_instance_type_context_by_id(
          Types.instance_type_context_id(),
          Keyword.t(extra_data: list(:instance_type | :application_context))
        ) ::
          {:ok, Data.SystApplicationContexts.t()} | {:error, MsbmsSystError.t()}
  def get_instance_type_context_by_id(instance_type_context_id, opts)
      when is_binary(instance_type_context_id) do
    opts = resolve_options(opts, extra_data: [])

    instance_type_context_base_query()
    |> maybe_add_joins(opts)
    |> maybe_add_extra_data(opts[:extra_data])
    |> where([instance_type_context: itc], itc.id == ^instance_type_context_id)
    |> MsbmsSystDatastore.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving Instance Type Context by ID.",
          cause: error
        }
      }
  end

  defp instance_type_context_base_query() do
    from(itc in Data.SystInstanceTypeContexts, as: :instance_type_context)
  end

  #
  # Join Section
  #

  defp maybe_add_joins(query, [_ | _] = options) do
    ((options[:extra_data] || []) ++
       Enum.reduce(Keyword.keys(options[:filters] || []), [], &add_filter_join_item/2) ++
       (options[:sorts] || []))
    |> Enum.uniq()
    |> Enum.reduce(query, &add_join(&1, &2))
  end

  defp add_filter_join_item(:instance_type_name, join_list), do: [:instance_type | join_list]
  defp add_filter_join_item(:instance_type_id, join_list), do: [:instance_type | join_list]
  defp add_filter_join_item(:login_context, join_list), do: [:application_context | join_list]

  defp add_filter_join_item(:database_owner_context, join_list),
    do: [:application_context | join_list]

  defp add_filter_join_item(:application_name, join_list),
    do: [:application_context, :application | join_list]

  defp add_filter_join_item(_, join_list), do: join_list

  defp add_join(:application_context, query) do
    from([instance_type_context: itc] in query,
      join: ac in assoc(itc, :application_context),
      as: :application_context,
      join: a in assoc(ac, :application),
      as: :application
    )
  end

  defp add_join(:instance_type, query) do
    from([instance_type_context: itc] in query,
      join: ita in assoc(itc, :instance_type_application),
      as: :instance_type_application,
      join: it in assoc(ita, :instance_type),
      as: :instance_type
    )
  end

  defp add_join(:application, query) do
    from([application_context: ac] in query, join: a in assoc(ac, :application))
  end

  #
  # Filter Section
  #

  defp maybe_add_filters(query, [_ | _] = filters) do
    Enum.reduce(filters, query, &add_filter(&1, &2))
  end

  defp maybe_add_filters(query, _filters), do: query

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

  defp add_filter({:login_context, login_context}, query) do
    from([application_context: ac] in query, where: ac.login_context == ^login_context)
  end

  defp add_filter({:database_owner_context, database_owner_context}, query) do
    from([application_context: ac] in query,
      where: ac.database_owner_context == ^database_owner_context
    )
  end

  defp add_filter({:application_name, application_name}, query) do
    from([application: a] in query, where: a.internal_name == ^application_name)
  end

  defp add_filter(filter, _query) do
    raise MsbmsSystError,
      code: :invalid_parameter,
      message: "Invalid filter requested.",
      cause: filter
  end

  #
  # Sort Section
  #

  defp maybe_add_sorts(query, [_ | _] = sorts) do
    Enum.reduce(sorts, query, &add_sort(&1, &2))
  end

  defp maybe_add_sorts(query, _sorts), do: query

  defp add_sort(:application_context, query) do
    from([application_context: ac] in query, order_by: ac.display_name)
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

  #
  # Extra Data Section
  #

  defp maybe_add_extra_data(query, [_ | _] = extra_data) do
    Enum.reduce(extra_data, query, &add_preload(&1, &2))
  end

  defp maybe_add_extra_data(query, _extra_data), do: query

  defp add_preload(:application_context, query) do
    from([application_context: ac] in query, preload: [application_context: ac])
  end

  defp add_preload(:instance_type, query) do
    from([instance_type_application: ita, instance_type: it] in query,
      preload: [instance_type_application: {ita, instance_type: it}]
    )
  end

  defp add_preload(extra_data, _query) do
    raise MsbmsSystError,
      code: :invalid_parameter,
      message: "Invalid extra data requested.",
      cause: extra_data
  end

  @spec set_instance_type_context_db_pool_size(
          Types.instance_type_context_id(),
          non_neg_integer()
        ) ::
          {:ok, Data.SystInstanceTypeContexts.t()} | {:error, MsbmsSystError.t()}
  def set_instance_type_context_db_pool_size(instance_type_context_id, default_db_pool_size) do
    MsbmsSystDatastore.get!(Data.SystInstanceTypeContexts, instance_type_context_id)
    |> Data.SystInstanceTypeContexts.update_changeset(%{
      default_db_pool_size: default_db_pool_size
    })
    |> MsbmsSystDatastore.update!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure updating Instance Type Context.",
          cause: error
        }
      }
  end
end
