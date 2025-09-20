# MscmpSystLimiter - General Rate Limiting Algorithms

<!-- MDOC !-->

API for establishing rate limits for usage of finite system resources.

Many activities in the system consume available scarce computing resources or
are otherwise rightfully subject to limitations on usage or consumption.  This
Component provides simple rate limiting algorithms to allow other, higher level
Components to implement rate limiting as they might require for their specific
purposes.

## Algorithms

The following algorithms have been implemented in this Component:

* **Token Bucket**

  This algorithm models a bucket which is filled with "usage tokens".  Each
  request consumes a token, and tokens are replenished at a steady rate.  This
  allows for burst traffic while maintaining an overall rate limit.

* **Fixed Window**

  This algorithm divides time into fixed intervals (windows) and tracks the
  number of requests within each window.  Once the limit for a window is
  reached, no more requests are allowed until the next window begins.

* **Sliding Window**

  This algorithm tracks requests over a rolling time period rather than fixed
  intervals.  It provides more accurate rate limiting by continuously
  evaluating requests against a moving time window, avoiding the burst
  behavior that can occur at window boundaries in fixed window algorithms.

* **Semaphore**

  This algorithm controls access to a limited number of resources by
  maintaining a count of available permits.  Each request must acquire a permit
  before proceeding, and releases it when complete, ensuring that no more than
  the maximum number of concurrent operations can occur simultaneously.

## Inspiration for this Component

This Component is inspired by the [ExHammer](https://github.com/ExHammer)
project.  In writing this Component, ExHammer was consistently used as a
reference implementation for how such general rate limiting algorithms might be
implemented in Elixir and therefore any similarities between this library and
ExHammer may be a result of this ExHammer influence.