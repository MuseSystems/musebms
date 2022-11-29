# Source File: datastore.ex
# Location:    musebms/components/system/mscmp_syst_db/lib/runtime/datastore.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.Runtime.Datastore do
  use Ecto.Repo,
    otp_app: :mscmp_syst_db,
    adapter: Ecto.Adapters.Postgres

  alias MscmpSystDb.Types

  require Logger

  @query_log_level :debug

  # TODO: figure out why start_datastore_post_processing fails the Dialyzer
  #       test.  Insofar as I've been able to see, it shouldn't cause a no_match
  #       warning.
  @dialyzer {:no_match, start_datastore_post_processing: 2}

  @moduledoc false

  @spec get_datastore_child_spec(Types.datastore_options(), Keyword.t()) ::
          Supervisor.child_spec()
  def get_datastore_child_spec(datastore_options, opts)
      when is_map(datastore_options) and is_list(opts) do
    %{
      id: __MODULE__,
      start:
        {MscmpSystDb.Datastore, :start_link, [[{:datastore_options, datastore_options} | opts]]},
      type: :supervisor,
      restart: :transient
    }
  end

  @spec start_link_datastore(Keyword.t()) :: Supervisor.on_start_child()
  def start_link_datastore(opts) when is_list(opts) do
    {:ok, datastore_options} = validate_datastore_options(opts[:datastore_options])

    opts =
      MscmpSystUtils.resolve_options(opts,
        strategy: :one_for_one,
        name: datastore_options.datastore_name,
        restart: :transient,
        timeout: 60_000
      )

    {:ok, datastore_supervisor_pid} = DynamicSupervisor.start_link(opts)

    start_datastore(datastore_options, opts[:name])
    |> start_datastore_post_processing(datastore_supervisor_pid)
  rescue
    error ->
      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "The Datastore failed to start.",
         cause: error
       }}
  end

  @spec start_datastore(
          MscmpSystDb.Types.datastore_options(),
          Supervisor.supervisor() | nil
        ) ::
          {:ok, :all_started | :some_started, list(Types.context_state_values())}
          | {:error, MscmpSystError.t()}
  def start_datastore(datastore_options, supervisor_name) when is_map(datastore_options) do
    datastore_options.contexts
    |> Enum.filter(&(&1.login_context and &1.start_context))
    |> Enum.map_reduce(nil, &ds_start_map_reduce(supervisor_name, datastore_options, &1, &2))
    |> case do
      {_context_states, :error} ->
        {
          :error,
          %MscmpSystError{
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
        %MscmpSystError{
          code: :database_error,
          message: "Failure to start datastore.",
          cause: error
        }
      }
  end

  defp ds_start_map_reduce(nil, datastore_options, context, acc) do
    start_datastore_context(datastore_options, context)
    |> ds_start_map_reduce_value(acc, context.context_name)
  end

  defp ds_start_map_reduce(supervisor_name, datastore_options, context, acc) do
    opts = [datastore_context: context]

    context_child_spec = get_context_child_spec(datastore_options, context.context_name, opts)

    DynamicSupervisor.start_child(supervisor_name, context_child_spec)
    |> ds_start_map_reduce_value(acc, context.context_name)
  end

  defp ds_start_map_reduce_value({:ok, _pid}, acc, context_id) when acc in [nil, :all_started] do
    {%{context: context_id, state: :started}, :all_started}
  end

  defp ds_start_map_reduce_value({:ok, _pid}, acc, context_id)
       when acc in [:some_started, :error] do
    {%{context: context_id, state: :started}, :some_started}
  end

  defp ds_start_map_reduce_value({:error, {:already_started, pid}}, acc, context_id) do
    ds_start_map_reduce_value({:ok, pid}, acc, context_id)
  end

  defp ds_start_map_reduce_value({:error, _}, acc, context_id) when acc in [nil, :error] do
    {%{context: context_id, state: :not_started}, :error}
  end

  defp ds_start_map_reduce_value({:error, _}, acc, context_id)
       when acc in [:all_started, :some_started] do
    {%{context: context_id, state: :not_started}, :some_started}
  end

  defp start_datastore_post_processing({:ok, result, context_states}, datastore_supervisor_pid),
    do: {:ok, datastore_supervisor_pid, {result, context_states}}

  defp start_datastore_post_processing({:error, _reason} = error, datastore_supervisor_pid) do
    DynamicSupervisor.stop(datastore_supervisor_pid, error, 60_000)
    error
  end

  @spec get_context_child_spec(Types.datastore_options(), Types.context_name(), Keyword.t()) ::
          Supervisor.child_spec()
  def get_context_child_spec(datastore_options, context_name, opts)
      when is_atom(context_name) and is_list(opts) do
    %{
      id: context_name,
      start:
        {MscmpSystDb.DatastoreContext, :start_link,
         [[{:datastore_options, datastore_options} | opts]]},
      type: :worker,
      restart: :transient
    }
  end

  @spec start_link_context(Keyword.t()) :: Supervisor.on_start_child()
  def start_link_context(opts) when is_list(opts) do
    {:ok, datastore_options} = validate_datastore_options(opts[:datastore_options])

    {:ok, context} = validate_datastore_context(opts[:datastore_context])

    start_datastore_context(datastore_options, context)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure starting Datastore Context.",
         cause: error
       }}
  end

  defp validate_datastore_context(context_name) when is_atom(context_name),
    do: {:ok, context_name}

  defp validate_datastore_context(%{context_name: context_name} = datastore_context)
       when is_binary(context_name) or is_atom(context_name),
       do: {:ok, datastore_context}

  defp validate_datastore_context(datastore_context) do
    {:error,
     %MscmpSystError{
       code: :invalid_parameter,
       message: "The datastore_context parameter must be provided and valid.",
       cause: %{parameters: datastore_context}
     }}
  end

  @spec start_datastore_context(Types.datastore_options(), atom() | Types.datastore_context()) ::
          {:ok, pid()} | {:error, MscmpSystError.t()}
  def start_datastore_context(datastore_options, context) when is_map(context) do
    [
      name: context.context_name,
      database: datastore_options.database_name,
      hostname: datastore_options.db_server.db_host,
      port: datastore_options.db_server.db_port,
      username: context.database_role,
      password: context.database_password,
      show_sensitive_data_on_connection_error: datastore_options.db_server.db_show_sensitive,
      pool_size: context.starting_pool_size,
      types: MscmpSystDb.DbTypes.PostgrexTypes,
      log: @query_log_level
    ]
    |> start_link()
    |> maybe_context_start_result()
  catch
    error ->
      {
        :error,
        %MscmpSystError{
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
    raise MscmpSystError,
      code: :database_error,
      message: "Failed to start datastore context.",
      cause: reason
  end

  defp validate_datastore_options(%{datastore_name: datastore_name} = datastore_options)
       when is_atom(datastore_name),
       do: {:ok, datastore_options}

  defp validate_datastore_options(datastore_options) do
    {:error,
     %MscmpSystError{
       code: :invalid_parameter,
       message: "The datastore_options parameter must be provided and valid.",
       cause: %{parameters: datastore_options}
     }}
  end

  @spec stop_datastore(
          Types.datastore_options()
          | list(Types.datastore_context())
          | list(%{context_name: Types.context_name()}),
          non_neg_integer()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  def stop_datastore(%{contexts: contexts}, shutdown_timeout),
    do: stop_datastore(contexts, shutdown_timeout)

  def stop_datastore(contexts, shutdown_timeout) when is_list(contexts) do
    contexts
    |> Enum.filter(&(Ecto.Repo.all_running() |> Enum.member?(&1.context_name)))
    |> Enum.each(&stop_datastore_context(&1, shutdown_timeout))
  catch
    error ->
      {
        :error,
        %MscmpSystError{
          code: :database_error,
          message: "Failure to start datastore contexts.",
          cause: error
        }
      }
  end

  @spec stop_datastore_context(pid() | atom() | Types.datastore_context(), non_neg_integer()) ::
          :ok
  def stop_datastore_context(context, shutdown_timeout) when is_map(context) do
    context.context_name
    |> stop_datastore_context(shutdown_timeout)
  end

  def stop_datastore_context(context, shutdown_timeout)
      when is_pid(context) or is_atom(context) do
    Supervisor.stop(context, :normal, shutdown_timeout)
  end

  @spec query_for_none(iodata(), [term()], Keyword.t()) :: :ok | {:error, MscmpSystError.t()}
  def query_for_none(query, query_params \\ [], opts \\ []) do
    case query(query, query_params, opts) do
      {:ok, _query_result} ->
        :ok

      {_result, error_result} ->
        {:error,
         %MscmpSystError{
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
        raise MscmpSystError,
          code: :database_error,
          message: "Failed querying for single value.",
          cause: reason
    end
  end

  @spec query_for_value(iodata(), [term()], Keyword.t()) ::
          {:ok, any()} | {:error, MscmpSystError.t()}
  def query_for_value(query, query_params \\ [], opts \\ []) do
    case query(query, query_params, opts) do
      {:ok, %{num_rows: 1, rows: [[result_value | _] | _]}} ->
        {:ok, result_value}

      {_result, error_result} ->
        {:error,
         %MscmpSystError{
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
        raise MscmpSystError,
          code: :database_error,
          message: "Failed querying for single value.",
          cause: reason
    end
  end

  @spec query_for_one(iodata(), [term()], Keyword.t()) ::
          {:ok, [any()]} | {:error, MscmpSystError.t()}
  def query_for_one(query, query_params \\ [], opts \\ []) do
    case query(query, query_params, opts) do
      {:ok, %{num_rows: 1, rows: [result_row | _]}} ->
        {:ok, result_row}

      {_result, error_result} ->
        {:error,
         %MscmpSystError{
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
        raise MscmpSystError,
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
          | {:error, MscmpSystError.t()}
  def query_for_many(query, query_params \\ [], opts \\ []) do
    case query(query, query_params, opts) do
      query_result = {:ok, _result} ->
        query_result

      {_result, error_result} ->
        {:error,
         %MscmpSystError{
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
        raise MscmpSystError,
          code: :database_error,
          message: "Failed querying for rows.",
          cause: reason
    end
  end

  # -----------------------------------------------------------------------------
  # Ecto.Repo Query API Wrappers
  # -----------------------------------------------------------------------------

  @spec put_datastore_context(pid() | Ecto.Repo.t() | Ecto.Adapter.adapter_meta()) ::
          atom() | pid()
  def put_datastore_context(context), do: put_dynamic_repo(context)

  @spec current_datastore_context :: atom() | pid()
  def current_datastore_context, do: get_dynamic_repo()

  @spec ecto_transaction(
          fun_or_multi :: (... -> any()) | Ecto.Multi.t(),
          opts :: Keyword.t()
        ) :: {:ok, any()} | {:error, MscmpSystError.t()}
  def ecto_transaction(job, opts \\ []) do
    case transaction(job, opts) do
      transaction_result = {:ok, _result} ->
        transaction_result

      {:error, reason} ->
        {
          :error,
          %MscmpSystError{
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
