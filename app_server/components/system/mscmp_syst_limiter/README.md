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
around the third party [`Hammer`](https://github.com/ExHammer/hammer) library.
`MscmpSystLimiter` offers a slightly different API to the wrapped library and
changes some return values to be more consistent with the Muse Systems Business
Management System standards and practices.  We also reuse and incorporate some
of the documentation from these projects into our own documentation as
appropriate.

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