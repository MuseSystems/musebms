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
  @moduledoc false

  use Ecto.Repo,
    otp_app: :mscmp_syst_db,
    adapter: Ecto.Adapters.Postgres

  alias MscmpSystDb.Types
  alias MscmpSystDb.Types.{ContextState, DatastoreContext, DatastoreOptions}

  require Logger

  @query_log_level :debug

  ##############################################################################
  #
  # Options Definition
  #

  option_defs = [
    datastore_name: [
      type:
        {:or,
         [nil, :atom, {:tuple, [{:in, [:via]}, :atom, :any]}, {:tuple, [{:in, [:global]}, :any]}]},
      type_doc: "`t:GenServer.name/0 or `nil`",
      doc: """
      Specifies the name for the Datastore Supervisor. If this option is not
      provided, the `datastore_options.datastore_name` value will be used as
      the default name for the Datastore Supervisor.  If this value identifies a
      process registry (e.g. `{:via, Registry, {MyApp.Registry, :my_registry}}`),
      this registry will become the default registry for all Datastore Contexts;
      a valid `context_registry value overrides this default.
      """
    ],
    context_registry: [
      type: {:or, [:atom, nil]},
      type_doc: "`t:module/0` or `nil`",
      doc: """
      Specifies the name of a registry to use for registering named Datastore
      Contexts.
      """
    ],
    db_shutdown_timeout: [
      type: :pos_integer,
      default: 60_000,
      doc: """
      Specifies the timeout value for the Datastore Context. The default
      timeout is 60,000 milliseconds (60 seconds).
      """
    ],
    strategy: [
      type: :atom,
      default: :one_for_one,
      doc: """
      Specifies the restart strategy for the Datastore Supervisor. The default
      strategy is `:one_for_one`.
      """
    ],
    restart: [
      type: :atom,
      default: :transient,
      doc: """
      Specifies the restart strategy for the Datastore Supervisor. The default
      restart strategy is `:transient`.
      """
    ],
    timeout: [
      type: :pos_integer,
      default: 60_000,
      doc: """
      Specifies the timeout value for the Datastore Supervisor. The default
      timeout is 60,000 milliseconds (60 seconds).
      """
    ],
    context_name: [
      type: :string,
      doc: """
      Specifies the name for the Datastore Context. This name is used to look up
      a specific context from the Datastore Options.
      """
    ]
  ]

  ##############################################################################
  #
  # get_datastore_child_spec
  #

  @get_datastore_child_spec_opts NimbleOptions.new!(
                                   Keyword.take(option_defs, [
                                     :datastore_name,
                                     :strategy,
                                     :restart,
                                     :timeout,
                                     :context_registry
                                   ])
                                 )

  @spec get_get_datastore_child_spec_opts_docs() :: String.t()
  def get_get_datastore_child_spec_opts_docs,
    do: NimbleOptions.docs(@get_datastore_child_spec_opts)

  @spec get_datastore_child_spec(DatastoreOptions.t(), Keyword.t()) :: Supervisor.child_spec()
  def get_datastore_child_spec(datastore_options, opts)
      when is_map(datastore_options) and is_list(opts) do
    opts = NimbleOptions.validate!(opts, @get_datastore_child_spec_opts)

    %{
      id: __MODULE__,
      start: {MscmpSystDb.Datastore, :start_link, [datastore_options, opts]},
      type: :supervisor,
      restart: :transient
    }
  end

  ##############################################################################
  #
  # start_link_datastore
  #

  @start_link_datastore_opts NimbleOptions.new!(
                               Keyword.take(option_defs, [
                                 :datastore_name,
                                 :strategy,
                                 :restart,
                                 :timeout,
                                 :context_registry
                               ])
                             )

  @spec get_start_link_datastore_opts_docs() :: String.t()
  def get_start_link_datastore_opts_docs,
    do: NimbleOptions.docs(@start_link_datastore_opts)

  @spec start_link_datastore(DatastoreOptions.t(), Keyword.t()) :: Supervisor.on_start()
  def start_link_datastore(%DatastoreOptions{} = datastore_options, opts) when is_list(opts) do
    opts = NimbleOptions.validate!(opts, @start_link_datastore_opts)

    supervisor_opts = Keyword.merge(opts, name: opts[:datastore_name])

    {:ok, datastore_supervisor_pid} =
      DynamicSupervisor.start_link(supervisor_opts)

    datastore_opts = Keyword.take(opts, [:datastore_name, :context_registry])

    start_datastore(datastore_options, datastore_opts)
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

  ##############################################################################
  #
  # start_datastore
  #

  @start_datastore_opts NimbleOptions.new!(
                          Keyword.take(option_defs, [:datastore_name, :context_registry])
                        )

  @spec get_start_datastore_opts_docs() :: String.t()
  def get_start_datastore_opts_docs,
    do: NimbleOptions.docs(@start_datastore_opts)

  @spec start_datastore(DatastoreOptions.t(), Keyword.t()) ::
          {:ok, :all_started | :some_started, list(Types.context_state_values())}
          | {:error, MscmpSystError.t()}
  def start_datastore(%DatastoreOptions{} = datastore_options, opts) when is_list(opts) do
    opts = NimbleOptions.validate!(opts, @start_datastore_opts)

    resolved_context_registry =
      opts[:context_registry] || extract_registry_from_name(opts[:datastore_name])

    datastore_options.contexts
    |> Enum.filter(&(&1.login_context and &1.start_context))
    |> Enum.map_reduce(
      nil,
      &ds_start_map_reduce(
        opts[:datastore_name],
        resolved_context_registry,
        datastore_options,
        &1,
        &2
      )
    )
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

  defp ds_start_map_reduce(nil, context_registry, datastore_options, context, acc) do
    start_datastore_context(datastore_options, context, context_registry: context_registry)
    |> ds_start_map_reduce_value(acc, context.context_name)
  end

  defp ds_start_map_reduce(supervisor_name, context_registry, datastore_options, context, acc) do
    opts = [context_registry: context_registry]

    context_child_spec = get_context_child_spec(datastore_options, context, opts)

    DynamicSupervisor.start_child(supervisor_name, context_child_spec)
    |> ds_start_map_reduce_value(acc, context.context_name)
  end

  defp ds_start_map_reduce_value({:ok, pid}, acc, context_id) when acc in [nil, :all_started] do
    {%ContextState{context: context_id, state: :started, pid: pid}, :all_started}
  end

  defp ds_start_map_reduce_value({:ok, pid}, acc, context_id)
       when acc in [:some_started, :error] do
    {%ContextState{context: context_id, state: :started, pid: pid}, :some_started}
  end

  defp ds_start_map_reduce_value({:error, {:already_started, pid}}, acc, context_id) do
    ds_start_map_reduce_value({:ok, pid}, acc, context_id)
  end

  defp ds_start_map_reduce_value({:error, _}, acc, context_id) when acc in [nil, :error] do
    {%ContextState{context: context_id, state: :not_started}, :error}
  end

  defp ds_start_map_reduce_value({:error, _}, acc, context_id)
       when acc in [:all_started, :some_started] do
    {%ContextState{context: context_id, state: :not_started}, :some_started}
  end

  # TODO: figure out why start_datastore_post_processing fails the Dialyzer
  #       test.  Insofar as I've been able to see, it shouldn't cause a no_match
  #       warning.
  @dialyzer {:no_match, start_datastore_post_processing: 2}

  defp start_datastore_post_processing({:ok, result, context_states}, datastore_supervisor_pid),
    do: {:ok, datastore_supervisor_pid, {result, context_states}}

  defp start_datastore_post_processing({:error, _reason} = error, datastore_supervisor_pid) do
    DynamicSupervisor.stop(datastore_supervisor_pid, error, 60_000)
    error
  end

  ##############################################################################
  #
  # get_context_child_spec
  #

  @get_context_child_spec_opts NimbleOptions.new!(Keyword.take(option_defs, [:context_registry]))

  @spec get_get_context_child_spec_opts_docs() :: String.t()
  def get_get_context_child_spec_opts_docs,
    do: NimbleOptions.docs(@get_context_child_spec_opts)

  @spec get_context_child_spec(
          DatastoreOptions.t(),
          Types.context_name() | DatastoreContext.t(),
          Keyword.t()
        ) ::
          Supervisor.child_spec()
  def get_context_child_spec(datastore_options, context_name, opts)
      when is_binary(context_name) and is_list(opts) do
    opts = NimbleOptions.validate!(opts, @get_context_child_spec_opts)

    context = Enum.find(datastore_options.contexts, &(&1.context_name == context_name))

    get_context_child_spec(datastore_options, context, opts)
  end

  def get_context_child_spec(datastore_options, %DatastoreContext{} = context, opts)
      when is_list(opts) do
    opts = NimbleOptions.validate!(opts, @get_context_child_spec_opts)

    %{
      id: context.context_name,
      start: {MscmpSystDb.DatastoreContext, :start_link, [datastore_options, context, opts]},
      type: :supervisor,
      restart: :transient
    }
  end

  ##############################################################################
  #
  # start_link_context
  #

  @start_link_context_opts NimbleOptions.new!(Keyword.take(option_defs, [:context_registry]))

  @spec get_start_link_context_opts_docs() :: String.t()
  def get_start_link_context_opts_docs,
    do: NimbleOptions.docs(@start_link_context_opts)

  @spec start_link_context(DatastoreOptions.t(), DatastoreContext.t(), Keyword.t()) ::
          Supervisor.on_start()
  def start_link_context(
        %DatastoreOptions{} = datastore_options,
        %DatastoreContext{} = datastore_context,
        opts
      )
      when is_list(opts) do
    opts = NimbleOptions.validate!(opts, @start_link_context_opts)

    {:ok, context} = validate_datastore_context(datastore_context)

    start_datastore_context(datastore_options, context, opts)
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

  defp validate_datastore_context(
         %DatastoreContext{context_name: context_name} = datastore_context
       )
       when is_binary(context_name),
       do: {:ok, datastore_context}

  defp validate_datastore_context(datastore_context) do
    {:error,
     %MscmpSystError{
       code: :invalid_parameter,
       message: "The datastore_context parameter must be provided and valid.",
       cause: %{parameters: datastore_context}
     }}
  end

  ##############################################################################
  #
  # start_datastore_context
  #

  @start_datastore_context_opts NimbleOptions.new!(Keyword.take(option_defs, [:context_registry]))

  @spec get_start_datastore_context_opts_docs() :: String.t()
  def get_start_datastore_context_opts_docs,
    do: NimbleOptions.docs(@start_datastore_context_opts)

  @spec start_datastore_context(
          DatastoreOptions.t(),
          DatastoreContext.t() | Types.context_name(),
          Keyword.t()
        ) ::
          {:ok, pid()} | {:error, MscmpSystError.t()}
  def start_datastore_context(
        %DatastoreOptions{} = datastore_options,
        %DatastoreContext{} = context,
        opts
      ) do
    opts = NimbleOptions.validate!(opts, @start_datastore_context_opts)

    [
      name: nil,
      database: datastore_options.database_name,
      hostname: datastore_options.db_server.db_host,
      port: datastore_options.db_server.db_port,
      username: context.database_role,
      password: context.database_password,
      show_sensitive_data_on_connection_error: datastore_options.db_server.db_show_sensitive,
      pool_size: context.starting_pool_size,
      types: MscmpSystDb.DbTypes.PostgrexTypes,
      log: @query_log_level,
      context_registry: opts[:context_registry],
      context_name: context.context_name
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

  def start_datastore_context(datastore_options, context, opts)
      when is_binary(context) do
    target_context =
      datastore_options.contexts
      |> Enum.find(&(&1.context_name == context))

    start_datastore_context(datastore_options, target_context, opts)
  end

  def start_datastore_context(datastore_options, context, opts) when is_atom(context),
    do: start_datastore_context(datastore_options, Atom.to_string(context), opts)

  ##############################################################################
  #
  # init
  #

  @spec init(context :: :supervisor | :runtime, config :: Keyword.t()) :: {:ok, Keyword.t()}
  def init(:supervisor, config) do
    :ok = register_datastore_context(config[:context_registry], config[:context_name])
    {:ok, config}
  end

  def init(:runtime, config), do: {:ok, config}

  defp register_datastore_context(:global, context_name) do
    :yes = :global.register_name(context_name, self())
    :ok
  end

  defp register_datastore_context(registry, context_name)
       when is_atom(registry) and not is_nil(registry) do
    {:ok, _} = Registry.register(registry, context_name, self())
    :ok
  end

  defp register_datastore_context(nil, _), do: :ok

  defp maybe_context_start_result({:ok, ds_pid}) do
    {:ok, ds_pid}
  end

  defp maybe_context_start_result({:error, {:already_started, ds_pid}}), do: {:ok, ds_pid}

  defp maybe_context_start_result({:error, reason}) do
    raise MscmpSystError,
      code: :database_error,
      message: "Failed to start datastore context.",
      cause: reason
  end

  ##############################################################################
  #
  # stop_datastore
  #

  @stop_datastore_opts NimbleOptions.new!(
                         Keyword.take(option_defs, [:context_registry, :db_shutdown_timeout])
                       )

  @spec get_stop_datastore_opts_docs() :: String.t()
  def get_stop_datastore_opts_docs,
    do: NimbleOptions.docs(@stop_datastore_opts)

  @spec stop_datastore(
          DatastoreOptions.t()
          | list(DatastoreContext.t())
          | list(%{context_name: Types.context_name()}),
          Keyword.t()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  def stop_datastore(%{contexts: contexts}, opts),
    do: stop_datastore(contexts, opts)

  def stop_datastore(contexts, opts) when is_list(contexts) and is_list(opts) do
    opts = NimbleOptions.validate!(opts, @stop_datastore_opts)

    filter_fn = fn context ->
      resolved_context = lookup_context_pid(opts[:context_registry], context.context_name)
      running_repos = Ecto.Repo.all_running()
      Enum.member?(running_repos, resolved_context)
    end

    contexts
    |> Enum.filter(&filter_fn.(&1))
    |> Enum.each(&stop_datastore_context(&1, opts))
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

  ##############################################################################
  #
  # stop_datastore_context
  #

  @stop_datastore_context_opts NimbleOptions.new!(
                                 Keyword.take(option_defs, [
                                   :context_registry,
                                   :db_shutdown_timeout
                                 ])
                               )

  @spec get_stop_datastore_context_opts_docs() :: String.t()
  def get_stop_datastore_context_opts_docs,
    do: NimbleOptions.docs(@stop_datastore_context_opts)

  @spec stop_datastore_context(pid() | atom() | String.t() | DatastoreContext.t(), Keyword.t()) ::
          :ok
  def stop_datastore_context(context, opts) when is_map(context) do
    context.context_name
    |> stop_datastore_context(opts)
  end

  def stop_datastore_context(context, opts) when is_binary(context) do
    lookup_context_pid(opts[:context_registry], context)
    |> stop_datastore_context(opts)
  end

  def stop_datastore_context(context, opts) when is_pid(context) or is_atom(context) do
    opts = NimbleOptions.validate!(opts, @stop_datastore_context_opts)
    Supervisor.stop(context, :normal, opts[:db_shutdown_timeout])
  end

  ##############################################################################
  #
  # Ecto.Repo Query API Wrappers
  #
  ##############################################################################

  @spec query_for_none(iodata()) :: :ok | {:error, MscmpSystError.t()}
  @spec query_for_none(iodata(), [term()]) :: :ok | {:error, MscmpSystError.t()}
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

  @spec query_for_none!(iodata()) :: :ok
  @spec query_for_none!(iodata(), [term()]) :: :ok
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

  @spec query_for_value(iodata()) :: {:ok, any()} | {:error, MscmpSystError.t()}
  @spec query_for_value(iodata(), [term()]) :: {:ok, any()} | {:error, MscmpSystError.t()}
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

  @spec query_for_value!(iodata()) :: any()
  @spec query_for_value!(iodata(), [term()]) :: any()
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

  @spec query_for_one(iodata()) :: {:ok, [any()]} | {:error, MscmpSystError.t()}
  @spec query_for_one(iodata(), [term()]) :: {:ok, [any()]} | {:error, MscmpSystError.t()}
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

  @spec query_for_one!(iodata()) :: [any()]
  @spec query_for_one!(iodata(), [term()]) :: [any()]
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

  @spec query_for_many(iodata()) ::
          {:ok,
           %{
             :rows => nil | [[term()] | binary()],
             :num_rows => non_neg_integer(),
             optional(atom()) => any()
           }}
          | {:error, MscmpSystError.t()}
  @spec query_for_many(iodata(), [term()]) ::
          {:ok,
           %{
             :rows => nil | [[term()] | binary()],
             :num_rows => non_neg_integer(),
             optional(atom()) => any()
           }}
          | {:error, MscmpSystError.t()}
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

  @spec query_for_many!(iodata()) :: %{
          :rows => nil | [[term()] | binary()],
          :num_rows => non_neg_integer(),
          optional(atom()) => any()
        }
  @spec query_for_many!(iodata(), [term()]) :: %{
          :rows => nil | [[term()] | binary()],
          :num_rows => non_neg_integer(),
          optional(atom()) => any()
        }
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

  @spec ecto_transaction(
          fun_or_multi :: (... -> any()) | Ecto.Multi.t(),
          opts :: Keyword.t()
        ) :: {:ok, any()} | {:error, MscmpSystError.t()}
  @spec ecto_transaction(fun_or_multi :: (... -> any()) | Ecto.Multi.t()) ::
          {:ok, any()} | {:error, MscmpSystError.t()}
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

  @spec record_count(any(), atom() | keyword()) :: any()
  def record_count(queryable, opts), do: aggregate(queryable, :count, opts)

  ##############################################################################
  #
  # Process Management
  #
  ##############################################################################

  ##############################################################################
  #
  # put_datastore_context
  #

  @spec put_datastore_context(Types.context_registry(), Types.context_name()) ::
          atom() | pid()
  @spec put_datastore_context(
          pid()
          | Ecto.Repo.t()
          | Ecto.Adapter.adapter_meta()
          | GenServer.name()
        ) ::
          atom() | pid()
  def put_datastore_context(context)
      when is_pid(context) or (is_atom(context) and not is_nil(context)),
      do: put_dynamic_repo(context)

  def put_datastore_context(context_name) when is_tuple(context_name),
    do: lookup_context_pid(context_name) |> put_datastore_context()

  def put_datastore_context(context_registry, context_name) when not is_nil(context_registry),
    do: lookup_context_pid(context_registry, context_name) |> put_datastore_context()

  ##############################################################################
  #
  # current_datastore_context
  #

  @spec current_datastore_context :: atom() | pid() | nil
  def current_datastore_context, do: get_dynamic_repo()

  defp extract_registry_from_name({:global, _}), do: :global
  defp extract_registry_from_name({:via, :global, _}), do: :global
  defp extract_registry_from_name({:via, Registry, {registry_name, _}}), do: registry_name
  defp extract_registry_from_name(_), do: nil

  defp lookup_context_pid({:global, context_name}), do: lookup_context_pid(:global, context_name)

  defp lookup_context_pid({:via, :global, context_name}),
    do: lookup_context_pid(:global, context_name)

  defp lookup_context_pid({:via, Registry, {registry_name, context_name}}),
    do: lookup_context_pid(registry_name, context_name)

  defp lookup_context_pid(_, nil), do: nil

  defp lookup_context_pid(:global, context_name) do
    case :global.whereis_name(context_name) do
      pid when is_pid(pid) ->
        pid

      _ ->
        raise MscmpSystError,
          code: :context_not_found,
          message: "Datastore Context not found in :global registry.",
          cause: %{parameters: %{context_name: context_name}}
    end
  end

  defp lookup_context_pid(context_registry, context_name) when is_atom(context_registry) do
    case Registry.lookup(context_registry, context_name) do
      [{pid, _}] ->
        pid

      _ ->
        raise MscmpSystError,
          code: :context_not_found,
          message: "Datastore Context not found in identified Registry.",
          cause: %{parameters: %{context_registry: context_registry, context_name: context_name}}
    end
  end

  defp lookup_context_pid(nil, context_name), do: context_name
end
