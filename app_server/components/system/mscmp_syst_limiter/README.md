# MscmpSystLimiter - General Rate Limiting Algorithms

<!-- MDOC !-->

API for establishing rate limits for usage of finite system resources.

Many activities in the system consume available scarce computing resources or
are otherwise rightfully subject to limitations on usage or consumption.  This
Component provides simple rate limiting algorithms to allow other, higher level
Components to implement rate limiting as they might require for their specific
purposes.

## Concepts

This Component is organized around basic conceptual ideas and understanding.

### Limiter Instances

"Limiter Instances" are the objects in this module that represent a utilization
counter and related configurations as assigned to a specific user of that
resource.  A Limiter Instance can be thought of as a singleton, with any
processes representing the same user and rate limited resource all accessing the
same utilization counter; there are some important caveats to the singleton
behavior discussed later in this document.

The process of using `MscmpSystLimiter` follows the basic process of:

1. Obtain a Limiter Instance by calling `MscmpSystLimiter.new/5`.  This function
   will either create new Limiter Instance along with its counter or provide a
   Limiter Instance referencing an existing counter if the same user already is
   being rate limited for the same purpose.

2. Use the Limiter Instance when consuming rate limited resources via such API
   calls as `MscmpSystLimiter.use/2`.

It's worth point out that once a Limiter Instance object is obtained, that
Limiter Instance can contiue to be used perpetually.  The counters which back
the Limiter Instance do have a time-to-live and can expire, but this doesn't
impact the calling functions. For example, trying to use Limiter Instance after
its counter has expired simply leads to the recreation of the counter behind the
scenes, sometimes called "refreshing" or "renewing" the Limiter Instance.

### Algorithms

The following algorithms have been implemented in this Component and can be used
by any one Limiter Instance:

* **Semaphore**

  This algorithm controls access to a limited number of resources by
  maintaining a count of available "Permits".  Each request must acquire a
  Permit from a pool of available Permits before proceeding.  If the request is
  made when there are no Permits remaining in the pool, the request is denied.
  If the pool is limiting a renewable resource, such as a pool of database
  connections, the Permit may be returned to the pool by the requestor once the
  limited resource is no longer needed by the requestor.  Otherwise the pool
  represents an exhaustable resource which only renews when the counter expires.

* **Token Bucket**

  This algorithm models a bucket which is filled with "usage tokens".  Each
  request consumes a token, and tokens are replenished at a steady rate.  This
  allows for burst traffic while maintaining an overall rate limit.

>#### Service Shutdown & Restarts {: .warning}
>
> Limiter Instances, the counters specific to an individual user/resource limit,
> are created and renewed by registiering the user with the `MscmpSystLimiter`
> runtime service.  Once created, Limiter Instances are independent of the
> service until their expiry/time to live values are exceeded.
>
> Shutting down the `MscmpSystLimiter` runtime service therefore does not stop
> existing Limiter Instances from being used, only new Limiter Instances from
> being created and existing Limiter Instances from being renewed.  As such you
> cannot count on the shutting down of the `MscmpSystLimiter` runtime service as
> any sort of indirect off-switch for some other, rate limited service.
>
> Also, when restarting the `MscmpSystLimiter` service, it is conceivable that
> for a short window some "users" of resources might be allowed up to double
> their allowed consumption of rate limited resources.  In this scenario a first
> process obtains a Limiter Instance on behalf of a user prior to restart, and
> then a second process obtains a second Limiter Instance on behalf of the same
> user after restart; the tracking of Limiter Instances is managed by the
> service and a restart effectively causes the service to lose all memory of the
> first Limiter Instance.  For this issue to manifest it is important that the
> first Limiter Instance has not yet reached its exipry/time to live when the
> restart happens.

## Inspiration for this Component

This Component is inspired by the [ExHammer](https://github.com/ExHammer)
project.  In writing this Component, ExHammer was consistently used as a
reference implementation for how such general rate limiting algorithms might be
implemented in Elixir and therefore any similarities between this library and
ExHammer may be a result of this ExHammer influence.