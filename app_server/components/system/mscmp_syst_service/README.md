# MscmpSystService - Baseline Service Behaviour & Implementaions

<!-- MDOC !-->

Establishes a Behaviour and common system or instance service patterns for the
application.

A number of persistent services are needed to successfully run the Muse Systems
Business Management system.  Many of these services may also need to be started
and run on a per-Instance basis and will thus have many of the same service
selection requirements between different services.  This module establishes the
common patterns that individual services should implement.

<!-- MDESC !-->

For the most part, this Component establishes a Behaviour that other service
defining Components should implement.  This ensures that any such services can
be more readily comprehended as they will implement common service patterns
across the application.

To implement this behaviour into a new Service, simply add the
`use MscmpSystService` directive to the top of the Public API module
implementing the interface.

> #### `use MscmpSystService` {: .info}
>
> When `use MscmpSystService` is called with the required options, it:
>
>   1. Adds the `MscmpSystService` as a module behaviour.
>
>   2. Adds the `@service_option_defs` module attribute to the module.
>      This attribute provides the NimbleOptions schema for standard GenServer
>      start options which are passed through to backing GenServer, assuming the
>      Service is backed by a GenServer.  Whether any given Service makes use of
>      these options is entirely up to the Service implementation.
>
>   3. Adds the `@service_option_selections` module attribute to the module.
>      This attribute provides a pre-assembled list of the NimbleOptions
>      selections for the standard GenServer starting options listed above.
