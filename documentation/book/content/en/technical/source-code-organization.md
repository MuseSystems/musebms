+++
title = "Source Code Organization"
linkTitle = "Source Code Organization"
description = "A discussion on how the MuseBMS source code is organized."

draft = false

weight = 20
+++
## Directory Structure

The MuseBMS source and documentation are managed using a single <a href="https://en.wikipedia.org/wiki/Monorepo" target="_blank">monorepo</a>.  The project is subdivided into various conceptually significant directories.

```
.
├── app_server
│   ├── components
│   │   ├── application
│   │   └── system
│   │       ├── mscmp_syst_authn
│   │       ├── mscmp_syst_db
│   │       ├── mscmp_syst_enums
│   │       ├── mscmp_syst_error
│   │       ├── mscmp_syst_forms
│   │       ├── mscmp_syst_instance
│   │       ├── mscmp_syst_limiter
│   │       ├── mscmp_syst_mcp_perms
│   │       ├── mscmp_syst_options
│   │       ├── mscmp_syst_perms
│   │       ├── mscmp_syst_session
│   │       ├── mscmp_syst_settings
│   │       └── mscmp_syst_utils
│   ├── platform
│   │   └── msplatform
│   └── subsystems
│       ├── mssub_bms
│       └── mssub_mcp
├── database
│   ├── all
│   ├── components
│   │   ├── application
│   │   │   ├── mscmp_acc_calendar
│   │   │   ├── mscmp_brm_contact
│   │   │   ├── mscmp_brm_country
│   │   │   ├── mscmp_brm_entity
│   │   │   ├── mscmp_brm_entity_bank
│   │   │   ├── mscmp_brm_entity_facility
│   │   │   ├── mscmp_brm_entity_inventory
│   │   │   ├── mscmp_brm_entity_person
│   │   │   ├── mscmp_brm_entity_purch
│   │   │   ├── mscmp_brm_entity_selling
│   │   │   ├── mscmp_brm_entity_staff
│   │   │   ├── mscmp_brm_person
│   │   │   ├── mscmp_brm_person_contact
│   │   │   ├── mscmp_brm_place
│   │   │   └── mscmp_syst_interactions
│   │   └── system
│   │       ├── mscmp_syst_authn
│   │       ├── mscmp_syst_docnum
│   │       ├── mscmp_syst_enums
│   │       ├── mscmp_syst_features
│   │       ├── mscmp_syst_formats
│   │       ├── mscmp_syst_instance
│   │       ├── mscmp_syst_mcp_perms
│   │       ├── mscmp_syst_perms
│   │       ├── mscmp_syst_session
│   │       └── mscmp_syst_settings
│   └── subsystems
│       ├── mssub_bms
│       └── mssub_mcp
├── documentation
│   ├── book
│   └── technical
│       ├── app_server
│       │   ├── mscmp_syst_authn
│       │   ├── mscmp_syst_db
│       │   ├── mscmp_syst_enums
│       │   ├── mscmp_syst_error
│       │   ├── mscmp_syst_forms
│       │   ├── mscmp_syst_instance
│       │   ├── mscmp_syst_limiter
│       │   ├── mscmp_syst_mcp_perms
│       │   ├── mscmp_syst_options
│       │   ├── mscmp_syst_perms
│       │   ├── mscmp_syst_session
│       │   ├── mscmp_syst_settings
│       │   ├── mscmp_syst_utils
│       │   └── mssub_mcp
│       └── database
│           ├── mssub_bms
│           └── mssub_mcp
└── tools
    ├── build_tools
    └── database_scripts
```

## Top Level Directory Description

Here we describe the general organization of the top level directories which provide the fundamental organization of the MuseBMS source code.

### __`app_server`__

The directory which contains the Elixir Projects and related source code.  These are organized into "[MuseBMS Component Model](/technical/high-level-architecture/#the-musebms-component-model)" related directories.

  * __`components/application`__

    Component Elixir Projects which define business domain related logic.  For example a product pricing related Component would be an Application Component.

  * __`components/system`__

    Component Elixir Projects which define system support related logic. These kinds of components will address subjects such as database management or authentication.

  * __`platform`__

    The Platform Elixir/Phoenix Project which defines web and external API interfaces (user interfaces collectively) as well as provides the logic to translate user interface interactions to the application business logic.

  * __`subsystems`__

    The Subsystem related Elixir Projects which encapsulate business logic into complete applications, sans user interfaces.

### __`database`__

This directory contains database source files which define the schema, functions and procedures, and any seed data which will be built into migrations by the [MscmpSystDb](/documentation/technical/app_server/mscmp_syst_db) migrator. Sub-directory structure generally follows the "[MuseBMS Component Model](/technical/high-level-architecture/#the-musebms-component-model)", with some exception.  Finally, these directories will also contain data and functionality which are used in support of application unit and integration tests as the tests require.

  * __`all`__

    Common or generally applicable database schema, functions/procedures, and extensions which aren't specific to any one Component or Subsystem.

  * __`components/application`__

    For each Elixir Project Application Component that defines database schema or functions/procedures, a corresponding `database/components/application` directory containing database source code will exist.

  * __`components/system`__

    For each Elixir Project System Component that defines database schema or functions/procedures, a corresponding `database/components/system` directory containing database source code will exist.

  * __`subsystems`__

    The database related source for the subsystems concerns itself chiefly with testing related support and migration building; the working database schema files are generally defined at the Component level even though migration building is a Subsystem level concern.

### __`documentation`__

Contains the source of all the MuseBMS documentation.  Different documentation authoring or generation tools may be
used as appropriate for the specific subject matter of the documentation.

  * __`book`__

    The primary technical and end user documentation of the application built using the <a href="https://gohugo.io" target="_blank">Hugo</a> static site generator in conjunction with the <a href="https://www.docsy.dev" target="_blank">Docsy</a> documentation theme for Hugo.  The document you are currently reading is part of this documentation.

    Ultimately this documentation is published independently via the Muse Systems website and is also included in the MuseBMS software release to support all online documentation scenarios.

  * __`technical/app_server`__

    This documentation is primarily aimed at documenting the APIs of the various Elixir components used throughout the application, though there is a fair amount of conceptual documentation when those components depend on a specific conceptual understand of the application logic.

    This documentation is generated from the Elixir source code commentary using Elixir's <a href="https://hexdocs.pm/ex_doc/readme.html" target="_blank">ExDoc</a>.

    This documentation is also imported into the `book` to support technical documentation references from documentation written there.

  * __`technical/database`__

    Database documentation is generated directly from the database using the <a href="https://schemaspy.org" target="_blank">SchemaSpy</a> tool.  Aside from introspecting the database schema, substantial amounts of database related explanatory documentation is drawn from database defined comments which are applied to the various database objects.  This means that substantial database documentation is drawn directly from the database source code files.

    While the Component level Elixir code is fully documented, the database documentation is currently only generated at the Subsystem level.  This avoids certain redundancies in documentation since many Components have common dependencies which would be included in the documentation for each dependent Component.  The Subsystem is a complete expression of an application and is therefore best suited to express the complete set of data relationships the application will depend on.

    This documentation is imported into the `book` to support technical documentation references from the documentation written there.

### __`tools`__

The tools directory is intended to contain useful tools for building, testing, and to generally aid in the development of the system.

{{< alert title="About the Tools" color="warning" >}}
The current condition of these tools are not in any sense "release quality"... in design or implementation.  Currently they are very specific to the ad hoc and manual needs of a single developer.  Some insights might be gained from looking at the contents, but such an effort may just be a waste of time.  You've been warned.
{{< /alert >}}