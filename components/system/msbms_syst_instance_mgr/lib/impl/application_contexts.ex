# Source File: application_contexts.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/application_contexts.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.ApplicationContexts do
  import Ecto.Query
  import MsbmsSystUtils

  require Logger

  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Types

  @moduledoc false

  @spec list_application_contexts(
          Keyword.t(
            filters:
              Keyword.t(
                application_name: Types.application_name() | nil,
                application_id: Ecto.UUID.t() | nil,
                start_context: boolean() | nil,
                login_context: boolean() | nil
              ),
            extra_data: list(:application) | [] | nil,
            sorts: list(:application | :application_context) | nil
          )
        ) ::
          {:ok, [Data.SystApplicationContexts.t()]} | {:error, MsbmsSystError.t()}
  def list_application_contexts(opts) do
    opts = resolve_options(opts, filters: nil, extra_data: nil, sorts: nil)

    application_context_base_query()
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
          message: "Failure retrieving Application Contexts.",
          cause: error
        }
      }
  end

  defp maybe_add_filters(query, [_ | _] = filters) do
    Enum.reduce(filters, query, &add_filter(&1, &2))
  end

  defp maybe_add_filters(query, _filters), do: query

  defp add_filter({:application_name, application_name}, query) do
    from([application: a] in query, where: a.internal_name == ^application_name)
  end

  defp add_filter({:application_id, application_id}, query) do
    from([application: a] in query, where: a.id == ^application_id)
  end

  defp add_filter({:start_context, start_context}, query) do
    from([application_context: ac] in query, where: ac.start_context == ^start_context)
  end

  defp add_filter({:login_context, login_context}, query) do
    from([application_context: ac] in query, where: ac.login_context == ^login_context)
  end

  defp add_filter(filter, _query) do
    raise MsbmsSystError,
      code: :invalid_parameter,
      message: "Invalid filter requested.",
      cause: filter
  end

  defp maybe_add_extra_data(query, [_ | _] = extra_data) do
    Enum.reduce(extra_data, query, &add_preload(&1, &2))
  end

  defp maybe_add_extra_data(query, _extra_data), do: query

  defp add_preload(:application, query),
    do: from([application: a] in query, preload: [application: a])

  defp add_preload(extra_data, _query) do
    raise MsbmsSystError,
      code: :invalid_parameter,
      message: "Invalid extra data requested.",
      cause: extra_data
  end

  defp maybe_add_sorts(query, [_ | _] = sorts) do
    Enum.reduce(sorts, query, &add_sort(&1, &2))
  end

  defp maybe_add_sorts(query, _sorts), do: query

  defp add_sort(:application, query) do
    order_by(query, [application: a], a.display_name)
  end

  defp add_sort(:application_context, query) do
    order_by(query, [application_context: ac], ac.display_name)
  end

  defp add_sort(sort, _query) do
    raise MsbmsSystError,
      code: :invalid_parameter,
      message: "Invalid sort requested.",
      cause: sort
  end

  @spec get_application_context_by_name(Types.application_context_name()) ::
          {:ok, Data.SystApplicationContexts.t()} | {:error, MsbmsSystError.t()}
  def get_application_context_by_name(application_context_name)
      when is_binary(application_context_name) do
    application_context_base_query()
    |> where([application_context: ac], ac.internal_name == ^application_context_name)
    |> MsbmsSystDatastore.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving Application Context by Name.",
          cause: error
        }
      }
  end

  @spec get_application_context_by_id(Types.application_context_id()) ::
          {:ok, Data.SystApplicationContexts.t()} | {:error, MsbmsSystError.t()}
  def get_application_context_by_id(application_context_id)
      when is_binary(application_context_id) do
    application_context_base_query()
    |> where([application_context: ac], ac.id == ^application_context_id)
    |> MsbmsSystDatastore.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving Application Context by ID.",
          cause: error
        }
      }
  end

  # Enough of these functions are just variations on a theme that we might as
  # well have a statement of that theme.
  defp application_context_base_query() do
    from(ac in Data.SystApplicationContexts,
      as: :application_context,
      join: a in assoc(ac, :application),
      as: :application
    )
  end

  @spec get_application_context_id_by_name(Types.application_context_name()) :: Ecto.UUID.t()
  def get_application_context_id_by_name(application_context_name)
      when is_binary(application_context_name) do
    from(ac in Data.SystApplicationContexts,
      where: ac.internal_name == ^application_context_name,
      select: ac.id
    )
    |> MsbmsSystDatastore.one!()
  end

  @spec set_application_context_start_context(Types.application_context_id(), boolean()) ::
          {:ok, Data.SystApplicationContexts.t()}
          | {:error, MsbmsSystError.t()}
  def set_application_context_start_context(application_context_id, start_context) do
    MsbmsSystDatastore.get!(Data.SystApplicationContexts, application_context_id)
    |> Data.SystApplicationContexts.update_changeset(start_context)
    |> MsbmsSystDatastore.update!(returning: true)
    |> then(&{:ok, &1})
  end
end
