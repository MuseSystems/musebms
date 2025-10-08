# Source File: mscmp_syst_limiter.ex
# Location:    musebms/app_server/components/system/mscmp_syst_limiter/lib/api/mscmp_syst_limiter.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystLimiter do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  use MscmpSystService

  use MscmpSystTelemetry,
    component: :mscmp_syst_limiter,
    categories: [:service, :limiter]

  import Msutils.Guards, only: [is_reg_atom: 1]

  alias MscmpSystError.Types.Context, as: ErrorContext
  alias MscmpSystLimiter.Impl
  alias MscmpSystLimiter.Runtime
  alias MscmpSystLimiter.Types
  alias MscmpSystService.Types, as: ServiceTypes

  ##############################################################################
  #
  # Options Definition
  #
  #

  option_defs =
    [
      algorithms: [
        type:
          {:or,
           [
             {:in, [:all]},
             {:list, {:in, [:token_bucket, :semaphore]}}
           ]},
        default: :all,
        type_doc: "`t:MscmpSystLimiter.Types.start_algorithms/0`",
        type_spec: quote(do: MscmpSystLimiter.Types.start_algorithms()),
        doc: """
        The rate limiting algorithms to start.

        This includes all the supported algorithms individually, and the special
        value `:all` which starts backends for all the supported algorithms.
        """
      ],
      cleanup_interval: [
        type: :keyword_list,
        keys: [
          all: [type: :pos_integer, default: 60_000],
          token_bucket: [type: :pos_integer],
          semaphore: [type: :pos_integer]
        ],
        default: [all: 60_000],
        doc: """
        The interval in milliseconds at which to cleanup expired rate limiting
        counters.

        The interval can be specified for all algorithms using the special key
        `:all` or for each algorithm individually.  If not specified, the default
        value of 60,000 milliseconds is used.  If you specify the `:all` key and
        one or more algorithms specific settings, the interval for the `:all`
        value is ignored for the specified algorithms and will only be used as
        the default for the unspecified algorithms.
        """
      ]
    ]

  ##############################################################################
  #
  # child_spec
  #
  #

  @child_spec_opts NimbleOptions.new!(
                     Keyword.take(option_defs, [
                       :algorithms,
                       :cleanup_interval
                     ]) ++ @service_option_defs
                   )
  @doc section: :service_management
  @doc """
  Returns the child specification for starting rate limiting services.

  ## Parameters
    * `opts` - The options to pass to the rate limiting service.

  ## Options

    #{NimbleOptions.docs(@child_spec_opts)}
  """
  @impl true
  @spec child_spec(Keyword.t()) :: Supervisor.child_spec()
  def child_spec(opts) do
    validated_opts = NimbleOptions.validate!(opts, @child_spec_opts)
    %{id: __MODULE__, start: {MscmpSystLimiter, :start_link, [validated_opts]}}
  end

  ##############################################################################
  #
  # start_link
  #
  #

  @start_link_opts NimbleOptions.new!(
                     Keyword.take(option_defs, [
                       :algorithms,
                       :cleanup_interval
                     ]) ++ @service_option_defs
                   )
  @doc section: :service_management
  @doc """
  Starts a rate limiting service.

  ## Parameters
    * `opts` - The options to pass to the rate limiting service.

  ## Options

    #{NimbleOptions.docs(@start_link_opts)}
  """
  @impl true
  @spec start_link(Keyword.t()) :: {:ok, pid()} | :ignore | {:error, Mserror.LimiterError.t()}
  def start_link(opts) do
    api_telemetry :service, %{service_name: opts[:service_name]} do
      validated_opts = NimbleOptions.validate!(opts, @start_link_opts)

      genserver_opts =
        [name: validated_opts[:service_name]] ++
          Keyword.take(validated_opts, [:debug, :timeout, :hibernate_after])

      init_opts = Keyword.take(validated_opts, [:algorithms, :cleanup_interval])

      case GenServer.start_link(Runtime.Service, init_opts, genserver_opts) do
        {:ok, pid} ->
          {:ok, pid}

        {:error, reason} ->
          {:error,
           Mserror.LimiterError.new(:service_management, "Failed to start rate limiting services",
             cause: reason,
             context: %ErrorContext{
               origin: {__MODULE__, :start_link, 1},
               parameters: %{opts: validated_opts}
             }
           )}

        :ignore ->
          :ignore
      end
    end
  end

  ##############################################################################
  #
  # put_service
  #
  #

  @doc section: :service_management
  @doc """
  Establishes a specific running instance of the Rate Limiting Service as the
  current service for the running process which invoked this function.

  ## Parameters

    * `service_name` - the name under which the Rate Limiting Service is
      started and by which it may be referenced.  This is any name that may be
      used to reference a GenServer process.  Additionally, this value may be
      set `nil` to clear the currently set Rate Limiting Service name.

  ## Returns

  Returns the name of the previously set Rate Limiting Service name or `nil` if
  no Rate Limiting Service name had been previously set.

  ## Examples

    Setting a specific Rate Limiting Service name:

      iex> MscmpSystLimiter.put_service(:"MscmpSystLimiter.TestSupportService")
      ...> MscmpSystLimiter.get_service()
      :"MscmpSystLimiter.TestSupportService"

    Clearing a previously set specific Service Name:

      iex> MscmpSystLimiter.put_service(nil)
      ...> MscmpSystLimiter.get_service()
      nil
  """
  @impl true
  @spec put_service(ServiceTypes.service_name()) :: ServiceTypes.service_name()
  defdelegate put_service(service_name), to: Runtime.ProcessUtils

  ##############################################################################
  #
  # get_service
  #
  #

  @doc section: :service_management
  @doc """
  Retrieves the name of the currently set Rate Limiting Service instance.

  See `put_service/1` for more information about setting an active Rate Limiting
  Service name.

  ## Returns

  Returns the name of the currently set Rate Limiting Service name or `nil` if
  no Rate Limiting Service name has been set.

  ## Examples

    Retrieving a specific Rate Limiting Service name:

      iex> MscmpSystLimiter.put_service(:"MscmpSystLimiter.TestSupportService")
      ...> MscmpSystLimiter.get_service()
      :"MscmpSystLimiter.TestSupportService"

    Retrieving a specific Rate Limiting Service name when no value is currently
    set for the process:

      iex> MscmpSystLimiter.put_service(nil)
      ...> MscmpSystLimiter.get_service()
      nil
  """
  @impl true
  @spec get_service() :: ServiceTypes.service_name()
  defdelegate get_service, to: Runtime.ProcessUtils

  ##############################################################################
  #
  # get_runtime_config
  #
  #

  @doc section: :service_management
  @doc """
  Retrieves the runtime configuration of a previously started Rate Limiting Service.

  Some services need a mechanism to return features such as `:ets` table names
  which are set at runtime.  This function provides the mechanism by which such
  runtime configuration can be returned.

  ## Returns

  Returns a map containing the runtime configuration of the currently active
  Rate Limiting Service, or `nil` if no service is currently set.

  ## Examples

    Getting runtime configuration from the current service:

      iex> old_service = MscmpSystLimiter.put_service(TestSupport.get_limiter_service_name())
      iex> config = MscmpSystLimiter.get_runtime_config()
      iex> %{semaphore: {table_id, _}} = config
      iex> is_reference(table_id)
      true
      iex> MscmpSystLimiter.put_service(old_service)
      iex> :ok
      :ok
  """
  @impl true
  @spec get_runtime_config() :: map() | nil
  defdelegate get_runtime_config, to: Runtime.ProcessUtils

  ##############################################################################
  #
  # new
  #
  #

  @new_token_bucket_opts NimbleOptions.new!(
                           bucket_size: [
                             type: :pos_integer,
                             required: true,
                             type_doc: "`t:pos_integer/0`",
                             type_spec: quote(do: pos_integer()),
                             doc: """
                             The maximum number of tokens the bucket can hold at any one time.

                             This represents the burst capacity of the limiter. When the bucket is full,
                             no additional tokens can be added until some are consumed.
                             """
                           ],
                           refill_rate: [
                             type: :pos_integer,
                             required: true,
                             type_doc: "`t:pos_integer/0`",
                             type_spec: quote(do: pos_integer()),
                             doc: """
                             The number of tokens added to the bucket during each refill interval.

                             This determines how quickly the bucket refills after tokens are consumed.
                             Higher values allow for faster recovery from burst consumption.
                             """
                           ],
                           refill_per: [
                             type: {:in, [:day, :hour, :minute, :second, :millisecond]},
                             required: true,
                             type_doc: "`t:MscmpSystLimiter.Types.time_scale/0`",
                             type_spec: quote(do: MscmpSystLimiter.Types.time_scale()),
                             doc: """
                             The time scale of the refill interval.

                             This value determines the time period over which the refill rate is
                             achieved or more simply: `refill_rate` per `refill_per`.
                             """
                           ]
                         )

  @new_semaphore_opts NimbleOptions.new!(
                        max_permits: [
                          type: :pos_integer,
                          required: true,
                          type_doc: "`t:pos_integer/0`",
                          type_spec: quote(do: pos_integer()),
                          doc: """
                          The maximum capacity of the semaphore.

                          This represents the total number of permits/resources available.
                          Positive increments consume permits, negative increments release them.
                          The semaphore starts with full capacity and requires explicit management.
                          """
                        ],
                        time_to_live: [
                          type: :pos_integer,
                          required: true,
                          type_doc: "`t:pos_integer/0`",
                          type_spec: quote(do: pos_integer()),
                          doc: """
                          The amount of time for which a semaphore limiter should be enforced.

                          In units of `time_scale`.  The limiter will be maintained from limiter
                          creation time to that time plus the time to live; this is the expiry
                          time.  After the expiry time expires the limiter will be considered
                          "purge-eligible" and will be dropped from the system.  Any `use/2` calls
                          made against an expired limiter cause the limiter to behave as though it
                          were newly created with maximum permits available.
                          """
                        ],
                        time_scale: [
                          type: {:in, [:day, :hour, :minute, :second, :millisecond]},
                          required: true,
                          type_doc: "`t:MscmpSystLimiter.Types.time_scale/0`",
                          type_spec: quote(do: MscmpSystLimiter.Types.time_scale()),
                          doc: """
                          Establishes the time unit in which the `time_to_live` is expressed.
                          """
                        ]
                      )

  @doc section: :limiter_support
  @doc """
  Creates a new rate limiter instance for the specified algorithm.

  This function creates a new limiter instance that can be used with the rate
  limiting operations (`use/2`, `get/1`, `set/2`, `reset/1`). The limiter is
  identified by a combination of component, type, and ID, allowing for
  hierarchical organization of limiters across different parts of an application.

  ## Parameters

    * `algorithm` - The rate limiting algorithm to use. Must be either
      `:token_bucket` or `:semaphore`.

    * `component` - A module name that represents the component or subsystem
      creating this limiter. This provides namespace organization and helps
      with debugging and monitoring.

    * `type` - An atom that categorizes the type of operation being limited.
      Examples might include `:api_calls`, `:database_connections`, `:file_uploads`, etc.

    * `id` - A string that uniquely identifies this specific limiter within
      the component/type namespace. This allows for per-user, per-resource,
      or other granular limiting.

    * `opts` - Algorithm-specific configuration options (see Options section below).

  ## Returns

  Returns `{:ok, limiter_instance}` on success or `{:error, error}` on failure.

  The `limiter_instance` is an opaque data structure that contains all the
  information needed to interact with the specific limiter. This instance
  should be passed to other limiter functions like `use/2`, `get/1`, etc.

  ## Options

  Each algorithm requires specific options to configure the limiter behavior:

  ### Semaphore Options:

    #{NimbleOptions.docs(@new_semaphore_opts)}

  ### Token Bucket Options:

    #{NimbleOptions.docs(@new_token_bucket_opts)}

  ## Examples

  ### Creating a Token Bucket Limiter

      iex> # First ensure we have a service available for testing
      iex> old_service = MscmpSystLimiter.put_service(TestSupport.get_limiter_service_name())
      iex>
      iex> # Create a token bucket for API rate limiting
      iex> {:ok, limiter} = MscmpSystLimiter.new(
      ...>   :token_bucket,
      ...>   MyApp.API,
      ...>   :requests,
      ...>   "user:123",
      ...>   bucket_size: 100,
      ...>   refill_rate: 10,
      ...>   refill_per: :second
      ...> )
      iex>
      iex> # Verify the limiter was created by checking its initial state
      iex> {:ok, {:allow, capacity, _}} = MscmpSystLimiter.get(limiter)
      iex> capacity
      100
      iex>
      iex> # Restore previous service
      iex> MscmpSystLimiter.put_service(old_service)
      iex> :ok
      :ok

  ### Creating a Semaphore Limiter

      iex> # First ensure we have a service available for testing
      iex> old_service = MscmpSystLimiter.put_service(TestSupport.get_limiter_service_name())
      iex>
      iex> # Create a semaphore for connection pool limiting
      iex> {:ok, limiter} = MscmpSystLimiter.new(
      ...>   :semaphore,
      ...>   MyApp.Database,
      ...>   :connections,
      ...>   "primary_pool",
      ...>   max_permits: 20,
      ...>   time_to_live: 5,
      ...>   time_scale: :minute
      ...> )
      iex>
      iex> # Verify the limiter was created with full permits
      iex> {:ok, {:allow, permits, _}} = MscmpSystLimiter.get(limiter)
      iex> permits
      20
      iex>
      iex> # Restore previous service
      iex> MscmpSystLimiter.put_service(old_service)
      iex> :ok
      :ok

  ## Limiter Identity

  Limiters are uniquely identified by the tuple `{component, type, id}`. Creating
  a new limiter with the same identity will either:

    * Return the existing limiter if it's still active and valid
    * Replace an expired or invalid limiter with a fresh instance

  This allows for idempotent limiter creation and automatic recovery from
  expired state.

  ## Error Conditions

  The function returns `{:error, error}` in the following cases:

    * Invalid algorithm name
    * Invalid component (must be an atom suitable for module names)
    * Invalid type (must be an atom)
    * Invalid ID (must be a binary string)
    * Invalid or missing required options for the chosen algorithm
    * Internal storage or system errors
  """

  @spec new(
          algorithm :: Types.algorithm(),
          component :: module(),
          type :: Types.counter_type(),
          id :: Types.counter_id(),
          opts :: Keyword.t()
        ) :: {:ok, Types.limiter_instance()} | {:error, Mserror.LimiterError.t()}
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def new(algorithm, component, type, id, opts)
      when algorithm in [:semaphore, :token_bucket] and
             is_reg_atom(component) and is_reg_atom(type) and
             is_binary(id) do
    api_telemetry :limiter, %{
      algorithm: algorithm,
      component: component,
      type: type,
      id: id
    } do
      validated_opts =
        case algorithm do
          :semaphore -> NimbleOptions.validate!(opts, @new_semaphore_opts)
          :token_bucket -> NimbleOptions.validate!(opts, @new_token_bucket_opts)
        end

      new_module =
        case algorithm do
          :semaphore -> Impl.Semaphore
          :token_bucket -> Impl.TokenBucket
        end

      case new_module.new(component, type, id, validated_opts) do
        {:ok, limiter_instance} ->
          {:ok, limiter_instance}

        {:error, _} = error ->
          {:error,
           Mserror.LimiterError.new(
             :limiter_management,
             "Error establishing new #{algorithm} limiter instance.",
             parse_error: error,
             context: %ErrorContext{
               origin: {__MODULE__, :new, 5},
               parameters: %{
                 algorithm: algorithm,
                 component: component,
                 type: type,
                 id: id,
                 opts: validated_opts
               }
             }
           )}
      end
    end
  end

  ##############################################################################
  #
  # use
  #
  #

  @doc section: :limiter_support
  @doc """
  Attempts to consume or release capacity from a rate limiter instance.

  This function is the primary mechanism for interacting with active rate limiters.
  It attempts to consume (positive increment) or release (negative increment) the
  specified amount of capacity from the limiter and returns whether the operation
  was allowed or denied.

  ## Parameters

    * `limiter_instance` - A limiter instance created with `new/5`. The instance
      contains all the information needed to identify the specific limiter and
      its configuration.

    * `increment` - An integer representing the amount of capacity to consume
      (positive values) or release (negative values). The behavior depends on
      the algorithm:

      * **Token Bucket**: Must be positive. Represents the number of tokens to
        consume from the bucket.

      * **Semaphore**: Can be positive (acquire permits), negative (release
        permits), or zero (no-op). Positive values consume permits, negative
        values release permits back to the pool.

  ## Returns

  Returns `{:ok, limiter_result}` on success or `{:error, error}` on failure.

  The `limiter_result` is a tuple with one of the following forms:

    * `{:allow, remaining_capacity, updated_limiter_instance}` - The operation
      was allowed. `remaining_capacity` indicates how much capacity remains
      available after this operation.

    * `{:deny, retry_condition, updated_limiter_instance}` - The operation was
      denied due to insufficient capacity. `retry_condition` provides
      algorithm-specific guidance:

      * **Token Bucket**: Number of milliseconds to wait before enough tokens
        are refilled to potentially allow the request.

      * **Semaphore**: Number of additional permits that would need to be
        released before this request could be satisfied.

  ## Algorithm-Specific Behavior

  ### Token Bucket

  Consumes tokens from a bucket that refills at a steady rate. Only positive
  increments are allowed.

    * **Allow**: When sufficient tokens are available, they are consumed and
      the remaining token count is returned.

    * **Deny**: When insufficient tokens are available, returns the number of
      milliseconds to wait for enough tokens to be refilled.

  ### Semaphore

  Manages a fixed pool of permits that can be acquired and released explicitly.

    * **Positive increment**: Attempts to acquire the specified number of permits.
      Fails if insufficient permits are available.

    * **Negative increment**: Releases permits back to the pool. Cannot exceed
      the maximum permit capacity.

    * **Zero increment**: No-op that returns current state without changes.

  ## Examples

  ### Token Bucket Usage

      iex> # First ensure we have a service available for testing
      iex> old_service = MscmpSystLimiter.put_service(TestSupport.get_limiter_service_name())
      iex>
      iex> # Create a token bucket limiter (10 tokens, refill 5 per second)
      iex> {:ok, limiter} = MscmpSystLimiter.new(
      ...>   :token_bucket,
      ...>   MscmpSystLimiter.Doctest,
      ...>   :api_calls,
      ...>   "user_doctest_token_bucket",
      ...>   bucket_size: 10,
      ...>   refill_rate: 5,
      ...>   refill_per: :second
      ...> )
      iex>
      iex> # Consume 3 tokens - allowed
      iex> {:ok, {:allow, remaining, updated_limiter}} = MscmpSystLimiter.use(limiter, 3)
      iex> remaining
      7
      iex>
      iex> # Try to consume 10 tokens when only 7 remain - denied
      iex> {:ok, {:deny, retry_after_ms, _limiter}} = MscmpSystLimiter.use(updated_limiter, 10)
      iex> is_integer(retry_after_ms) and retry_after_ms > 0
      true
      iex>
      iex> # Restore previous service
      iex> MscmpSystLimiter.put_service(old_service)
      iex> :ok
      :ok

  ### Semaphore Usage

      iex> # First ensure we have a service available for testing
      iex> old_service = MscmpSystLimiter.put_service(TestSupport.get_limiter_service_name())
      iex>
      iex> # Create a semaphore limiter (5 permits, 1 hour TTL)
      iex> {:ok, limiter} = MscmpSystLimiter.new(
      ...>   :semaphore,
      ...>   MscmpSystLimiter.Doctest,
      ...>   :database_connections,
      ...>   "pool_doctest_semaphore",
      ...>   max_permits: 5,
      ...>   time_to_live: 1,
      ...>   time_scale: :hour
      ...> )
      iex>
      iex> # Acquire 2 permits - allowed
      iex> {:ok, {:allow, remaining, updated_limiter}} = MscmpSystLimiter.use(limiter, 2)
      iex> remaining
      3
      iex>
      iex> # Try to acquire 5 permits when only 3 remain - denied
      iex> {:ok, {:deny, needed_permits, _limiter}} = MscmpSystLimiter.use(updated_limiter, 5)
      iex> needed_permits
      2
      iex>
      iex> # Release 1 permit back to the pool
      iex> {:ok, {:allow, final_remaining, _final_limiter}} = MscmpSystLimiter.use(updated_limiter, -1)
      iex> final_remaining
      4
      iex>
      iex> # Restore previous service
      iex> MscmpSystLimiter.put_service(old_service)
      iex> :ok
      :ok

  ## Error Conditions

  The function returns `{:error, error}` in the following cases:

    * Invalid limiter instance format
    * Internal algorithm errors (storage issues, etc.)
    * For token bucket: non-positive increment values

  ## Thread Safety

  This function is thread-safe and can be called concurrently from multiple
  processes against the same limiter instance. The underlying storage mechanisms
  provide atomic operations to ensure consistent state.

  ## Performance Notes

  This function performs atomic operations against shared storage (ETS tables
  with `:atomics` references). Performance is optimized for high-concurrency
  scenarios, but consider the frequency of calls when designing rate limiting
  strategies.
  """
  @spec use(limiter_instance :: Types.limiter_instance(), increment :: integer()) ::
          {:ok, Types.limiter_result()} | {:error, Mserror.LimiterError.t()}
  def use(limiter_instance, increment) do
    {algorithm, component_type_id, _} = limiter_instance

    api_telemetry :limiter, %{
      algorithm: algorithm,
      limiter_key: component_type_id,
      increment: increment
    } do
      use_module =
        case limiter_instance do
          {:semaphore, _, _} -> Impl.Semaphore
          {:token_bucket, _, _} -> Impl.TokenBucket
        end

      case use_module.use(limiter_instance, increment) do
        {:ok, _} = result ->
          result

        {:error, _} = error ->
          {:error,
           Mserror.LimiterError.new(
             :limiter_management,
             "Error trying to consume possibly available limiter availability.",
             parse_error: error,
             context: %ErrorContext{
               origin: {__MODULE__, :use, 2},
               parameters: %{
                 limiter_instance: limiter_instance,
                 increment: increment
               }
             }
           )}
      end
    end
  end

  ##############################################################################
  #
  # get
  #
  #

  @doc section: :limiter_support
  @doc """
  Retrieves the current state of a rate limiter instance without modifying it.

  This function allows you to inspect the current capacity and state of a limiter
  without consuming or releasing any resources. It's useful for monitoring,
  logging, or making decisions based on current availability.

  ## Parameters

    * `limiter_instance` - A limiter instance created with `new/5`. The instance
      contains all the information needed to identify the specific limiter and
      its configuration.

  ## Returns

  Returns `{:ok, limiter_result}` on success or `{:error, error}` on failure.

  The `limiter_result` is a tuple with the following form:

    * `{:allow, current_capacity, limiter_instance}` - Returns the current
      available capacity without modifying the limiter state. The
      `current_capacity` value represents:

      * **Token Bucket**: The number of tokens currently available in the bucket.

      * **Semaphore**: The number of permits currently available for acquisition.

  ## Algorithm-Specific Behavior

  ### Token Bucket

  Returns the current number of tokens in the bucket, taking into account any
  refills that have occurred since the last operation. The bucket is refilled
  up to its maximum capacity based on the configured refill rate and time elapsed.

  ### Semaphore

  Returns the current number of available permits. If the semaphore has expired
  (past its time-to-live), it behaves as if newly created with maximum permits
  available.

  ## Examples

  ### Token Bucket State Check

      iex> # First ensure we have a service available for testing
      iex> old_service = MscmpSystLimiter.put_service(TestSupport.get_limiter_service_name())
      iex>
      iex> # Create a token bucket limiter (10 tokens, refill 5 per second)
      iex> {:ok, limiter} = MscmpSystLimiter.new(
      ...>   :token_bucket,
      ...>   MscmpSystLimiter.Doctest,
      ...>   :api_calls,
      ...>   "user_doctest_get_token_bucket",
      ...>   bucket_size: 10,
      ...>   refill_rate: 5,
      ...>   refill_per: :second
      ...> )
      iex>
      iex> # Check initial state - should have full bucket
      iex> {:ok, {:allow, capacity, _limiter}} = MscmpSystLimiter.get(limiter)
      iex> capacity
      10
      iex>
      iex> # Consume some tokens
      iex> {:ok, {:allow, remaining, updated_limiter}} = MscmpSystLimiter.use(limiter, 3)
      iex> remaining
      7
      iex>
      iex> # Check state after consumption - should show reduced capacity
      iex> {:ok, {:allow, current_capacity, _limiter}} = MscmpSystLimiter.get(updated_limiter)
      iex> current_capacity
      7
      iex>
      iex> # Restore previous service
      iex> MscmpSystLimiter.put_service(old_service)
      iex> :ok
      :ok

  ### Semaphore State Check

      iex> # First ensure we have a service available for testing
      iex> old_service = MscmpSystLimiter.put_service(TestSupport.get_limiter_service_name())
      iex>
      iex> # Create a semaphore limiter (5 permits, 1 hour TTL)
      iex> {:ok, limiter} = MscmpSystLimiter.new(
      ...>   :semaphore,
      ...>   MscmpSystLimiter.Doctest,
      ...>   :database_connections,
      ...>   "pool_doctest_get_semaphore",
      ...>   max_permits: 5,
      ...>   time_to_live: 1,
      ...>   time_scale: :hour
      ...> )
      iex>
      iex> # Check initial state - should have full permits
      iex> {:ok, {:allow, capacity, _limiter}} = MscmpSystLimiter.get(limiter)
      iex> capacity
      5
      iex>
      iex> # Acquire some permits
      iex> {:ok, {:allow, remaining, updated_limiter}} = MscmpSystLimiter.use(limiter, 2)
      iex> remaining
      3
      iex>
      iex> # Check state after acquisition - should show reduced permits
      iex> {:ok, {:allow, current_permits, _limiter}} = MscmpSystLimiter.get(updated_limiter)
      iex> current_permits
      3
      iex>
      iex> # Restore previous service
      iex> MscmpSystLimiter.put_service(old_service)
      iex> :ok
      :ok

  ## Error Conditions

  The function returns `{:error, error}` in the following cases:

    * Invalid limiter instance format
    * Internal algorithm errors (storage issues, etc.)
  """
  @spec get(limiter_instance :: Types.limiter_instance()) ::
          {:ok, Types.limiter_result()} | {:error, Mserror.LimiterError.t()}
  def get(limiter_instance) do
    {algorithm, component_type_id, _} = limiter_instance

    api_telemetry :limiter, %{
      algorithm: algorithm,
      limiter_key: component_type_id
    } do
      get_module =
        case limiter_instance do
          {:semaphore, _, _} -> Impl.Semaphore
          {:token_bucket, _, _} -> Impl.TokenBucket
        end

      case get_module.get(limiter_instance) do
        {:ok, _} = result ->
          result

        {:error, _} = error ->
          {:error,
           Mserror.LimiterError.new(
             :limiter_management,
             "Error trying retrieve the current limiter state.",
             parse_error: error,
             context: %ErrorContext{
               origin: {__MODULE__, :get, 1},
               parameters: %{
                 limiter_instance: limiter_instance
               }
             }
           )}
      end
    end
  end

  ##############################################################################
  #
  # set
  #
  #

  @set_semaphore_opts NimbleOptions.new!(
                        current_permits: [
                          type: :non_neg_integer,
                          required: true,
                          type_doc: "`t:non_neg_integer/0`",
                          type_spec: quote(do: non_neg_integer()),
                          doc: """
                          The current number of permits available.

                          Overrides the existing number of permits available to value of this
                          option.  Note that the value of this option must be no less than 1 and
                          no more than the `max_permits` value established at limiter creation.
                          """
                        ]
                      )

  @set_token_bucket_opts NimbleOptions.new!(
                           current_fill: [
                             type: :non_neg_integer,
                             required: true,
                             type_doc: "`t:non_neg_integer/0`",
                             type_spec: quote(do: non_neg_integer()),
                             doc: """
                             The current fill of the bucket.

                             Allows the caller to override the number of tokens currently filling
                             the bucket.  This value must be 1 or greater and less than or equal
                             to the `bucket_size` value set on limiter creation.
                             """
                           ]
                         )

  @doc section: :limiter_support
  @doc """
  Explicitly sets the current available capacity of a rate limiter instance.

  This function allows you to override the current state of a limiter with a
  specific capacity value. This is useful for administrative operations,
  testing scenarios, or implementing custom policies that need to adjust
  limiter capacity based on external conditions.

  ## Parameters

    * `limiter_instance` - A limiter instance created with `new/5`. The instance
      contains all the information needed to identify the specific limiter and
      its configuration.

    * `opts` - Algorithm-specific options that define the new capacity state
      (see Options section below).

  ## Returns

  Returns `{:ok, limiter_result}` on success or `{:error, error}` on failure.

  The `limiter_result` is a tuple with the following form:

    * `{:allow, set_capacity, limiter_instance}` - The limiter capacity has been
      set to the specified value. The `set_capacity` reflects the new current
      capacity:

      * **Token Bucket**: The number of tokens now available in the bucket.

      * **Semaphore**: The number of permits now available for acquisition.

  ## Options

  Each algorithm requires specific options to set the capacity:

  ### Semaphore Options:

    #{NimbleOptions.docs(@set_semaphore_opts)}

  ### Token Bucket Options:

    #{NimbleOptions.docs(@set_token_bucket_opts)}

  ## Algorithm-Specific Behavior

  ### Token Bucket

  Sets the bucket's current token count to the specified value and updates the
  last refill timestamp to the current time. The new token count must be within
  the bucket's configured capacity (0 to `bucket_size`).

  ### Semaphore

  Sets the semaphore's current permit count to the specified value. The new
  permit count must be within the semaphore's configured capacity (0 to
  `max_permits`). The expiry time is not modified.

  ## Examples

  ### Setting Token Bucket Capacity

      iex> # First ensure we have a service available for testing
      iex> old_service = MscmpSystLimiter.put_service(TestSupport.get_limiter_service_name())
      iex>
      iex> # Create a token bucket limiter
      iex> {:ok, limiter} = MscmpSystLimiter.new(
      ...>   :token_bucket,
      ...>   MscmpSystLimiter.Doctest,
      ...>   :api_calls,
      ...>   "user_doctest_set_bucket",
      ...>   bucket_size: 10,
      ...>   refill_rate: 5,
      ...>   refill_per: :second
      ...> )
      iex>
      iex> # Consume some tokens
      iex> {:ok, {:allow, remaining, depleted_limiter}} = MscmpSystLimiter.use(limiter, 7)
      iex> remaining
      3
      iex>
      iex> # Explicitly set the bucket to half capacity
      iex> {:ok, {:allow, set_capacity, set_limiter}} = MscmpSystLimiter.set(depleted_limiter, current_fill: 5)
      iex> set_capacity
      5
      iex>
      iex> # Verify the new capacity is in effect
      iex> {:ok, {:allow, current_capacity, _}} = MscmpSystLimiter.get(set_limiter)
      iex> current_capacity
      5
      iex>
      iex> # Restore previous service
      iex> MscmpSystLimiter.put_service(old_service)
      iex> :ok
      :ok

  ### Setting Semaphore Permits

      iex> # First ensure we have a service available for testing
      iex> old_service = MscmpSystLimiter.put_service(TestSupport.get_limiter_service_name())
      iex>
      iex> # Create a semaphore limiter
      iex> {:ok, limiter} = MscmpSystLimiter.new(
      ...>   :semaphore,
      ...>   MscmpSystLimiter.Doctest,
      ...>   :database_connections,
      ...>   "pool_doctest_set_semaphore",
      ...>   max_permits: 10,
      ...>   time_to_live: 1,
      ...>   time_scale: :hour
      ...> )
      iex>
      iex> # Acquire some permits
      iex> {:ok, {:allow, remaining, depleted_limiter}} = MscmpSystLimiter.use(limiter, 6)
      iex> remaining
      4
      iex>
      iex> # Explicitly set permits to a specific value
      iex> {:ok, {:allow, set_permits, set_limiter}} = MscmpSystLimiter.set(depleted_limiter, current_permits: 8)
      iex> set_permits
      8
      iex>
      iex> # Verify the new permit count is in effect
      iex> {:ok, {:allow, current_permits, _}} = MscmpSystLimiter.get(set_limiter)
      iex> current_permits
      8
      iex>
      iex> # Restore previous service
      iex> MscmpSystLimiter.put_service(old_service)
      iex> :ok
      :ok

  ## Error Conditions

  The function returns `{:error, error}` in the following cases:

    * Invalid limiter instance format
    * Capacity value outside valid range (e.g., negative values or exceeding
      maximum configured capacity)
    * Internal algorithm errors (storage issues, etc.)
  """
  @spec set(limiter_instance :: Types.limiter_instance(), opts :: Keyword.t()) ::
          {:ok, Types.limiter_result()} | {:error, Mserror.LimiterError.t()}
  def set(limiter_instance, opts) do
    {algorithm, component_type_id, _} = limiter_instance

    api_telemetry :limiter, %{
      algorithm: algorithm,
      limiter_key: component_type_id,
      opts_keys: Keyword.keys(opts)
    } do
      validated_opts =
        case limiter_instance do
          {:semaphore, _, _} -> NimbleOptions.validate!(opts, @set_semaphore_opts)
          {:token_bucket, _, _} -> NimbleOptions.validate!(opts, @set_token_bucket_opts)
        end

      set_module =
        case limiter_instance do
          {:semaphore, _, _} -> Impl.Semaphore
          {:token_bucket, _, _} -> Impl.TokenBucket
        end

      case set_module.set(limiter_instance, validated_opts) do
        {:ok, limiter_result} ->
          {:ok, limiter_result}

        {:error, _} = error ->
          {:error,
           Mserror.LimiterError.new(
             :limiter_management,
             "Error setting limiter available capacity to explicit value.",
             parse_error: error,
             context: %ErrorContext{
               origin: {__MODULE__, :set, 2},
               parameters: %{
                 limiter_instance: limiter_instance,
                 opts: validated_opts
               }
             }
           )}
      end
    end
  end

  ##############################################################################
  #
  # reset
  #
  #

  @doc section: :limiter_support
  @doc """
  Resets a rate limiter instance to its initial state.

  This function restores a limiter to its original configuration state, as if it
  were newly created. This is useful for clearing accumulated state, resetting
  counters after maintenance windows, or handling error recovery scenarios.

  ## Parameters

    * `limiter_instance` - A limiter instance created with `new/5`. The instance
      contains all the information needed to identify the specific limiter and
      its configuration.

  ## Returns

  Returns `{:ok, limiter_result}` on success or `{:error, error}` on failure.

  The `limiter_result` is a tuple with the following form:

    * `{:allow, initial_capacity, limiter_instance}` - The limiter has been
      reset to its initial state. The `initial_capacity` value represents:

      * **Token Bucket**: The bucket is filled to its maximum `bucket_size`
        capacity with all tokens available.

      * **Semaphore**: All permits are available, equal to the `max_permits`
        value configured at creation time.

  ## Algorithm-Specific Behavior

  ### Token Bucket

  Resets the bucket to its maximum capacity (`bucket_size`) and updates the
  last refill timestamp to the current time. This effectively gives the limiter
  a fresh start with all tokens immediately available.

  ### Semaphore

  Resets the semaphore to have all permits available (`max_permits`) and
  updates the expiry time based on the current time plus the configured
  `time_to_live`. This extends the limiter's lifetime and makes all permits
  available for acquisition.

  ## Examples

  ### Token Bucket Reset

      iex> # First ensure we have a service available for testing
      iex> old_service = MscmpSystLimiter.put_service(TestSupport.get_limiter_service_name())
      iex>
      iex> # Create a token bucket limiter (10 tokens, refill 5 per second)
      iex> {:ok, limiter} = MscmpSystLimiter.new(
      ...>   :token_bucket,
      ...>   MscmpSystLimiter.Doctest,
      ...>   :api_calls,
      ...>   "user_doctest_reset_token_bucket",
      ...>   bucket_size: 10,
      ...>   refill_rate: 5,
      ...>   refill_per: :second
      ...> )
      iex>
      iex> # Consume most tokens
      iex> {:ok, {:allow, remaining, depleted_limiter}} = MscmpSystLimiter.use(limiter, 8)
      iex> remaining
      2
      iex>
      iex> # Reset the limiter - should restore full capacity
      iex> {:ok, {:allow, reset_capacity, reset_limiter}} = MscmpSystLimiter.reset(depleted_limiter)
      iex> reset_capacity
      10
      iex>
      iex> # Verify we can now consume the full amount again
      iex> {:ok, {:allow, final_remaining, _final_limiter}} = MscmpSystLimiter.use(reset_limiter, 8)
      iex> final_remaining
      2
      iex>
      iex> # Restore previous service
      iex> MscmpSystLimiter.put_service(old_service)
      iex> :ok
      :ok

  ### Semaphore Reset

      iex> # First ensure we have a service available for testing
      iex> old_service = MscmpSystLimiter.put_service(TestSupport.get_limiter_service_name())
      iex>
      iex> # Create a semaphore limiter (5 permits, 1 hour TTL)
      iex> {:ok, limiter} = MscmpSystLimiter.new(
      ...>   :semaphore,
      ...>   MscmpSystLimiter.Doctest,
      ...>   :database_connections,
      ...>   "pool_doctest_reset_semaphore",
      ...>   max_permits: 5,
      ...>   time_to_live: 1,
      ...>   time_scale: :hour
      ...> )
      iex>
      iex> # Acquire most permits
      iex> {:ok, {:allow, remaining, depleted_limiter}} = MscmpSystLimiter.use(limiter, 4)
      iex> remaining
      1
      iex>
      iex> # Reset the semaphore - should restore all permits
      iex> {:ok, {:allow, reset_permits, reset_limiter}} = MscmpSystLimiter.reset(depleted_limiter)
      iex> reset_permits
      5
      iex>
      iex> # Verify we can now acquire permits again
      iex> {:ok, {:allow, final_remaining, _final_limiter}} = MscmpSystLimiter.use(reset_limiter, 3)
      iex> final_remaining
      2
      iex>
      iex> # Restore previous service
      iex> MscmpSystLimiter.put_service(old_service)
      iex> :ok
      :ok

  ## Use Cases

  This function is particularly useful in the following scenarios:

    * **Maintenance Windows**: Resetting limiters after scheduled maintenance
      to ensure full capacity is available when services resume.

    * **Error Recovery**: Clearing accumulated state after resolving issues
      that may have caused unusual consumption patterns.

    * **Testing**: Providing a clean slate for test scenarios without needing
      to recreate limiter instances.

    * **Administrative Actions**: Allowing operators to manually reset limiters
      in response to operational requirements.

  ## Error Conditions

  The function returns `{:error, error}` in the following cases:

    * Invalid limiter instance format
    * Internal algorithm errors (storage issues, etc.)
  """
  @spec reset(limiter_instance :: Types.limiter_instance()) ::
          {:ok, Types.limiter_result()} | {:error, Mserror.LimiterError.t()}
  def reset(limiter_instance) do
    {algorithm, component_type_id, _} = limiter_instance

    api_telemetry :limiter, %{
      algorithm: algorithm,
      limiter_key: component_type_id
    } do
      reset_module =
        case limiter_instance do
          {:semaphore, _, _} -> Impl.Semaphore
          {:token_bucket, _, _} -> Impl.TokenBucket
        end

      case reset_module.reset(limiter_instance) do
        {:ok, limiter_result} ->
          {:ok, limiter_result}

        {:error, error} ->
          {:error,
           Mserror.LimiterError.new(
             :limiter_management,
             "Error resetting limiter.",
             parse_error: error,
             context: %ErrorContext{
               origin: {__MODULE__, :reset, 1},
               parameters: %{
                 limiter_instance: limiter_instance
               }
             }
           )}
      end
    end
  end
end
