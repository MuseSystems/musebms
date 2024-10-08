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

  alias MscmpSystLimiter.Impl
  alias MscmpSystLimiter.Types

  ##############################################################################
  #
  # get_counter_name
  #
  #

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

  ##############################################################################
  #
  # get_check_rate_function
  #
  #

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
             | {:error, Mserror.LimiterError.t()})
  defdelegate get_check_rate_function(counter_type, scale_ms, limit), to: Impl.RateLimiter

  ##############################################################################
  #
  # check_rate
  #
  #

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
          | {:error, Mserror.LimiterError.t()}
  def check_rate(counter_type, counter_id, scale_ms, limit) do
    case Impl.RateLimiter.check_rate(counter_type, counter_id, scale_ms, limit) do
      {response, _} = result when response in [:allow, :deny] ->
        result

      {:error, _} = error ->
        {:error,
         Mserror.LimiterError.new(
           :check_counter,
           "Error encountered checking and incrementing the rate limit.",
           cause: error,
           context: %MscmpSystError.Types.Context{
             origin: {__MODULE__, :check_rate, 4},
             parameters: %{
               counter_type: counter_type,
               counter_id: counter_id,
               scale_ms: scale_ms,
               limit: limit
             }
           }
         )}
    end
  end

  ##############################################################################
  #
  # check_rate_with_increment
  #
  #

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
          | {:error, Mserror.LimiterError.t()}
  def check_rate_with_increment(counter_type, counter_id, scale_ms, limit, increment) do
    case Impl.RateLimiter.check_rate_with_increment(
           counter_type,
           counter_id,
           scale_ms,
           limit,
           increment
         ) do
      {response, _} = result when response in [:allow, :deny] ->
        result

      {:error, _} = error ->
        {:error,
         Mserror.LimiterError.new(
           :check_counter,
           "Error encountered checking and incrementing the rate limit with a variable increment.",
           cause: error,
           context: %MscmpSystError.Types.Context{
             origin: {__MODULE__, :check_rate_with_increment, 5},
             parameters: %{
               counter_type: counter_type,
               counter_id: counter_id,
               scale_ms: scale_ms,
               limit: limit,
               increment: increment
             }
           }
         )}
    end
  end

  ##############################################################################
  #
  # inspect_counter
  #
  #

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
          | {:error, Mserror.LimiterError.t()}
  def inspect_counter(counter_type, counter_id, scale_ms, limit) do
    case Impl.RateLimiter.inspect_counter(counter_type, counter_id, scale_ms, limit) do
      {:ok, _} = result ->
        result

      {:error, _} = error ->
        {:error,
         Mserror.LimiterError.new(
           :inspect_counter,
           "Error encountered inspecting the rate limit counter.",
           cause: error,
           context: %MscmpSystError.Types.Context{
             origin: {__MODULE__, :inspect_counter, 4},
             parameters: %{
               counter_type: counter_type,
               counter_id: counter_id,
               scale_ms: scale_ms,
               limit: limit
             }
           }
         )}
    end
  end

  ##############################################################################
  #
  # delete_counters
  #
  #

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
          {:ok, integer()} | {:error, Mserror.LimiterError.t()}
  def delete_counters(counter_type, counter_id) do
    case Impl.RateLimiter.delete_counters(counter_type, counter_id) do
      {:ok, _} = result ->
        result

      {:error, _} = error ->
        {:error,
         Mserror.LimiterError.new(
           :delete_counter,
           "Error encountered deleting the rate limit counter.",
           cause: error,
           context: %MscmpSystError.Types.Context{
             origin: {__MODULE__, :delete_counters, 2},
             parameters: %{counter_type: counter_type, counter_id: counter_id}
           }
         )}
    end
  end
end
