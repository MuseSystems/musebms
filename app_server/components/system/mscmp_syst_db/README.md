# MscmpSystDb - Database Migrations, Connectivity, and Querying

A database management Component for developing and managing database-per-tenant
oriented systems.  To achieve this we wrap and extend the popular `Ecto` and
`EctoSql` libraries with a specialized templated (`EEx`) migrations system and add
additional, opinionated abstractions encapsulating the tenant model as it
relates to development, data access, and runtime concerns.

>#### Important {: .warning}
>
> "Database-per-tenant" is not the typical tenancy implementation pattern for
> Elixir/Phoenix based applications.  As with most choices in software
> architecture and engineering there are trade-offs between the different
> tenancy approaches that you should be well-versed with prior to committing to
> this or any other tenancy model for your applications.

## Concepts

There are several concepts requiring definitions which should be understood
before continuing.  Most of these concepts relate to runtime concerns though
understanding them will inform your sense of the possibilities and constraints
on development and deployment scenarios.

#### Datastore

A Datastore can most simply be thought of as a single database created to
support either a tenant environment or an administrative function of the
application.  More specifically speaking, a Datastore establishes a store of
data and a security boundary at the database level for the data of a tenant or
of administrative functionality.

Using `MscmpSystDb.create_datastore/2` automatically will create the database
backing the Datastore.

Datastores and the Ecto dynamic repositories which back them are started and
stopped at runtime using this Component's API.  Datastores are not typically
started directly via OTP application related functionality at application
startup.  This is chiefly because we don't assume to even know what Datastores
actually exist until we've started up an administrative Datastore which records
the information.

#### Datastore Context

A Datastore Context represents a PostgreSQL database role which is used to
establish Datastore access and security contexts using database security
features. Datastore Contexts are specific to a single Datastore and are managed
by the this Component, including the creation, maintenance, and dropping of them
as needed, typically in conjunction with Datastore creation/deletion.

Behind the scenes Datastore Contexts use the ["Ecto Dynamic Repositories"](https://hexdocs.pm/ecto/replicas-and-dynamic-repositories.html#dynamic-repositories) feature.
Each Datastore Context is backed by an Ecto Dynamic Repo.   Starting a Datastore
Context starts its Ecto Dynamic Repo including establishing the connections to
the database.  Stopping a Datastore Context shuts that associated Dynamic Repo
down and terminates its database connections.

There are several different kinds of Datastore Contexts which can be defined:

  * __Owner__: This kind of Datastore Context creates a database role to serve
    as the database owner of all the database objects backing the Datastore
    making it the de facto admin role for the Datastore.  While the Owner
    Datastore Context owns the database objects backing the Datastore, it is
    only a regular database role (no special database rights) and it cannot be a
    database login role itself.  All Datastores must have exactly one Owner
    Datastore Context defined.

  * __Login__: The Login Datastore Context is a regular database role with which
    the application can log into the database and perform operations allowed by
    the database security policies established by the database developer.  There
    can be one or more Login Datastore Contexts in order to support various
    security profiles that the application may assume or in order to build
    connection pools with varying limits depending on some application specific
    need (e.g. connections support web user interface vs. connections supporting
    external API interactions.).  For a Datastore to be useful there must be at
    least one Login Datastore Context defined for the Datastore.

  * __Non-Login__: While the Owner Datastore Context is required, there are
    other possible scenarios where non-login roles could be useful in managing
    access to specific database objects, but how useful Non-Login roles might
    be will depend on application specific factors; the expectation is that
    their use will be rare.  Naturally, there is no requirement for Non-Login
    Datastore Contexts to be defined for any Datastore.

Finally, when we access the database from the application we'll always be doing
so identifying one of our Login Datastore Contexts.  This is done using
`MscmpSystDb.put_datastore_context/1` which behind the scenes is using the
`Ecto.Repo` dynamic repository features (`c:Ecto.Repo.put_dynamic_repo/1`).
Note that there is no default Ecto Repo, dynamic or otherwise, defined in the
system.  Any attempts to access a Datastore Context without having established
the current Datastore Context for the process will cause the process to crash.

>#### Warning! {: .warning}
>
> Datastore Contexts are created and destroyed by the application using the API
> functions in this Component.  The current implementation of Login Datastore
> Contexts, however, is expected to have certain security weaknesses related to
> database role credential management.
>
> With this in mind, __*do not look to our implementation as an example of how
> to approach such a problem*__ until this and other warnings disappear.  The
> reality is that while in certain on-premise scenarios our current approach
> might well be workable, it was designed with the idea of kicking the can of a
> difficult and sensitive problem down the road and not as a final solution that
> we'd stand behind.  We do believe this problem is solvable with sufficient
> time and expertise.

## Database Development

Our development model assumes that there are fundamentally two phases of
development related to the database: __*Initial/Major Development*__ and
__*Ongoing Maintenance*__.

#### Initial/Major Development

When initially developing a database schema, prior to any releases of usable
software the typical "migrations" oriented development pattern of a continuing
sequence of incremental changes is significantly less useful than it is during
later, maintenance oriented phases of development.  During initial development
it is more useful to see database schema changes through the lens of traditional
source control methodologies.  The extend to which this is true will naturally
vary depending on the application.  Larger, database-centric applications will
benefit from this phase of development significantly more than smaller
applications where the database is simple persistence and data isn't significant
beyond this persistence support role.

#### Ongoing Maintenance

Once there is an active release of the software and future deployments will be
focused on maintaining already running databases, our model shifts to the norms
typical of the traditional migrations database development model.  We expect
smaller, relatively independent changes which are simply applied in sequence.
Unlike other migration tools such as the migrator built into `EctoSql`, we have
some additional ceremony related to sequencing migrations, but aside from these
minor differences our migrations will resemble those of other tools once in the
maintenance phase of development.

>#### Note {: .neutral}
>
> Despite the discussion above, the distinction between "Initial/Major
> Development" and "Ongoing Maintenance" is a distinction in developer practice
> only; the tool itself doesn't make this distinction but merely is designed to
> work in a way which supports a workflow recognizing these phases.  The cost of
> being able to support the Initial/Major Development concept is that migrations
> are not numbered or sequenced automatically as will be shown below.  If you
> don't need the Initial/Major Development phase, the traditional `EctoSql`
> migrator may be more suitable to your needs.

#### Source Files & Building Migrations Overview

In the more typical migrations model, the migration files are themselves the
source code of the database changes.  This Component separates the two concepts:

  * Database source code files are written by the developer as the developer
    sees fit.  Database source files are what we are most concerned with from a
    source control perspective; and these files can be freely modified and
    changes committed up to the point that they are built into released
    migrations.  Database source files are written in (mostly) plain SQL; `EEx`
    tags are allowed in the SQL and can be bound during migration time.

  * Once the database source code has reached some stage of completion, the
    developer can use the `mix builddb` task to generate migration files from
    the database sources.  In order to build the migration files, the developer
    will create a `TOML` "build plan" file which indicates which database source
    files to include in the migrations and their sequence.  For more about the
    build process and build plans see the `mix builddb` task documentation.

Now let's connect this back to the development phases discussed previously.
During the "Initial/Major Development" phase, we expect that there will be many
database source files and that these files will be written, committed to source
control, modified, and re-committed to source control not as migrations but as
you would any other source file (for example, maybe one file per table.); we
might also be building migration files at this time for testing purposes, but
until the application is released we'd expect the migration files to be cleaned
out and rebuilt.  Finally once tests, code, reviews, etc. are complete and a
release is ready to be prepared, a final `mix builddb` is run to create the
release migrations and those migrations are committed to source control.

From this point forward we generally wouldn't modify the original database
source files or the final release migrations: the release migrations are
essentially set in stone once they may be deployed to a environment where
dropping the database is not an option.  Subsequent development in the "Ongoing
Maintenance" phase looks similar to traditional migration development.  For any
modification to the database you'll create new a database source file(s) for
those modifications specifically and they'll get new version numbers which will
in turn create new migrations when `mix builddb` builds them.  These will then
be deployed to the database as standard migrations would.

## Migration Deployments

Once built, migration files are deployed to a database similar to the way
traditional migration systems perform their deployments: the migrations are
checked, in migration number order, against a special database table listing the
previously deployed migrations (table `ms_syst_db.migrations`).  If a migration
has been previously deployed, it's skipped and the deployment process moves onto
the next migration; if the migration needs to be deployed it is applied to the
database and, assuming successful deployment, the process moves onto the next
migration or exits when all outstanding migrations have been applied.

Each individual migration is applied in a single database transaction.  This
means that if part of a migration fails to apply to the database successfully,
the entire migration is rolled back and the database will be in the state of the
last fully successful migration application.  A migration application failure
will abort the migration process, cancelling the attempted application of
migrations after the failed migration.

Unlike the `EctoSql` based migration process, migrations in `MscmpSystDb` are
expected to be managed at runtime by the application.  There is no external
`mix` oriented migration deployment process.  Migration processes are started
for each tenant database individually allowing for selective application of
migrations to the specified environment or allowing for "upgrade window" style
functionality.  Migrations are also `EEx` templates and template bindings can be
supplied to the migrator to make each deployment specific to the database being
migrated if appropriate.   Naturally, much depends on the broader application
design, but the migrator can support a number of different scenarios for
deployment of database changes.

Finally, the migrator, can in a single application, manage and migrate different
database schemas/migration sets depending on the identified "type".  This means
that different database schemas for different subsystems can be supported by the
migration system in a single application.  This assumes that a single database
is of a single type; that type may be any of the available types, but mixing of
types in a single database is not allowed.

## Custom Database Types

`Ecto`, `EctoSql`, and the underlying PostgreSQL library `Postgrex` offer decent
PostgreSQL data type support out of box, but they don't directly map some of the
database types that can be helpful in business software such as PostgreSQL range
types, internet address types, and interval types.  To this end we add some
custom database data types via the modules in the `MscmpSystDb.DbTypes.*`
namespace.

## Data Access Interface

The `Ecto` library offers a data access and manipulation API via the `Ecto.Repo`
module.  We wrap and in some cases extend the majority of that functionality in
this Component as documented in the [Query section](#query).  As a rule of
thumb, you want to call on this module for such needs even if the same can be
achieved with the `Ecto` library.  This recommendation is not meant to suggest
that you shouldn't use the `Ecto.Query` related DSL or methods for constructing
queries; using the Ecto Query DSL is, in fact, recommended absent compelling
reason to do otherwise.