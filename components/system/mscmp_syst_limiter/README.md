# MscmpSystLimiter - Token Bucket Rate Limiting

API for establishing rate limits for usage of finite system resources.

Online, multi-user systems can be unintentionally overwhelmed by aggressive
service calls from external applications and systems or intentionally
exploited by hostile actors seeking to defeat system protections though such
actions as brute forcing user credentials or consuming all available computing
resources of our application.  One approach to mitigating the dangers of
resource exhaustion or persistent illicit information seeking attempts is to
reject excessive calls to system services.

This component limits the rate at which targeted services can be called by
any one caller to a level which preserves the availability of resources to
all users of the system, or makes brute force information gathering
prohibitively time intensive to would be attackers of the system.

## Third Party Functionality

This version of the `MscmpSystLimiter` component is primarily a wrapper
around the third party [`Hammer`](https://github.com/ExHammer/hammer) and
[`Hammer.Backend.Mnesia`](https://github.com/ExHammer/hammer-backend-mnesia)
libraries.  `MscmpSystLimiter` offers a slightly different API to the
wrapped libraries and changes some return values to be more consistent with
the Muse Systems Business Management System standards and practices.  We also
reuse and incorporate some of the documentation from these projects into our
own documentation as appropriate.

## Concepts

MscmpSystLimiter implements a ["Token Bucket"](https://en.wikipedia.org/wiki/Token_bucket)
rate limiting algorithm.  In a Token Bucket rate limit, for each user and
request type a "bucket", called a "Counter" herein, with a finite
number of tokens is created.  As requests are made the Counter is checked to
see if all the tokens are consumed and if not the request is allowed and a
token consumed.  If there are no tokens available at request time, then the
request is denied until the Counter expires.

Over time, expired Counters are periodically deleted by the system.  Both the
expiry time and the cleanup schedule are configurable.

## Setup for Use

Using this component assumes certain setups and configurations are performed
by the client application:

1. __Setup Mnesia__ - MscmpSystLimiter keeps its counters in the Mnesia
database allowing for distribution of the rate limit counters across nodes.
MscmpSystLimiter expects the client application to have setup and called
`:mnesia.create_schema/1` prior to trying to use the provided services.

2. __Initialize the Counter Table__ - Once the Mnesia is configured and
running, the Mnesia table which will hold the counters must be created if it
doesn't already exist.  There are two ways to do this: 1) add a start phase to
the client application `mix.exs` or call a function which creates the Mnesia
table if it doesn't exist.

  * __Add a Start Phase__ - In the `mix.exs` applications specification
  section add a `:post_mnesia_setup` start phase.  Example:

  ```elixir
  def application do
    [
      extra_applications: [:logger, :mnesia]
      start_phases: [{:post_mnesia_setup, [mnesia_table_args: []]}]
    ]
  end
  ```
  note that an optional `mnesia_table_args` value may be set to further
  configure behavior of the mnesia table. `mnesia_table_args` is a
  Keyword List which simply gets passed to `:mnesia.create_table/2` as the
  `Arg` parameter.  see [the Erlang docs](https://www.erlang.org/doc/man/mnesia.html#create_table-2)
  for more.

  * __Call Table Creation Function__ - If adding a `start_phases` definition
  to the application specification is not desirable, the table creation can
  also be completed by explicitly calling
  `MscmpSystLimiter.init_rate_limiter/1` function.
