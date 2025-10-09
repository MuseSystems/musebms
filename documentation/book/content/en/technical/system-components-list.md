+++
title = "System Component Listing"
linkTitle = "System Component Listing"
description = "Here we begin documenting the system in detail, moving away from purely conceptual discussions to examining more concrete implementation details."

draft = false

weight = 30
+++

{{< alert title="Example Documentation" color="primary" >}}
If you are reading this documentation to see and/or evaluate examples of this project's documentation, we recommend looking at the [__`MscmpSystAuthn`__](#mscmpsystauthn) Component documentation.  This documentation is reasonably complete and representative of the documentation standards this project hopes to achieve.
{{< /alert >}}

## Overview

The listing below shows the currently existing Elixir components which make up the application server (`app_server`), their dependencies, and their relationship with each other.

{{< alert title="Dependency Listings" color="warning" >}}
Note that only dependencies which are active at runtime in production are listed below. Excluded are those dependencies that are only present to support development or testing.
{{< /alert >}}


Each listed Component includes links to its application API documentation.  If the Component depends on the database, a link to the Component specific database documentation and ERD is also included.  Note that the inclusion of the database documentation at the Component level is not meant to imply that each Component requires its own database, but rather to ensure that only the relevant database documentation is presented in the Component context.


## Platform

_(No platform components found)_


## Subsystems

_(No subsystem components found)_


## Component Documentation

These Components are listed in "Lower Level Component" to "Higher Level Component" order.  Lower Level Components offer more simple, base level functionality whereas Higher Level Components will offer more complex functionality closer to the final business logic.  Often times Higher Level Components will depend on Lower Level Components.

  * ### `MscmpSystAuthn`

    <sup>(<a href="/documentation/technical/app_server/mscmp_syst_authn" target="_blank">API Docs</a>) / (<a href="/documentation/technical/database/mscmp_syst_authn" target="_blank">Database Docs & ERD</a>)</sup>

    API for the management of user authentication.
    
    This Component provides a global method of authentication for users wishing to
    use the system.  General features supported by this Component include:
    
      * The ability to host user accounts that are managed by specific tenants
    
      * The ability to host user accounts that are independent of any specific
      tenant (e.g. freelance bookkeepers)
    
      * Authentication rights for users to specific Application Instances
    
      * Use of a single user account to authenticate to Application Instances
      owned by different tenants.
    
      * Individual tenant controls over certain authentication controls such as
      Password Credential complexity or requiring Multi-Factor Authentication
    
      * The ability to establish "Network Rules" which act as a sort of firewall
      allowing or denying certain origin host IP addresses or networks the right
      to attempt authentication
    
      * Rate limiting of authentication attempts enforced, independently, by
      identifier and by originating host IP address
    
    Note that this Component doesn't provide a substantial authorization
    capability.  Authorization needs are left for higher level, Application
    Instance functionality to fulfill.

    * __First Party Dependencies__

      <a href="#mscmpsystdb">`mscmp_syst_db`</a>,
      <a href="#mscmpsystenums">`mscmp_syst_enums`</a>,
      <a href="#mscmpsysterror">`mscmp_syst_error`</a>,
      <a href="#mscmpsystinstance">`mscmp_syst_instance`</a>,
      <a href="#mscmpsystlimiter">`mscmp_syst_limiter`</a>,
      <a href="#mscmpsystnetwork">`mscmp_syst_network`</a>,
      <a href="#mscmpsystoptions">`mscmp_syst_options`</a>,
      <a href="#mscmpsystutils">`mscmp_syst_utils`</a>,
      <a href="#mscmpsystutilsdata">`mscmp_syst_utils_data`</a>


    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/jason" target="_blank">`jason`</a>,
      <a href="https://hexdocs.pm/nimble_options" target="_blank">`nimble_options`</a>,
      <a href="https://hexdocs.pm/nimble_totp" target="_blank">`nimble_totp`</a>,
      <a href="https://hexdocs.pm/pathex" target="_blank">`pathex`</a>,
      <a href="https://hexdocs.pm/timex" target="_blank">`timex`</a>


  * ### `MscmpSystDb`

    <sup>(<a href="/documentation/technical/app_server/mscmp_syst_db" target="_blank">API Docs</a>)</sup>

    A database management Component for developing and managing database-per-tenant
    oriented systems.  To achieve this we wrap and extend the popular `Ecto` and
    `EctoSql` libraries with a specialized templated (`EEx`) migrations system and add
    additional, opinionated abstractions encapsulating the tenant model as it
    relates to development, data access, and runtime concerns.

    * __First Party Dependencies__

      <a href="#mscmpsysterror">`mscmp_syst_error`</a>,
      <a href="#mscmpsystnetwork">`mscmp_syst_network`</a>,
      <a href="#mscmpsysttelemetry">`mscmp_syst_telemetry`</a>,
      <a href="#mscmpsystutils">`mscmp_syst_utils`</a>


    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/ecto" target="_blank">`ecto`</a>,
      <a href="https://hexdocs.pm/ecto_sql" target="_blank">`ecto_sql`</a>,
      <a href="https://hexdocs.pm/jason" target="_blank">`jason`</a>,
      <a href="https://hexdocs.pm/nimble_options" target="_blank">`nimble_options`</a>,
      <a href="https://hexdocs.pm/postgrex" target="_blank">`postgrex`</a>,
      <a href="https://hexdocs.pm/toml" target="_blank">`toml`</a>


  * ### `MscmpSystEnums`

    <sup>(<a href="/documentation/technical/app_server/mscmp_syst_enums" target="_blank">API Docs</a>) / (<a href="/documentation/technical/database/mscmp_syst_enums" target="_blank">Database Docs & ERD</a>)</sup>

    A framework for user configurable 'list of values' functionality.
    
    List of values can serve two purposes in business systems:
    
      1. Making selections between optional system behaviors for some given entity
         or calculation.
    
      2. Selection of categorization for informational/reporting purposes.
    
    When supporting the first purpose such choices benefit from being well defined
    and closely matched to the functional choices available.  The second purpose,
    however, is often times better served by a finer grained set of selection values
    which are user defined rather than chosen ahead of time by the application
    developer.  This component offers a solution for those cases when these two
    needs diverge, allowing the system developers to create a well defined list of
    choices matched to system capabilities while at the same time allowing users to
    establish a more extensive and nuance set of choices matching their
    informational needs without have to create duplicative fields for a given master
    or transactional data type.

    * __First Party Dependencies__

      <a href="#mscmpsystdb">`mscmp_syst_db`</a>,
      <a href="#mscmpsysterror">`mscmp_syst_error`</a>,
      <a href="#mscmpsystservice">`mscmp_syst_service`</a>,
      <a href="#mscmpsysttelemetry">`mscmp_syst_telemetry`</a>,
      <a href="#mscmpsystutils">`mscmp_syst_utils`</a>,
      <a href="#mscmpsystutilsdata">`mscmp_syst_utils_data`</a>


    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/nimble_options" target="_blank">`nimble_options`</a>


  * ### `MscmpSystError`

    <sup>(<a href="/documentation/technical/app_server/mscmp_syst_error" target="_blank">API Docs</a>)</sup>

    MscmpSystError establishes a common framework for defining and handling errors.
    
    MscmpSystError provides a structured way to define and handle errors within an
    application. It defines a set of fields that errors should include, such as
    `kind`, `message`, `context`, and `cause`. This standardization enables
    consistent error handling and reporting across different parts of an
    application.

    * __First Party Dependencies__

      (none)


    * __Third Party Dependencies__

      (none)


  * ### `MscmpSystHierarchy`

    <sup>(<a href="/documentation/technical/app_server/mscmp_syst_hierarchy" target="_blank">API Docs</a>) / (<a href="/documentation/technical/database/mscmp_syst_hierarchy" target="_blank">Database Docs & ERD</a>)</sup>

    API providing a baseline methodology for defining Hierarchies and validating
    that implementations of those Hierarchies are valid.
    
    The Hierarchy features supported by this Component are:
    
      * Providing a Hierarchy definition with which implementations can be
      validated.
    
      * Support for optionally validated Hierarchies ("structured" vs.
      "unstructured").
    
      * Support of optional Hierarchy levels.
    
      * Specification of which Hierarchy levels may be associated with "Leaf Nodes";
      for example a Hierarchy defining an application menu structure may allow for
      levels which only define menu item groupings or may be associated directly
      with actionable application menu items where the menu items are "Leaf Nodes".
    
      * Protection of in-use Hierarchy definitions to ensure Hierarchy
      implementation operational consistency.

    * __First Party Dependencies__

      <a href="#mscmpsystdb">`mscmp_syst_db`</a>,
      <a href="#mscmpsystenums">`mscmp_syst_enums`</a>,
      <a href="#mscmpsysterror">`mscmp_syst_error`</a>,
      <a href="#mscmpsysttelemetry">`mscmp_syst_telemetry`</a>,
      <a href="#mscmpsystutils">`mscmp_syst_utils`</a>


    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/nimble_options" target="_blank">`nimble_options`</a>


  * ### `MscmpSystInstance`

    <sup>(<a href="/documentation/technical/app_server/mscmp_syst_instance" target="_blank">API Docs</a>) / (<a href="/documentation/technical/database/mscmp_syst_instance" target="_blank">Database Docs & ERD</a>)</sup>

    API allowing for the management of application Instances.
    
    "Instances" are instances of running application environments.  Instances are
    established to host the application for different purposes, such as for
    running the application for production, training, and testing purposes; or as
    a means to implement multi-tenancy where each tenant application environment
    is an Instance.
    
    Each Instance also requires supporting data in order to facilitate runtime
    actions, such as defining database roles with which to access database data.
    Such supporting information is also managed via this component.

    * __First Party Dependencies__

      <a href="#mscmpsystdb">`mscmp_syst_db`</a>,
      <a href="#mscmpsystenums">`mscmp_syst_enums`</a>,
      <a href="#mscmpsysterror">`mscmp_syst_error`</a>,
      <a href="#mscmpsystoptions">`mscmp_syst_options`</a>,
      <a href="#mscmpsysttelemetry">`mscmp_syst_telemetry`</a>,
      <a href="#mscmpsystutils">`mscmp_syst_utils`</a>


    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/nimble_options" target="_blank">`nimble_options`</a>


  * ### `MscmpSystLimiter`

    <sup>(<a href="/documentation/technical/app_server/mscmp_syst_limiter" target="_blank">API Docs</a>)</sup>

    API for establishing rate limits for usage of finite system resources.
    
    Many activities in the system consume available scarce computing resources or
    are otherwise rightfully subject to limitations on usage or consumption.  This
    Component provides simple rate limiting algorithms to allow other, higher level
    Components to implement rate limiting as they might require for their specific
    purposes.

    * __First Party Dependencies__

      <a href="#mscmpsysterror">`mscmp_syst_error`</a>,
      <a href="#mscmpsystservice">`mscmp_syst_service`</a>,
      <a href="#mscmpsysttelemetry">`mscmp_syst_telemetry`</a>,
      <a href="#mscmpsystutils">`mscmp_syst_utils`</a>


    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/nimble_options" target="_blank">`nimble_options`</a>


  * ### `MscmpSystMcpPerms`

    <sup>(<a href="/documentation/technical/app_server/mscmp_syst_mcp_perms" target="_blank">API Docs</a>) / (<a href="/documentation/technical/database/mscmp_syst_mcp_perms" target="_blank">Database Docs & ERD</a>)</sup>

    Implements `MscmpSystPerms` related functionality for the `MssubMcp` subsystem.
    
    The only public API provided by this module are the selector structs which are
    used to identify the user context of various Permission related actions. These
    structs implement the `MscmpSystPerms.Protocol` and are usable via the
    Permissions Protocol API at `MscmpSystPerms`.
    
    For more complete information about Permissions, see the `MscmpSystPerms`
    component documentation.

    * __First Party Dependencies__

      <a href="#mscmpsystauthn">`mscmp_syst_authn`</a>,
      <a href="#mscmpsystdb">`mscmp_syst_db`</a>,
      <a href="#mscmpsysterror">`mscmp_syst_error`</a>,
      <a href="#mscmpsystperms">`mscmp_syst_perms`</a>,
      <a href="#mscmpsystutils">`mscmp_syst_utils`</a>


    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/nimble_options" target="_blank">`nimble_options`</a>


  * ### `MscmpSystNetwork`

    <sup>(<a href="/documentation/technical/app_server/mscmp_syst_network" target="_blank">API Docs</a>)</sup>

    Simple IP address handling and convenience functionality.
    
    IP addresses in Erlang, and by extension Elixir, are expressed as tuples with an element reserved
    for each segment of the IP address.  This works well enough, but departs from the standard CIDR
    notation used by most professionals.  In fact, the Erlang/Elixir standard library for dealing with
    IP addresses only deals with addresses and sockets; excluded are representations or utilities for
    dealing with subnets.
    
    This Component aims to make it simpler to work with IP addresses, allowing for CIDR notation
    parsing and for the ability to recognize subnets.

    * __First Party Dependencies__

      <a href="#mscmpsysterror">`mscmp_syst_error`</a>


    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/jason" target="_blank">`jason`</a>


  * ### `MscmpSystOptions`

    <sup>(<a href="/documentation/technical/app_server/mscmp_syst_options" target="_blank">API Docs</a>)</sup>

    API for retrieving and working with option files stored in the application
    server file system.

    * __First Party Dependencies__

      <a href="#mscmpsystdb">`mscmp_syst_db`</a>,
      <a href="#mscmpsysterror">`mscmp_syst_error`</a>


    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/toml" target="_blank">`toml`</a>


  * ### `MscmpSystPerms`

    <sup>(<a href="/documentation/technical/app_server/mscmp_syst_perms" target="_blank">API Docs</a>) / (<a href="/documentation/technical/database/mscmp_syst_perms" target="_blank">Database Docs & ERD</a>)</sup>

    Provides a generalized foundation for user permission system
    implementations.
    
    The principle idea of this component is to organization permissions in a way
    that higher level components can introduce the concept of user and
    establish contexts of applicability while keeping a cohesion in permissioning
    capability.  To this end this component provides the core concepts for use in
    any permissioning system using this ecosystem of components.

    * __First Party Dependencies__

      <a href="#mscmpsystdb">`mscmp_syst_db`</a>,
      <a href="#mscmpsysterror">`mscmp_syst_error`</a>,
      <a href="#mscmpsystutils">`mscmp_syst_utils`</a>,
      <a href="#mscmpsystutilsdata">`mscmp_syst_utils_data`</a>


    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/nimble_options" target="_blank">`nimble_options`</a>


  * ### `MscmpSystService`

    <sup>(<a href="/documentation/technical/app_server/mscmp_syst_service" target="_blank">API Docs</a>)</sup>

    Establishes a Behaviour and common system or instance service patterns for the
    application.
    
    A number of persistent services are needed to successfully run the Muse Systems
    Business Management system.  Many of these services may also need to be started
    and run on a per-Instance basis and will thus have many of the same service
    selection requirements between different services.  This module establishes the
    common patterns that individual services should implement.

    * __First Party Dependencies__

      (none)


    * __Third Party Dependencies__

      (none)


  * ### `MscmpSystSession`

    <sup>(<a href="/documentation/technical/app_server/mscmp_syst_session" target="_blank">API Docs</a>) / (<a href="/documentation/technical/database/mscmp_syst_session" target="_blank">Database Docs & ERD</a>)</sup>

    Session Management API & Runtime

    * __First Party Dependencies__

      <a href="#mscmpsystdb">`mscmp_syst_db`</a>,
      <a href="#mscmpsysterror">`mscmp_syst_error`</a>,
      <a href="#mscmpsystutils">`mscmp_syst_utils`</a>


    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/nimble_options" target="_blank">`nimble_options`</a>


  * ### `MscmpSystSettings`

    <sup>(<a href="/documentation/technical/app_server/mscmp_syst_settings" target="_blank">API Docs</a>) / (<a href="/documentation/technical/database/mscmp_syst_settings" target="_blank">Database Docs & ERD</a>)</sup>

    A user options configuration management service.
    
    The Settings Service provides caching and management functions for user
    configurable options which govern how the application operates.  Multiple
    Settings Service instances may be in operation depending on the needs of the
    application; for example, in the case of multi-tenancy, each tenant will have
    its own instance of the Setting Service running since each tenant's needs of
    the application may unique.

    * __First Party Dependencies__

      <a href="#mscmpsystdb">`mscmp_syst_db`</a>,
      <a href="#mscmpsysterror">`mscmp_syst_error`</a>,
      <a href="#mscmpsystservice">`mscmp_syst_service`</a>,
      <a href="#mscmpsysttelemetry">`mscmp_syst_telemetry`</a>,
      <a href="#mscmpsystutils">`mscmp_syst_utils`</a>,
      <a href="#mscmpsystutilsdata">`mscmp_syst_utils_data`</a>


    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/nimble_options" target="_blank">`nimble_options`</a>


  * ### `MscmpSystTelemetry`

    <sup>(<a href="/documentation/technical/app_server/mscmp_syst_telemetry" target="_blank">API Docs</a>)</sup>

    Telemetry recording and handling library for the Muse System Business
    Management System.
    
    This library provides standardized instrumentation and telemetry handling
    capabilities for MuseBMS Components, enabling observability, debugging, and
    monitoring across the system.

    * __First Party Dependencies__

      <a href="#mscmpsysterror">`mscmp_syst_error`</a>


    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/telemetry" target="_blank">`telemetry`</a>


  * ### `MscmpSystUtils`

    <sup>(<a href="/documentation/technical/app_server/mscmp_syst_utils" target="_blank">API Docs</a>)</sup>

    This is a set of basic utilities which are generally useful across Components.

    * __First Party Dependencies__

      <a href="#mscmpsysterror">`mscmp_syst_error`</a>


    * __Third Party Dependencies__

      (none)


  * ### `MscmpSystUtilsData`

    <sup>(<a href="/documentation/technical/app_server/mscmp_syst_utils_data" target="_blank">API Docs</a>)</sup>

    This is a set of utilities for working with data which is generally
    useful across components.
    
    Currently included in these utilities are:
    
    * ETS operations
    
      Functions wrap some typical ETS operations so that they return standard result
      tuples.
    
    * Changeset validators
    
      Common validation functions which can be used to validate changesets across
      Components.

    * __First Party Dependencies__

      <a href="#mscmpsysterror">`mscmp_syst_error`</a>


    * __Third Party Dependencies__

      <a href="https://hexdocs.pm/ecto" target="_blank">`ecto`</a>,
      <a href="https://hexdocs.pm/nimble_options" target="_blank">`nimble_options`</a>


