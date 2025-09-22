# Source File: types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_limiter/lib/api/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystLimiter.Types do
  #
  # Note that the ordering of typespecs here is alphabetical.
  #

  @moduledoc """
  Defines public types for use with the MscmpSystLimiter module.
  """

  @typedoc """
  The algorithm to use for the limiter.
  """
  @type algorithm() :: :semaphore | :token_bucket

  @typedoc """
  A unique identifier for a specific counter type within a limiter.

  This identifier distinguishes between different instances of the same counter
  type. For example, if you have a `:login_attempt` counter type, different
  users would have different counter IDs to track their individual login
  attempts separately.
  """
  @type counter_id() :: String.t()

  @typedoc """
  The kind of activity being rate limited.

  For example, a counter type might be `:login_attempt`.
  """
  @type counter_type() :: atom()

  @typedoc """
  The type of value expected for the table which holds the counters.
  """
  @type counter_table_name() :: atom()

  @typedoc """
  Configuration parameters for a rate limiting algorithm.

  This type represents the algorithm-specific configuration needed to define
  how a rate limiter should behave. Each algorithm has its own configuration
  structure that defines the limits, intervals, and other parameters specific
  to that algorithm's implementation.

  > #### Treat constituent configs as opaque {: .warning}
  >
  > While the constituent configuration types are public due to Elixir module
  > boundary limitations, they are not intended for pattern matching. Use the
  > public API to construct and work with them.
  """
  @type limiter_config() :: semaphore_config() | token_bucket_config()

  @typedoc """
  A composite identifier referencing a counter's origin, type, and unique
  identity.

  This acts as the identifier of a specific counter within an assumed algorithm.
  The composite ID provides a methodology for the application to support rate
  limiting across the application while avoiding counter identity conflicts via
  the this structured naming approach.
  """
  @type limiter_id() :: {module(), counter_type(), counter_id()}

  @typedoc """
  A reference to a specific limiter instance.

  A limiter instance represents a complete rate limiting configuration including
  the algorithm to use and the specific limiter to apply it to. For example, a
  user attempting to make API calls to the system will have a limiter instance
  assigned to their session to ensure that their access is within reasonable
  resource consumption limits. The limiter instance is sufficient to know the
  algorithm, the activity being rate limited, and the user/process engaging in
  the activity.
  """
  @type limiter_instance() :: {algorithm(), limiter_id(), limiter_config()}

  @typedoc """
  The name of the limiter.
  """
  @type limiter_name() :: String.t()

  @typedoc """
  The result of a rate limit check or increment operation.

  Returns a tuple indicating whether the action is allowed or denied.

  * `{:allow, remaining_limit, limiter_instance}`: The action is allowed.
    `remaining_limit` is a non-negative integer representing the number of
    remaining allowed actions before hitting the rate limit.

  * `{:deny, retry_condition, limiter_instance}`: The action is denied.
    `retry_condition` is a `non-negative integer representing an algorithm-
    specific condition for retrying the action.  In the case of the semaphore
    algorithm, this is the number of permits which would need to be made
    available prior to retrying the action.  For token bucket, this is the
    number of milliseconds to wait before tokens are added back to the bucket.
  """
  @type limiter_result() ::
          {:allow, non_neg_integer(), limiter_instance()}
          | {:deny, non_neg_integer(), limiter_instance()}

  @typedoc """
  Configuration for the semaphore algorithm.

  > #### Treat as opaque {: .warning}
  >
  > While this type is public due to Elixir module boundary limitations, the
  > concrete representation is an implementation detail and may change without
  > notice. Treat this value as opaque and construct/manage it via the public API.

  Conceptually includes:

    * `max_permits` - the maximum number of resources/permits available
    (positive integer)

    * `time_to_live` - the time to live in units of the time scale (positive
    integer).

    * `time_scale` - the time scale to use for the time to live see
    `MscmpSystLimiter.Types.time_scale/0` for more details.

  Note: Unlike time-based algorithms, semaphore capacity is managed explicitly
  through acquire/release operations rather than automatic time-based refill.
  """
  @type semaphore_config() :: nil | :atomics.atomics_ref()

  @typedoc """
  The algorithms which are to be started.

  This includes all the supported algorithms individually, and the special
  value `:all` which includes all the supported algorithms.
  """
  @type start_algorithms() :: :all | [algorithm()]

  @typedoc """
  The time scale value by which to understand certain time integer values.
  """
  @type time_scale() :: :day | :hour | :minute | :second | :millisecond

  @typedoc """
  Configuration for the token bucket algorithm.

  > #### Treat as opaque {: .warning}
  >
  > While this type is public due to Elixir module boundary limitations, the
  > concrete representation is an implementation detail and may change without
  > notice. Treat this value as opaque and construct/manage it via the public API.

  Conceptually includes:

    * `limit` - the maximum number of tokens in the bucket (positive integer)
    * `interval_ms` - the interval in milliseconds for refilling tokens (positive integer)
    * `refill_rate` - the number of tokens to add per interval (positive integer)
  """
  @type token_bucket_config() :: nil | :atomics.atomics_ref()
end
