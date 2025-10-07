# MuseBMS Build Library

<!-- MDOC !-->

MsbmsBuildLib is a comprehensive Elixir build utilities library that provides
automated build, test, documentation, and maintenance tasks for multi-component
projects within the Muse Systems Business Management System ecosystem.

<!-- MDESC !-->

## Overview

This library serves as a centralized toolset for managing complex,
multi-component projects that span both Elixir applications and database
schemas. It provides a unified interface through Mix tasks and programmatic APIs
to handle common development operations across multiple project components
simultaneously.

### Key Capabilities

  - **Multi-Component Build Management**: Coordinate build processes across
    multiple Elixir applications and libraries within a single project structure

  - **Database Operations**: Manage database cleaning, migration handling, and
    documentation generation for PostgreSQL-based components

  - **Documentation Generation**: Automated building of both Elixir (ExDoc) and
    database documentation with proper cross-referencing

  - **Development Environment Maintenance**: Clean and manage development
    artifacts including Language Server files, PLT caches, build directories,
    and dependencies

  - **Testing Coordination**: Execute test suites across multiple components
    with unified reporting and configuration

  - **Project Discovery**: Automatically discover and manage project components
    based on filesystem markers and conventions

The library is designed specifically for complex business management systems
where multiple interconnected components (applications, libraries, database
schemas) need to be developed, tested, and maintained as a cohesive unit while
preserving modular boundaries and independent deployment capabilities.