+++
title = "System Component Listing"
linkTitle = "System Component Listing"
description = "Here we begin documenting the system in detail, moving away from purely conceptual discussions to examining more concrete implementation details."

draft = false

weight = 30
+++
{{< alert title="Dependency Listings" color="warning" >}}
Note that only dependencies which are active at runtime in production are listed below. Excluded are those dependencies that are only present to support development or testing.
{{< /alert >}}

## Application Server Documentation

The listing below shows the currently existing Elixir components which make up the application server (`app_server`), their dependencies, and their relationship with each other.

### `Msplatform`

`Msplatform` is an Elixir/Phoenix umbrella project which provides the runtime environment for its hosted user applications and defines the user interfaces (web/external API).  The umbrella itself exists to support these application/Subsystem runtime boundaries including the conditional inclusion/exclusion of various Subsystems in any given client specific build/release.  The `apps` of the Msplatform umbrella are:

  * #### `MsappMcpWeb`

    <sup>(<a href="/musebms/documentation/technical/app_server/msapp_mcp_web" target="_blank">API Docs</a>)</sup>

    Defines the Phoenix user interface "view" layer used by users of the Master Control Program (MCP) application.  In addition, operational issues such as request routing and other typical Phoenix web related functions are handled here as well.  This component invokes `MsappMcp` functionality in order to carry out user wishes.

    * __First Party Dependencies__

      <a href="#mscmpsystforms">`MscmpSystForms`</a>,
      <a href="#msappmcp">`MsappMcp`</a>

    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/phoenix" target="_blank">`phoenix`</a>,
      <a href="https://hexdocs.pm/phoenix_ecto" target="_blank">`phoenix_ecto`</a>,
      <a href="https://hexdocs.pm/phoenix_html" target="_blank">`phoenix_html`</a>,
      <a href="https://hexdocs.pm/phoenix_live_reload" target="_blank">`phoenix_live_reload`</a>,
      <a href="https://hexdocs.pm/phoenix_live_view" target="_blank">`phoenix_live_view`</a>,
      <a href="https://hexdocs.pm/floki" target="_blank">`floki`</a>,
      <a href="https://hexdocs.pm/phoenix_live_dashboard" target="_blank">`phoenix_live_dashboard`</a>,
      <a href="https://hexdocs.pm/esbuild" target="_blank">`esbuild`</a>,
      <a href="https://hexdocs.pm/tailwind" target="_blank">`tailwind`</a>,
      <a href="https://hexdocs.pm/telemetry_metrics" target="_blank">`telemetry_metrics`</a>,
      <a href="https://hexdocs.pm/telemetry_poller" target="_blank">`telemetry_poller`</a>,
      <a href="https://hexdocs.pm/gettext" target="_blank">`gettext`</a>,
      <a href="https://hexdocs.pm/jason" target="_blank">`jason`</a>,
      <a href="https://hexdocs.pm/plug_cowboy" target="_blank">`plug_cowboy`</a>,
      <a href="https://hexdocs.pm/ex_doc" target="_blank">`ex_doc`</a>

  * #### `MsappMcp`

    <sup>(<a href="/musebms/documentation/technical/app_server/msapp_mcp" target="_blank">API Docs</a>)</sup>

    Provides the MCP "controller" level logic which responds to user input from the view layer and invokes logic from the `MssubMcp` Subsystem.  `MsappMcp` also defines the abstract configuration of the various user interface forms according to form development standards set by the [`MscmpSystForms`](#mscmpsystforms) Component.

    * __First Party Dependencies__

      <a href="#mscmpsysterror">`MscmpSystError`</a>,
      <a href="#mscmpsystoptions">`MscmpSystOptions`</a>,
      <a href="#mscmpsystforms">`MscmpSystForms`</a>,
      <a href="#mssubmcp">`MssubMcp`</a>

    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/phoenix_pubsub" target="_blank">`phoenix_pubsub`</a>,
      <a href="https://hexdocs.pm/swoosh" target="_blank">`swoosh`</a>,
      <a href="https://hexdocs.pm/finch" target="_blank">`finch`</a>,
      <a href="https://hexdocs.pm/net_address" target="_blank">`net_address`</a>

## Subsystems

  * ### `MssubMcp`

      <sup>(<a href="/musebms/documentation/technical/app_server/mssub_mcp" target="_blank">API Docs</a>)</sup>

      API for defining a standard for error handling and reporting.

      * __First Party Dependencies__

        (none)

      * __Third Party Dependencies__

        (none)

  * ### `MssubBms`

      <sup>(<a href="/musebms/documentation/technical/app_server/mssub_bms" target="_blank">API Docs</a>)</sup>

      (Undefined)

      * __First Party Dependencies__

        (none)

      * __Third Party Dependencies__

        (none)

## Component Documentation

These Components are listed in "Lower Level Component" to "Higher Level Component" order.  Lower Level Components offer more simple, base level functionality whereas Higher Level Components will offer more complex functionality closer to the final business logic.  Often times Higher Level Components will depend on Lower Level Components.

  * ### `MscmpSystUtils`

    <sup>(<a href="/musebms/documentation/technical/app_server/mscmp_syst_utils" target="_blank">API Docs</a>)</sup>

    Common utility functions generally useful across components.

  * ### `MscmpSystError`

    <sup>(<a href="/musebms/documentation/technical/app_server/mscmp_syst_error" target="_blank">API Docs</a>)</sup>

    This module defines a nested structure for reporting errors in contexts where a result should be represented by an error result. By capturing lower level errors and reporting them in a standard way, various application errors, especially non-fatal errors, can be handled as appropriate and logged for later analysis.

  * ### `MscmpSystLimiter`

    <sup>(<a href="/musebms/documentation/technical/app_server/mscmp_syst_limiter" target="_blank">API Docs</a>)</sup>

    This component limits the rate at which targeted services can be called by any one caller to a level which preserves the availability of resources to all users of the system, or makes brute force information gathering prohibitively time intensive to would be attackers of the system.

    * __First Party Dependencies__

      <a href="#mscmpsysterror">`MscmpSystError`</a>,
      <a href="#mscmpsystutils">`MscmpSystUtils`</a>

    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/hammer" target="_blank">`Hammer`</a>

  * ### `MscmpSystDb`

    <sup>(<a href="/musebms/documentation/technical/app_server/mscmp_syst_db" target="_blank">API Docs</a>)</sup>

    A database management library for developing and managing database-per-tenant oriented systems.  To achieve this we wrap and extend the popular `Ecto` and `EctoSql` libraries with a specialized templated migration system and add additional, opinionated abstractions encapsulating the tenant model as it relates to development, data access, and runtime concerns.

    * __First Party Dependencies__

      <a href="#mscmpsysterror">`MscmpSystError`</a>,
      <a href="#mscmpsystutils">`MscmpSystUtils`</a>

    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/ecto_sql" target="_blank">`ecto_sql`</a>,
      <a href="https://hexdocs.pm/ecto" target="_blank">`ecto`</a>,
      <a href="https://hexdocs.pm/ex_doc" target="_blank">`ex_doc`</a>,
      <a href="https://hexdocs.pm/jason" target="_blank">`jason`</a>,
      <a href="https://hexdocs.pm/postgrex" target="_blank">`postgrex`</a>,
      <a href="https://hexdocs.pm/toml" target="_blank">`toml`</a>,
      <a href="https://hexdocs.pm/net_address" target="_blank">`net_address`</a>

  * ### `MscmpSystOptions`

    <sup>(<a href="/musebms/documentation/technical/app_server/mscmp_syst_options" target="_blank">API Docs</a>)</sup>

    API for retrieving and working with option files stored in the application server file system.

    * __First Party Dependencies__

      <a href="#mscmpsysterror">`MscmpSystError`</a>,
      <a href="#mscmpsystdb">`MscmpSystDb`</a>

    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/toml" target="_blank">`toml`</a>

  * ### `MscmpSystSettings`

    <sup>(<a href="/musebms/documentation/technical/app_server/mscmp_syst_settings" target="_blank">API Docs</a>)</sup>

    The Settings Service provides caching and management functions for user configurable options which govern how the application operates.  Multiple Settings Service instances may be in operation depending on the needs of the application; for example, in the case of multi-tenancy, each tenant will have its own instance of the Setting Service running since each tenant's needs of the application may unique.

    * __First Party Dependencies__

      <a href="#mscmpsysterror">`MscmpSystError`</a>,
      <a href="#mscmpsystutils">`MscmpSystUtils`</a>,
      <a href="#mscmpsystdb">`MscmpSystDb`</a>

  * ### `MscmpSystEnums`

    <sup>(<a href="/musebms/documentation/technical/app_server/mscmp_syst_enums" target="_blank">API Docs</a>)</sup>

    A framework for user configurable 'list of values' type functionality.

    * __First Party Dependencies__

      <a href="#mscmpsysterror">`MscmpSystError`</a>,
      <a href="#mscmpsystutils">`MscmpSystUtils`</a>,
      <a href="#mscmpsystdb">`MscmpSystDb`</a>

  * ### `MscmpSystInstance`

    <sup>(<a href="/musebms/documentation/technical/app_server/mscmp_syst_instance" target="_blank">API Docs</a>)</sup>

    "Instances" are instances of running application environments.  Instances are established to host the application for different purposes, such as for running the application for production, training, and testing purposes; or as a means to implement multi-tenancy where each tenant application environment is an Instance.

    Each Instance also requires supporting data in order to facilitate runtime actions, such as defining database roles with which to access database data.  Such supporting information is also managed via this component.

    * __First Party Dependencies__

      <a href="#mscmpsysterror">`MscmpSystError`</a>,
      <a href="#mscmpsystutils">`MscmpSystUtils`</a>,
      <a href="#mscmpsystdb">`MscmpSystDb`</a>,
      <a href="#mscmpsystoptions">`MscmpSystOptions`</a>,
      <a href="#mscmpsystenums">`MscmpSystEnums`</a>,

  * ### `MscmpSystAuthn`

    <sup>(<a href="/musebms/documentation/technical/app_server/mscmp_syst_authn" target="_blank">API Docs</a>)</sup>

    API for the management of user authentication.

    This Component provides a global method of authentication for users wishing to use the system.

    * __First Party Dependencies__

      <a href="#mscmpsysterror">`MscmpSystError`</a>,
      <a href="#mscmpsystutils">`MscmpSystUtils`</a>,
      <a href="#mscmpsystlimiter">`MscmpSystLimiter`</a>,
      <a href="#mscmpsystdb">`MscmpSystDb`</a>,
      <a href="#mscmpsystoptions">`MscmpSystOptions`</a>,
      <a href="#mscmpsystenums">`MscmpSystEnums`</a>,
      <a href="#mscmpsystinstance">`MscmpSystInstance`</a>

    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/argon2_elixir" target="_blank">`argon2_elixir`</a>,
      <a href="https://hexdocs.pm/nimble_totp" target="_blank">`nimble_totp`</a>,
      <a href="https://hexdocs.pm/net_address" target="_blank">`net_address`</a>,
      <a href="https://hexdocs.pm/pathex" target="_blank">`pathex`</a>,
      <a href="https://hexdocs.pm/timex" target="_blank">`timex`</a>

  * ### `MscmpSystPerms`

    <sup>(<a href="/musebms/documentation/technical/app_server/mscmp_syst_perms" target="_blank">API Docs</a>)</sup>

    Provides a generalized foundation for user permission system implementations.

    The principle idea of this component is to organization permissions in a way that higher level components can introduce the concept of user and establish contexts of applicability while keeping a cohesion in permissioning capability.  To this end this component provides the core concepts for use in any permissioning system using this ecosystem of components.

    * __First Party Dependencies__

      <a href="#mscmpsysterror">`MscmpSystError`</a>,
      <a href="#mscmpsystutils">`MscmpSystUtils`</a>,
      <a href="#mscmpsystdb">`MscmpSystDb`</a>

  * ### `MscmpSystMcpPerms`

    <sup>(<a href="/musebms/documentation/technical/app_server/mscmp_syst_mcp_perms" target="_blank">API Docs</a>)</sup>

    Implements [`MscmpSystPerms`](#mscmpsystperms) related functionality for the [`MssubMcp`](#mssub_mcp) subsystem.

    * __First Party Dependencies__

      <a href="#mscmpsysterror">`MscmpSystError`</a>,
      <a href="#mscmpsystutils">`MscmpSystUtils`</a>,
      <a href="#mscmpsystlimiter">`MscmpSystLimiter`</a>,
      <a href="#mscmpsystdb">`MscmpSystDb`</a>,
      <a href="#mscmpsystauthn">`MscmpSystAuthn`</a>,
      <a href="#mscmpsystperms">`MscmpSystPerms`</a>

  * ### `MscmpSystSession`

    <sup>(<a href="/musebms/documentation/technical/app_server/mscmp_syst_session" target="_blank">API Docs</a>)</sup>

    Session Management API & Runtime

    * __First Party Dependencies__

      <a href="#mscmpsysterror">`MscmpSystError`</a>,
      <a href="#mscmpsystutils">`MscmpSystUtils`</a>,
      <a href="#mscmpsystdb">`MscmpSystDb`</a>

  * ### `MscmpSystForms`

    <sup>(<a href="/musebms/documentation/technical/app_server/mscmp_syst_forms" target="_blank">API Docs</a>)</sup>

    The `MscmpSystForms` module provides a standard methodology for authoring application user interface forms in support of business management system development.


    * __First Party Dependencies__

      <a href="#mscmpsysterror">`MscmpSystError`</a>,
      <a href="#mscmpsystutils">`MscmpSystUtils`</a>,
      <a href="#mscmpsystperms">`MscmpSystPerms`</a>

    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/phoenix" target="_blank">`phoenix`</a>,
      <a href="https://hexdocs.pm/phoenix_live_view" target="_blank">`phoenix_live_view`</a>,
      <a href="https://hexdocs.pm/phoenix_ecto" target="_blank">`phoenix_ecto`</a>,
      <a href="https://hexdocs.pm/gettext" target="_blank">`gettext`</a>

## Database Documentation

Database schema are current only documented at the Subsystem level.

  * ### `MssubMcp` {#mssub_mcp_db}

    <sup>(<a href="/musebms/documentation/technical/database/mssub_mcp" target="_blank">Database Docs / ERD</a>)</sup>

  * ### `MssubBms` {#mssub_bms_db}

    <sup>(<a href="/musebms/documentation/technical/database/mssub_bms" target="_blank">Database Docs / ERD</a>)</sup>