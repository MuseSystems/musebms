# Source File: mscmp_syst_limiter.ex
# Location:    musebms/components/system/mscmp_syst_limiter/lib/mscmp_syst_limiter.ex
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
  alias MscmpSystLimiter.Impl
  alias MscmpSystLimiter.Runtime
  alias MscmpSystLimiter.Types

  @external_resource "README.md"

  @moduledoc File.read!(Path.join([__DIR__, "..", "README.md"]))

  @doc section: :rate_limiter_data
  @doc """
  Creates a canonical name for each unique counter.

  ## Parameters

    * `counter_type` - an atom representing the kind of counter being created.

    * `counter_id` - a value unique to the `counter_type` which identifies a
    specific counter.

  ## Example

      iex> MscmpSystLimiter.get_counter_name(:example_counter_name, "123")
      "example_counter_name_123"
  """

  @spec get_counter_name(Types.counter_type(), Types.counter_id()) :: Types.counter_name()
  defdelegate get_counter_name(counter_type, counter_id), to: Impl.RateLimiter

  @doc section: :rate_limiter_data
  @doc """
  Returns an anonymous function to simplify calls to check the rate for a
  specific counter type.

  The returned function avoids requiring the parameters that are common between
  calls from being constantly supplied.  The only parameter that the returned
  function requires is the `counter_id` value of the specific counter of the
  type to test; all other parameters typically required by
  `MscmpSystLimiter.check_rate/4` are captured by the returned closure.

  ## Parameters

    * `counter_type` - an atom representing the kind of counter that the
    returned function will be set to check.

    * `scale_ms` - the time in milliseconds of the rate window.  For example,
    for the rate limit of 3 tries in one minute the `scale_ms` value is set to
    60,000 milliseconds for one minute.

    * `limit` - the number of attempts allowed with the `scale_ms` duration.  In
    the example of 3 tries in one minute, the `limit` value is 3.

  ## Example

  Note that The returned anonymous function is equivalent to making a call to
  the more verbose `MscmpSystLimiter.check_rate/4`:

      iex> my_check_rate_function =
      ...>   MscmpSystLimiter.get_check_rate_function(
      ...>     :example_counter_get_func,
      ...>     60_000,
      ...>     3)
      iex> my_check_rate_function.("id1")
      {:allow, 1}
      iex> MscmpSystLimiter.check_rate(
      ...>   :example_counter_get_func,
      ...>   "id1",
      ...>   60_000,
      ...>   3)
      {:allow, 2}
      iex> my_check_rate_function.("id1")
      {:allow, 3}
  """

  @spec get_check_rate_function(Types.counter_type(), integer(), integer()) ::
          (counter_id :: Types.counter_id() ->
             {:allow, count :: integer()}
             | {:deny, limit :: integer()}
             | {:error, MscmpSystError.t()})
  defdelegate get_check_rate_function(counter_type, scale_ms, limit), to: Impl.RateLimiter

  @doc section: :rate_limiter_data
  @doc """
  Checks if a Counter is within it's permissible rate and increments the Counter
  if it is within it's permissible rate.

  ## Parameters

    * `counter_type` - an atom representing the kind of counter for which the
    rate is being checked.

    * `counter_id` - the specific Counter ID of the type.  For example if the
    `counter_type` is `:user_login`, the `counter_id` value may be a value like
    `user@email.domain` for the user's username.

    * `scale_ms` - the time in milliseconds of the rate window.  For example,
    for the rate limit of 3 tries in one minute the `scale_ms` value is set to
    60,000 milliseconds for one minute.

    * `limit` - the number of attempts allowed with the `scale_ms` duration.  In
    the example of 3 tries in one minute, the `limit` value is 3.

  ## Example

      iex> MscmpSystLimiter.check_rate(:check_rate_counter, "id1", 60_000, 3)
      {:allow, 1}
      iex> MscmpSystLimiter.check_rate(:check_rate_counter, "id1", 60_000, 3)
      {:allow, 2}
      iex> MscmpSystLimiter.check_rate(:check_rate_counter, "id1", 60_000, 3)
      {:allow, 3}
      iex> MscmpSystLimiter.check_rate(:check_rate_counter, "id1", 60_000, 3)
      {:deny, 3}

  """

  @spec check_rate(Types.counter_type(), Types.counter_id(), integer(), integer()) ::
          {:allow, count :: integer()}
          | {:deny, limit :: integer()}
          | {:error, MscmpSystError.t()}
  defdelegate check_rate(counter_type, counter_id, scale_ms, limit), to: Impl.RateLimiter

  @doc section: :rate_limiter_data
  @doc """
  Checks the rate same as `MscmpSystLimiter.check_rate/4`, but allows for a
  variable increment to be set for the call.

  ## Parameters

    * `counter_type` - an atom representing the kind of counter for which the
    rate is being checked.

    * `counter_id` - the specific Counter ID of the type.  For example if the
    `counter_type` is `:user_login`, the `counter_id` value may be a value like
    `user@email.domain` for the user's username.

    * `scale_ms` - the time in milliseconds of the rate window.  For example,
    for the rate limit of 3 tries in one minute the `scale_ms` value is set to
    60,000 milliseconds for one minute.

    * `limit` - the number of attempts allowed with the `scale_ms` duration.  In
    the example of 3 tries in one minute, the `limit` value is 3.

  ## Example

      iex> MscmpSystLimiter.check_rate_with_increment(
      ...>   :check_with_increment,
      ...>   "id1",
      ...>   60_000,
      ...>   10,
      ...>   7)
      {:allow, 7}
      iex> MscmpSystLimiter.check_rate_with_increment(
      ...>   :check_with_increment,
      ...>   "id1",
      ...>   60_000,
      ...>   10,
      ...>   2)
      {:allow, 9}
      iex> MscmpSystLimiter.check_rate(:check_with_increment, "id1", 60_000, 10)
      {:allow, 10}
  """

  @spec check_rate_with_increment(
          Types.counter_type(),
          Types.counter_id(),
          integer(),
          integer(),
          integer()
        ) ::
          {:allow, count :: integer()}
          | {:deny, limit :: integer()}
          | {:error, MscmpSystError.t()}
  defdelegate check_rate_with_increment(counter_type, counter_id, scale_ms, limit, increment),
    to: Impl.RateLimiter

  @doc section: :rate_limiter_data
  @doc """
  Retrieves data about a currently used counter without counting towards the limit.

  ## Parameters

    * `counter_type` - an atom representing the kind of counter which to inspect.

    * `counter_id` - the specific Counter ID of the type.  For example if the
    `counter_type` is `:user_login`, the `counter_id` value may be a value like
    `user@email.domain` for the user's username.

    * `scale_ms` - the time in milliseconds of the rate window.  For example,
    for the rate limit of 3 tries in one minute the `scale_ms` value is set to
    60,000 milliseconds for one minute.

    * `limit` - the number of attempts allowed with the `scale_ms` duration.  In
    the example of 3 tries in one minute, the `limit` value is 3.
  """

  @spec inspect_counter(Types.counter_type(), Types.counter_id(), integer(), integer()) ::
          {:ok,
           {
             count :: integer(),
             count_remaining :: integer(),
             ms_to_next_counter :: integer(),
             created_at :: integer() | nil,
             updated_at :: integer() | nil
           }}
          | {:error, MscmpSystError.t()}
  defdelegate inspect_counter(counter_type, counter_id, scale_ms, limit), to: Impl.RateLimiter

  @doc section: :rate_limiter_data
  @doc """
  Deletes a counter from the system.

  ## Parameters

    * `counter_type` - an atom representing the kind of counter which is to be
    deleted.

    * `counter_id` - the specific Counter ID of the type.  For example if the
    `counter_type` is `:user_login`, the `counter_id` value may be a value like
    `user@email.domain` for the user's username.

  ## Example

      iex> MscmpSystLimiter.check_rate(:delete_test_counter, "id1", 60_000, 3)
      {:allow, 1}
      iex> MscmpSystLimiter.delete_counters(:delete_test_counter, "id1")
      {:ok, 1}
  """

  @spec delete_counters(Types.counter_type(), Types.counter_id()) ::
          {:ok, integer()} | {:error, MscmpSystError.t()}
  defdelegate delete_counters(counter_type, counter_id), to: Impl.RateLimiter

  @doc section: :service_management
  @doc """
  Starts the rate limiter services.

  This service should be started after the Mnesia has had its schema created and
  before any call to `init_rate_limiter/1`.

  ## Parameters

    * `opts` - a Keyword List of options which can be used to override default
    values typically used to initialize the service.  The available options are:

      * `supervisor_name` - the name of the supervisor which will manage the
      Rate Limiter services.  The default value is `MscmpSystLimiter.Supervisor`.

      * `expiry_ms` - the life time in milliseconds of any single Counter.  This
      should be longer than the life of the longest bucket that will be created.
      A shorter value could result in an active counter being deleted prior to
      becoming inactive.

      * `cleanup_interval_ms` - the time in milliseconds to wait between sweeps
      of the stale Counter cleaner.  During a sweep any Counter past its expiry
      time (see `expiry_ms`) will be purged from the system.

      * `table_name` - the name of the backend database table to use for
      tracking counters.  Typically this value should be allowed to default
      (`:mscmp_syst_limiter_counters`) unless there's a compelling reason to do
      otherwise.

  """
  @spec start_link(Keyword.t()) :: Supervisor.on_start_child()
  defdelegate start_link(opts \\ []), to: Runtime.Services

  @doc section: :service_management
  @doc """
  Initializes the rate limiter table.

  This function must be called per the instructions of `MscmpSystLimiter`
  prior to the checking the rate of any counter.

  ## Parameters

    * `opts` - a keyword list of optional parameters.  Valid options are:
      * `mnesia_table_args` - a list of options to be passed directly to
      `:mnesia.create_table/2`.  For complete documentation of the
      available Mnesia table options see
      [the Erlang documentation](https://www.erlang.org/doc/man/mnesia.html#create_table-2).
  """

  @spec init_rate_limiter(Keyword.t()) ::
          {:ok, detail :: atom()} | {:error, MscmpSystError.t()}
  defdelegate init_rate_limiter(opts \\ []), to: Runtime.Services
end