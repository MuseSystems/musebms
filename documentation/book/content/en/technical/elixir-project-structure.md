+++
title = "Elixir Project Structure"
linkTitle = "Elixir Project Structure"
description = """
Each of the application server code of the various Components, Subsystems, and
Platforms making up the MuseBMS is implemented as independent Elixir projects,
each of which is organized along lines which support our development philosophy.
While our Elixir projects largely conform to the standard patterns used by most
Elixir projects, there are nonetheless departures from convention which are
worthy of discussion.
"""

draft = false

weight = 40
+++
## Central Motivation

As has been said, the directory organization is based on the standard Elixir
project organization as created by running `mix new myapp`.  Our Components are
also started this way and then modified to match our requirements.

{{< alert title="Important Note" color="warning" >}}
The Elixir project organization standard which follows departs from standard
Elixir development practice which doesn't embrace our approach.

If you are new to Elixir development practices you will be better served
becoming familiar with more typical approaches to Elixir project organization
rather than those outlined in this document.
{{< /alert >}}

A core development principle for our Elixir related projects includes the idea
of strictly separating out API definitions from the business logic of the
Component.  It follows that this separation of interface from logic impacts our
project structure.  Within the `lib` directory which typically holds Elixir
source files and possibly other directories, we allow for three directories:

  * __`api`__ -  for Elixir source files defining the public API of the Component

  * __`impl`__ - for Elixir source files implementing business logic concerns of the
    Component.

  * __`runtime`__ - for Elixir source files implementing Component runtime concerns
    such as defining GenServers.

Under our structure, there are no source files directly homed in the `lib`
directory itself.

## Directory Structure and Common Files

Below is an example of a typical MuseBMS Elixir project followed by a detailed
description.  Depending on the specific features and scope of the Component not
all directories or common files displayed below will be present.

```
.
├── README.md
├── config
├── database_utils
│   └── reset_dev_database.psql
├── dev_support
│   └── dev_support.ex
├── lib
│   ├── api
│   │   ├── msdata
│   │   ├── msform
│   │   ├── types
│   │   ├── types.ex
│   │   └── <module_name>.ex
│   ├── impl
│   │   ├── msdata
│   │   └── msform
│   └── runtime
├── mix.exs
├── priv
│   ├── database
│   └── plts
└── test
    ├── support
    └── test_helper.exs
```

## Top Level Entry Descriptions

What follows are the important details regarding each of the organizational
elements at the top level, with additional details as relevant.

### `README.md`

The `README.md` files serves the typical purpose of describing the Component's
purpose and basics about usage.  An important extra role for the `README.md` is
that it is incorporated into the project's technical documentation as the
opening text.

Given this important opening role, the `README.md` file should contain a solid
overview as well as an introduction to the Component at the conceptual and
definitional levels.

### `config`

The `config` directory is the standard Elixir project directory containing
compile time related configurations.  We do not use the config directory or its
files in any non-standard way and actively avoid having our Components depend on
these configuration files.  There are exceptions, such as when third party
libraries require configuration using this method, but even then our usage is
in keeping with Elixir standard practices.

### `database_utils`

This directory contains psql scripts, specifically written for the needs of this
component, which are useful during development and testing.  Only Components
which have a database requirement will have this directory.

  * __`reset_dev_database.psql`__

    This script is run at the end of `mix test` execution to reset the testing
    database back to a clean state.  It is specific to the Component where it
    is defined, though this script will be similar across all components where
    found.

### `dev_support`

The `dev_support` directory contains Elixir code which is use to aid development
activities.  For the most part, this involves building migrations and deploying
them to a development database server. Other dependencies which require services
to be started may also be started via code sourced from this directory.

  * __`dev_support.ex`__

    Typically this is the only file in this directory.  While that's not a hard
    and fast rule that future Components will follow, there are few needs for
    development runtime support and so a single module makes sense.

### `lib`

This is the traditional home of Elixir application source code and this doesn't
change for this project.  As previously discussed, where we depart from
convention is in how the source code inside this directory is organized.

  * __`api`__

    All source files in this directory should be focused on defining and
    documenting the APIs used to interact with the Component.  Business logic
    implementation should not, as a practice, be included in the API defining
    source files.

    Files in `api` will typically consist of `defdelegate` calls, struct
    definitions, and type definitions, all of which should be documented.

    Some of the favored practices just discussed are possible sources of
    performance degradation.  The first choice is to follow the standard
    established here and assume performance penalties are inconsequential.  If
    performance issues arise, then we break ti standard documented here with a
    focus on preserving the API, but moving implementation closer to the API
    defining functions.  We don't expect material performance impacts in all but
    a few edge cases.

    * __*`msdata`*__

      This is special sub-directory containing the definitions of `Ecto.Schema`
      structs which establish database table representations.  In addition there
      will be `defdelegate` references to `Ecto.Changeset` processing functions.
      Components which do not define database schema will not have an
      `api/msdata` directory.

      The structs created in `msdata` are namespaced directly to the `Msdata`
      namespace, so for example a users table may be in a struct module named
      `Msdata.Users`.  Naturally, this means that all Ecto Schemas in `msdata`
      must be uniquely named across all Components in the project.

    * __*`msform`*__

      This is special sub-directory containing the source files which define
      <a href="/documentation/technical/app_server/mscmp_syst_forms" target="_blank">`MscmpSystForms`</a>
      implementing modules.  More information about the organization of the
      `api/msforms` directory can be found in the
      <a href="/documentation/technical/app_server/mscmp_syst_forms/MscmpSystForms.html#module-developing-forms" target="_blank">`MscmpSystForms` Developing Forms</a>
      documentation.

      This directory will only exist for Components implementing
      `MscmpSystForms` based user interfaces.

    * __*`types`*__

      The `types` directory hosts source files which principally define public
      structs which are usable outside of the Component and which aren't defined
      in a more dedicated part of the `api` directory hierarchy (e.g. `msdata`
      database related structs).  Public struct source files will include the
      struct definition and `defdelegate` calls to `impl` or `runtime` hosted
      function implementations.  This directory will not exist if there are no
      module-level type definitions.

    * __*`types.ex`*__

      This source file holds typespecs for simpler types which don't require a
      full module to be created.  Again, these types should be documented and
      considered useful outside of the Component.  Typically this fill will list
      all its defined types in alphabetical order, though other organization is
      acceptable if there are enough defined types to make more topical
      organization useful.

    * __*`<module name>.ex`*__

      A source file containing the Component's principle API definition and
      API documentation.  This file carries the same name as the Elixir project
      and will front the majority of the Component's functionality on offer to
      the outside world.  In a standard Elixir project, a source file with
      roughly the same purpose and name would be found directly in `lib`; we
      simply move that file to `api` and more strictly define its purpose.

  * __`impl`__

    This directory provides a home for the application's business logic
    implementation.  The source files in this directory will contain the vast
    majority of code, though there should be no ExDoc related doc tags in these
    files aside from `@moduledoc false`.  Comments describing feature/function
    intention are allowed and, indeed, welcomed.

    * __*`msdata`*__

      This is the implementation side of previously discussed `api/msdata`
      directory.  If a data struct requires business logic implementation, such
      as the definition of `Ecto.Changeset` processing or protocol
      implementation, a sub-directory will be created here with the same name as
      the corresponding struct in `api/msdata`.  Other, more general changeset
      validation or helper modules which implement data related logic may host
      their source files directly in the root of `impl/msdata`.  Standard names
      for these sorts of files include the following:

      * `impl/msdata/helpers.ex`

        Helper functions which work across multiple structs' logic.

      * `impl/msdata/general_validators.ex`

        Validation and Changeset processing functions which are reusable across
        multiple data defining structs in `api/msdata`.

      * `impl/msdata/<data struct name>/validators.ex`

        Source files hosting Changeset processing functions which are delegated
        to from struct modules defined in `api/msdata`.

      * `impl/msdata/<data struct name>/protocol.ex`

        Source files implementing various protocols for a given struct as
        needed.

    * __*`msform`*__

      This is the implementation oriented compliment to the `api/msform`
      directory.  For more complete documentation on the use of this directory
      please see the
      <a href="/documentation/technical/app_server/mscmp_syst_forms/MscmpSystForms.html#module-developing-forms" target="_blank">`MscmpSystForms` Developing Forms</a>
      documentation.

  * __`runtime`__

    Source files which define and implement runtime services, such as
    GenServers.  This directory will only exist if the Component defines such
    runtime services.  Note that code in `runtime` source files is limited to
    the runtime concerns.  Business logic implementations continue to be hosted
    in the `impl` directory structure and referenced from the runtime service
    as necessary.

### `mix.exs`

This is the typical Elixir `mix.exs` defining project file.  There are some
organizational differences between our approach and the typical generated Elixir
`mix.exs`, but there are no differences that go further than trivial stylist
differences.

### `priv`

This is the standard Elixir `priv` directory, though there are a few special
sub-directories to be aware of.

  * __`priv/database`__

    In [`Component`](/technical/high-level-architecture/#components) level
    Elixir projects, this directory may be visible and hosts database migrations
    built during the testing process.  When tests are not  actually running, the
    directory will exist but will be empty as the testing cleanup processes will
    typically delete this database related testing  artifacts.

    At the [`Subsystem`](/technical/high-level-architecture/#subsystems) level
    the `priv/database` directory will host sub-directories named after their
    corresponding database type name (see the
    [`MscmpSystDb` documentation](/documentation/technical/app_server/mscmp_syst_db/Mix.Tasks.Builddb.html)
    for more about database types).  The database migrations built for the
    database type will be hosted by the appropriate sub-directory.  Note that
    these database migration files are persistent and drive the release as
    opposed to the transient nature of `Component` level migrations.

  * __`priv/plts`__

    This directory hosts generated PLT files for Dialyzer analysis during
    development and the Continuous Integration process.  There is some
    historical precedence for doing handling PLTs and we're just following this
    community convention.

    PLT files should not be part of releases and so this directory should not be
    a factor outside of development and testing processes.

### `test`

This is the standard Elixir project testing directory.  We follow standard
conventions for the most part in regard to testing.  We do define two different
kinds of testing:

  * __*Unit Testing*__

    Unit tests are aimed at testing non-private `impl` and `runtime` related
    code and functions at a granular level.  We are not confirming the public
    API in unit testing, but rather the internal implementations for correct
    results and typing.

  * __*Integration Testing*__

    Integration testing works to test the public API of the Component in a
    fashion which mimics the end-to-end business process as much as possible,
    including the Component's interaction with any dependencies.

These two testing types will not be run together and will typically use
different testing database seed data (if database interactions are part of the
component's functionality.)

Sub-directories and files to the `test` directory include:

  * __*`support`*__

    For testing support related files.  It is typical for this directory to host
    implementations of
    [`ExUnit.CaseTemplate`](https://hexdocs.pm/ex_unit/1.12.3/ExUnit.CaseTemplate.html)
    and logic for building, migrating, and seeding test databases, runtime
    services defined by dependencies and making good on other testing pre-
    conditions.

  * __*`test_helper.exs`*__

    This is the standard Elixir/ExUnit `test_helper.exs` file, typically
    modified to help in supporting testing related database operations and
    post-testing cleanup.
