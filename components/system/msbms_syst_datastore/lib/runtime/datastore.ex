# Source File: datastore.ex
# Location:    components/system/msbms_syst_datastore/lib/runtime/datastore.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystDatastore.Runtime.Datastore do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :msbms_syst_datastore,
    adapter: Ecto.Adapters.Postgres

  alias MsbmsSystDatastore.Types

  require Logger

  @spec start_datastore(MsbmsSystDatastore.Types.datastore_options()) ::
          {:ok, :all_started | :some_started, list(Types.context_state_values())}
          | {:error, MsbmsSystError.t()}
  def start_datastore(datastore_options) when is_map(datastore_options) do
    datastore_options.contexts
    |> Enum.filter(& &1.start_context)
    |> Enum.map_reduce(nil, &ds_start_map_reduce(datastore_options, &1, &2))
    |> case do
      {_context_states, :error} ->
        {
          :error,
          %MsbmsSystError{
            code: :database_error,
            message: "Failure starting all datastore contexts",
            cause: []
          }
        }

      {context_states, result} ->
        {:ok, result, context_states}
    end
  catch
    error ->
      {
        :error,
        %MsbmsSystError{
          code: :database_error,
          message: "Failure to start datastore.",
          cause: error
        }
      }
  end

  defp ds_start_map_reduce(datastore_options, context, acc) do
    start_datastore_context(datastore_options, context)
    |> ds_start_map_reduce_value(acc, context.id)
  end

  defp ds_start_map_reduce_value({:ok, _pid}, acc, context_id) when acc in [nil, :all_started] do
    {%{context: context_id, state: :started}, :all_started}
  end

  defp ds_start_map_reduce_value({:ok, _pid}, acc, context_id)
       when acc in [:some_started, :error] do
    {%{context: context_id, state: :started}, :some_started}
  end

  defp ds_start_map_reduce_value({:error, _}, acc, context_id) when acc in [nil, :error] do
    {%{context: context_id, state: :not_started}, :error}
  end

  defp ds_start_map_reduce_value({:error, _}, acc, context_id)
       when acc in [:all_started, :some_started] do
    {%{context: context_id, state: :not_started}, :some_started}
  end

  @spec start_datastore_context(Types.datastore_options(), atom() | Types.datastore_context()) ::
          {:ok, pid()} | {:error, MsbmsSystError.t()}
  def start_datastore_context(datastore_options, context) when is_map(context) do
    start_link(
      name: context.id,
      database: datastore_options.database_name,
      hostname: datastore_options.db_server.db_host,
      port: datastore_options.db_server.db_port,
      username: context.database_role,
      password: context.database_password,
      show_sensitive_data_on_connection_error: datastore_options.db_server.db_show_sensitive,
      pool_size: context.starting_pool_size,
      types: MsbmsSystDatastore.DbTypes.PostgrexTypes
    )
    |> maybe_context_start_result()
  catch
    error ->
      {
        :error,
        %MsbmsSystError{
          code: :database_error,
          message: "Failure to start datastore contexts.",
          cause: error
        }
      }
  end

  def start_datastore_context(datastore_options, context) when is_atom(context) do
    target_context =
      datastore_options.contexts
      |> Enum.find(&(String.to_atom(&1.database_role) == context))

    start_datastore_context(datastore_options, target_context)
  end

  defp maybe_context_start_result({:ok, ds_pid}), do: {:ok, ds_pid}
  defp maybe_context_start_result({:error, {:already_started, ds_pid}}), do: {:ok, ds_pid}

  defp maybe_context_start_result({:error, reason}) do
    raise MsbmsSystError,
      code: :database_error,
      message: "Failed to start datastore context.",
      cause: reason
  end

  @spec stop_datastore(Types.datastore_options(), non_neg_integer()) ::
          :ok | {:error, MsbmsSystError.t()}
  def stop_datastore(datastore_options, shutdown_timeout) do
    datastore_options.contexts
    |> Enum.filter(&(&1.id != nil))
    |> Enum.each(&stop_datastore_context(&1, shutdown_timeout))
  catch
    error ->
      {
        :error,
        %MsbmsSystError{
          code: :database_error,
          message: "Failure to start datastore contexts.",
          cause: error
        }
      }
  end

  @spec stop_datastore_context(pid() | atom() | Types.datastore_context(), non_neg_integer()) ::
          :ok
  def stop_datastore_context(context, shutdown_timeout) when is_map(context) do
    context.id
    |> stop_datastore_context(shutdown_timeout)
  end

  def stop_datastore_context(context, shutdown_timeout)
      when is_pid(context) or is_atom(context) do
    _ = set_datastore_context(context)
    stop(shutdown_timeout)
  end

  @spec query_for_none(iodata(), [term()], Keyword.t()) :: :ok | {:error, MsbmsSystError.t()}
  def query_for_none(query, query_params \\ [], opts \\ []) do
    case query(query, query_params, opts) do
      {:ok, _query_result} ->
        :ok

      {_result, error_result} ->
        {:error,
         %MsbmsSystError{
           code: :database_error,
           message: "Failed to verify query success.",
           cause: error_result
         }}
    end
  end

  @spec query_for_none!(iodata(), [term()], Keyword.t()) :: :ok
  def query_for_none!(query, query_params \\ [], opts \\ []) do
    case query_for_none(query, query_params, opts) do
      :ok ->
        :ok

      {:error, reason} ->
        raise MsbmsSystError,
          code: :database_error,
          message: "Failed querying for single value.",
          cause: reason
    end
  end

  @spec query_for_value(iodata(), [term()], Keyword.t()) ::
          {:ok, any()} | {:error, MsbmsSystError.t()}
  def query_for_value(query, query_params \\ [], opts \\ []) do
    case query(query, query_params, opts) do
      {:ok, %{num_rows: 1, rows: [[result_value | _] | _]}} ->
        {:ok, result_value}

      {_result, error_result} ->
        {:error,
         %MsbmsSystError{
           code: :database_error,
           message: "Failed to retrieve current datastore version.",
           cause: error_result
         }}
    end
  end

  @spec query_for_value!(iodata(), [term()], Keyword.t()) :: any()
  def query_for_value!(query, query_params \\ [], opts \\ []) do
    case query_for_value(query, query_params, opts) do
      {:ok, result_value} ->
        result_value

      {:error, reason} ->
        raise MsbmsSystError,
          code: :database_error,
          message: "Failed querying for single value.",
          cause: reason
    end
  end

  @spec query_for_one(iodata(), [term()], Keyword.t()) ::
          {:ok, [any()]} | {:error, MsbmsSystError.t()}
  def query_for_one(query, query_params \\ [], opts \\ []) do
    case query(query, query_params, opts) do
      {:ok, %{num_rows: 1, rows: [result_row | _]}} ->
        {:ok, result_row}

      {_result, error_result} ->
        {:error,
         %MsbmsSystError{
           code: :database_error,
           message: "Failed to retrieve current datastore version.",
           cause: error_result
         }}
    end
  end

  @spec query_for_one!(iodata(), [term()], Keyword.t()) :: [any()]
  def query_for_one!(query, query_params \\ [], opts \\ []) do
    case query_for_one(query, query_params, opts) do
      {:ok, result_value} ->
        result_value

      {:error, reason} ->
        raise MsbmsSystError,
          code: :database_error,
          message: "Failed querying for single row.",
          cause: reason
    end
  end

  @spec query_for_many(iodata(), [term()], Keyword.t()) ::
          {:ok,
           %{
             :rows => nil | [[term()] | binary()],
             :num_rows => non_neg_integer(),
             optional(atom()) => any()
           }}
          | {:error, MsbmsSystError.t()}
  def query_for_many(query, query_params \\ [], opts \\ []) do
    case query(query, query_params, opts) do
      query_result = {:ok, _result} ->
        query_result

      {_result, error_result} ->
        {:error,
         %MsbmsSystError{
           code: :database_error,
           message: "Failed to retrieve current datastore version.",
           cause: error_result
         }}
    end
  end

  @spec query_for_many!(iodata(), [term()], Keyword.t()) :: %{
          :rows => nil | [[term()] | binary()],
          :num_rows => non_neg_integer(),
          optional(atom()) => any()
        }
  def query_for_many!(query, query_params \\ [], opts \\ []) do
    case query_for_many(query, query_params, opts) do
      {:ok, result_value} ->
        result_value

      {:error, reason} ->
        raise MsbmsSystError,
          code: :database_error,
          message: "Failed querying for rows.",
          cause: reason
    end
  end

  # -----------------------------------------------------------------------------
  # Ecto.Repo Query API Wrappers
  # -----------------------------------------------------------------------------

  @spec set_datastore_context(pid() | Ecto.Repo.t() | Ecto.Adapter.adapter_meta()) ::
          atom() | pid()
  def set_datastore_context(context), do: put_dynamic_repo(context)

  @spec current_datastore_context :: atom() | pid()
  def current_datastore_context, do: get_dynamic_repo()

  @spec ecto_transaction(
          fun_or_multi :: (... -> any()) | Ecto.Multi.t(),
          opts :: Keyword.t()
        ) :: {:ok, any()} | {:error, MsbmsSystError.t()}
  def ecto_transaction(job, opts \\ []) do
    case transaction(job, opts) do
      transaction_result = {:ok, _result} ->
        transaction_result

      {:error, reason} ->
        {
          :error,
          %MsbmsSystError{
            code: :database_error,
            message: "Failed processing requested database transaction.",
            cause: reason
          }
        }
    end
  end

  def record_count(queryable, opts) do
    aggregate(queryable, :count, opts)
  end
end
