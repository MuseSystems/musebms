+++
title = "Development Testing Standards"
linkTitle = "Development Testing Standards"
description = """As development proceeds, the need to test code under a variety
of conditions exists.  This document establishes certain minimum standards for
development related testing.
"""

draft = false

weight = 50
+++

{{< alert title="Temporary Entry" color="warning" >}}
This entry into the Technical Book is temporary until time can be found to move this content to a
more appropriate, permanent home.
{{< /alert >}}

## Testing Concerns

Currently there are two broad testing concerns which mirror the highest level
structure of our application.

### Application Server Testing

This is testing of the Elixir application server code.  While this testing
concern is not meant to be an explicit testing of database code (schema,
constraints, store procedures, etc.) the database code will nonetheless be
exercised by application.

Application server testing current is focused on using the Elixir `ExUnit` test
suit with workflows prescribed in this document to attain our application
development testing goals.

### Database Testing

Database testing is focused on testing the database explicitly outside of the
context of the application related code.

{{< alert title="No Direct Database Testing" color="info" >}}
Currently this testing concern is not being directly addressed and relies on
application code to exercise the database; this is not ideal, but sufficient for
our current needs.
{{< /alert >}}

When direct database testing is incorporated into the test suite, we'll like
base such testing on `PgTap`.

## Testing Types

Each of our testing areas of concern are subject to three kinds of testing.

### Unit Testing

Unit testing targets the intended to confirm the functioning of any
internal/private API functions defined by a Component.  Unit tests have the
following qualities:

  * __Testing Target__

    Internal, private APIs

  * __Ordering__

    Random & asynchronous

  * __Data__

    Expects the database to be sufficiently seeded such that any private API
    function can execute normally without interfering with other, possibly
    concurrently running tests.

    Ideally, the seeded test data is randomly generated, though this is not
    commonly done at present.

### Integration Testing

The focus of Integration Testing is twofold: 1) test that public API functions
are working correctly; and 2) establish that the supported business process can
be operated successfully and completely using the public API.  Traits of
integration testing are:

  * __Testing Target__

    Public APIs & end-to-end business processing adequacy

  * __Ordering__

    Business processed ordered & synchronous

  * __Data__

    Pre-testing database seeding is as minimal as possible with later tests
    relying on data created during earlier tests.

    Ideally, test data is generated randomly though this is not consistently
    done at present.

### Documentation Testing

Documentation Testing, where supported by the test suites, is intended to ensure
that any documented code examples are representations of working code.
The qualities of documentation testing are:

  * __Testing Target__

    Public API documented examples

  * __Ordering__

    Random & asynchronous

  * __Data__

    Expects the database to be sufficiently seeded such that any public API
    function can execute normally without interfering with other, possibly
    concurrently running tests.

    The seeded data must be well defined and correspond directly to the data
    seen in the documented code examples.

## Testing an the Component Model

The [Component Model](/technical/high-level-architecture/#the-musebms-component-model)
establishes a hierarchy of application concerns which influences the
expectations of our testing regime.

### Component Level Testing

Each [Component](/technical/high-level-architecture/#components) is responsible
for defining its own unit, integration, and documentation testing suite.
Passing the complete test suite is a pre-requisite for inclusion in any release
oriented code branch of the larger application.

If a Component has dependencies, it may assume that those dependencies have
defined and passed their own test suites.  If they require data seeding in order
to support testing of the current Component, the typical process should be to
simply load the appropriate testing data from the dependency's test suite as a
prerequisite to loading the current Component's seed data.  This does mean that
across Components some effort for cross-Component compatibility of data seeding
should be considered.

### Subsystem Level Testing

[Subsystems](/technical/high-level-architecture/#subsystems) are mostly
aggregates of Components and their testing will typically reflect this.  While
unit tests and documentation tests will exist for Subsystems, these testing
concerns will not differ from Component level testing; indeed, just as
Components will assume their dependencies are independently tested prior to
being available as a dependency, the dependencies of the Subsystem are similarly
treated.

Integration testing for Subsystems, however, is much more important and
extensive.  The reason for this is that Subsystems must ensure that their
combinations of large numbers of dependencies (Components) must all work well
enough together to form a coherent application.  Therefore, end-to-end business
process testing is key to ensuring application level degrees of
interoperability.  This is the full expression of the business logic of the
application and testing that expression is critical.

Seeding data for Subsystem integration testing is usually restricted to the
data seeded as part of a new system implementation, with no specifically testing
related data being seeded.  All testing data is created using the Public APIs of
the application with the data from earlier tests providing inputs to later
tests.

Unit and documentation test data, insofar as it is required, is typically seeded
from the unit and documentation test seed data from each of the dependencies
prior to the tests being run; naturally if there are Subsystem specific
requirements for seeding test data the Subsystem's test suite can define and
load any additional seed data as needed.

### Platform Level Testing

Testing the [Platform](/technical/high-level-architecture/#platforms) related
code is focused on Integration testing similar to the testing focus of
Subsystems.  The key difference is that the integration focus is less concerned
with testing end-to-end business logic as it is with integration testing of the
system's external "user interfaces"; user interfaces as used here is broadly
interpreted as any interface to external users.  Examples of user interfaces are
"web application", "External, Public API", or any other sanctioned means by
which an external user may interact with the running Elixir applications.

The data sources and seed data concerns of the Subsystem level of testing are
broadly applicable to Platform Level Testing.
