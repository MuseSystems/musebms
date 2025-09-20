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
             {:list, {:in, [:sliding_window, :fixed_window, :token_bucket]}}
           ]},
        default: :all,
        type_doc: "t:MscmpSystLimiter.Types.start_algorithms/0",
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
          sliding_window: [type: :pos_integer],
          fixed_window: [type: :pos_integer],
          token_bucket: [type: :pos_integer]
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

      iex> MscmpSystLimiter.put_service(MyRateLimiter)
      ...> config = MscmpSystLimiter.get_runtime_config()
      ...> %{sliding_window_table: table_id} = config
      ...> is_reference(table_id)
      true
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
                             type_doc: "t:pos_integer/0",
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
                             type_doc: "t:pos_integer/0",
                             type_spec: quote(do: pos_integer()),
                             doc: """
                             The number of tokens added to the bucket during each refill interval.

                             This determines how quickly the bucket refills after tokens are consumed.
                             Higher values allow for faster recovery from burst consumption.
                             """
                           ],
                           refill_per: [
                             type: {:in, [:day, :hour, :minute, :second]},
                             required: true,
                             type_doc: "t:MscmpSystLimiter.Types.time_scale/0",
                             type_spec: quote(do: MscmpSystLimiter.Types.time_scale()),
                             doc: """
                             The time scale of the refill interval.

                             This value determines the time period over which the refill rate is
                             achieved or more simply: `refill_rate` per `refill_per`.
                             """
                           ]
                         )

  @new_fixed_window_opts NimbleOptions.new!(
                           window_limit: [
                             type: :pos_integer,
                             required: true,
                             type_doc: "t:pos_integer/0",
                             type_spec: quote(do: pos_integer()),
                             doc: """
                             The maximum number of requests allowed within a single time window.

                             This defines the rate limit for the fixed window. Once this limit is
                             reached, no additional requests are allowed until the window resets.
                             """
                           ],
                           window_time_scale: [
                             type: {:in, [:day, :hour, :minute, :second]},
                             required: true,
                             type_doc: "t:MscmpSystLimiter.Types.time_scale/0",
                             type_spec: quote(do: MscmpSystLimiter.Types.time_scale()),
                             doc: """
                             The time scale for the window duration.

                             This determines the granularity of the time window. For example, if set to
                             `:minute`, the window will be measured in minutes. This works in conjunction
                             with the global time_scale setting to determine the actual window duration.
                             """
                           ]
                         )

  @new_sliding_window_opts NimbleOptions.new!(
                             window_limit: [
                               type: :pos_integer,
                               required: true,
                               type_doc: "t:pos_integer/0",
                               type_spec: quote(do: pos_integer()),
                               doc: """
                               The maximum number of requests allowed within the sliding window.

                               This defines the rate limit for the sliding window. The window continuously
                               slides forward in time, providing more accurate rate limiting compared to
                               fixed windows.
                               """
                             ],
                             window_time_scale: [
                               type: {:in, [:day, :hour, :minute, :second]},
                               required: true,
                               type_doc: "t:MscmpSystLimiter.Types.time_scale/0",
                               type_spec: quote(do: MscmpSystLimiter.Types.time_scale()),
                               doc: """
                               The time scale for the sliding window duration.

                               This determines the granularity of the sliding window. For example, if set to
                               `:minute`, the window will slide minute by minute. This works in conjunction
                               with the global time_scale setting to determine the actual window duration.
                               """
                             ]
                           )

  @doc section: :limiter_support
  @doc """
  Starts a rate limiting service.

  ## Parameters
    * `opts` - The options to pass to the rate limiting service.

  ## Options

  Each algorithm requires certain options be set to configure the limiter for
  use.

  #### Token Bucket:

    #{NimbleOptions.docs(@new_token_bucket_opts)}

  #### Fixed Window:

    #{NimbleOptions.docs(@new_fixed_window_opts)}

  #### Sliding Window:

    #{NimbleOptions.docs(@new_sliding_window_opts)}
  """

  @spec new(
          algorithm :: Types.algorithm(),
          component :: module(),
          type :: Types.counter_type(),
          id :: Types.counter_id(),
          opts :: Keyword.t()
        ) :: {:ok, Types.limiter_instance()} | {:error, Mserror.LimiterError.t()}

  def new(:token_bucket, component, type, id, opts)
      when is_reg_atom(component) and is_reg_atom(type) and is_binary(id) do
    validated_opts = NimbleOptions.validate!(opts, @new_token_bucket_opts)

    case Impl.TokenBucket.new(component, type, id, validated_opts) do
      {:ok, limiter_instance} ->
        {:ok, limiter_instance}

      {:error, _} = error ->
        {:error,
         Mserror.LimiterError.new(
           :limiter_management,
           "Error establishing new Token Bucket rate limiter instance.",
           parse_error: error,
           context: %ErrorContext{
             origin: {__MODULE__, :new, 5},
             parameters: %{
               algorithm: :token_bucket,
               component: component,
               type: type,
               id: id,
               opts: validated_opts
             }
           }
         )}
    end
  end

  ##############################################################################
  #
  # use
  #
  #

  @spec use(limiter_instance :: Types.limiter_instance(), increment :: pos_integer()) ::
          {:ok, Types.limiter_result()} | {:error, Mserror.LimiterError.t()}
  def use({:token_bucket, _, _} = limiter_instance, increment) do
    case Impl.TokenBucket.use(limiter_instance, increment) do
      {:ok, _} = result ->
        result

      {:error, _} = error ->
        {:error,
         Mserror.LimiterError.new(
           :limiter_management,
           "Error trying to consume possibly available rate limiter availability.",
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

  ##############################################################################
  #
  # get
  #
  #

  @spec get(limiter_instance :: Types.limiter_instance()) ::
          {:ok, Types.limiter_result()} | {:error, Mserror.LimiterError.t()}
  def get({:token_bucket, _, _} = limiter_instance) do
    case Impl.TokenBucket.get(limiter_instance) do
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

  ##############################################################################
  #
  # set
  #
  #

  @set_token_bucket_opts NimbleOptions.new!(
                           current_fill: [
                             type: :non_neg_integer,
                             required: true,
                             type_doc: "t:non_neg_integer/0",
                             type_spec: quote(do: non_neg_integer()),
                             doc: """
                             The current fill of the bucket.

                             Allows the caller to override the number of tokens
                             currently filling the bucket.
                             """
                           ]
                         )

  @set_fixed_window_opts NimbleOptions.new!(
                           current_count: [
                             type: :non_neg_integer,
                             required: true,
                             type_doc: "t:non_neg_integer/0",
                             type_spec: quote(do: non_neg_integer()),
                             doc: """
                             The current count of the window.

                             Allows the caller to override the number of requests
                             consumed in the current window.
                             """
                           ]
                         )

  @doc """
  Allows for the overriding of the rate limiting configuration for a limiter instance.

  ## Parameters
    * `limiter_instance` - The limiter instance to set the configuration for.
    * `opts` - The options to set the configuration for.

  ## Options

  Each algorithm requires certain options be set to configure the limiter for
  use.

  #### Token Bucket:

    #{NimbleOptions.docs(@set_token_bucket_opts)}

  #### Fixed Window:

    #{NimbleOptions.docs(@set_fixed_window_opts)}

  #### Sliding Window:

    There are currently no settable options for Sliding Window rate limiters
    after creation.
  """
  @spec set(limiter_instance :: Types.limiter_instance(), opts :: Keyword.t()) ::
          {:ok, Types.limiter_result()} | {:error, Mserror.LimiterError.t()}
  def set({:token_bucket, _limiter_id, _limiter_config} = limiter_instance, opts) do
    validated_opts = NimbleOptions.validate!(opts, @set_token_bucket_opts)

    case Impl.TokenBucket.set(limiter_instance, validated_opts) do
      {:ok, limiter_result} ->
        {:ok, limiter_result}

      {:error, _} = error ->
        {:error,
         Mserror.LimiterError.new(
           :limiter_management,
           "Error setting Token Bucket counter to explicit value.",
           parse_error: error,
           context: %ErrorContext{
             origin: {__MODULE__, :set, 2},
             parameters: %{
               algorithm: :token_bucket,
               limiter_instance: limiter_instance,
               opts: validated_opts
             }
           }
         )}
    end
  end

  ##############################################################################
  #
  # reset
  #
  #

  @spec reset(limiter_instance :: Types.limiter_instance()) ::
          {:ok, Types.limiter_result()} | {:error, Mserror.LimiterError.t()}
  def reset({:token_bucket, _limiter_id, _limiter_config} = limiter_instance) do
    case Impl.TokenBucket.reset(limiter_instance) do
      {:ok, limiter_result} ->
        {:ok, limiter_result}

      {:error, error} ->
        {:error,
         Mserror.LimiterError.new(
           :limiter_management,
           "Error resetting Token Bucket counter.",
           parse_error: error,
           context: %ErrorContext{
             origin: {__MODULE__, :set, 2},
             parameters: %{
               algorithm: :token_bucket,
               limiter_instance: limiter_instance
             }
           }
         )}
    end
  end
end
