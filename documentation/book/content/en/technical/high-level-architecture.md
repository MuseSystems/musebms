+++
title = "High Level Architecture"
linkTitle = "High Level Architecture"
description = "This section describes the highest level concepts used to organize the software."

draft = true

weight = 10
+++

## Foundational Ideas

The MuseBMS is built somewhat differently than most Elixir/Phoenix based applications.  In the typical Elixir/Phoenix development model, the application is built as a monolith with the database schema, business logic, external APIs, and user interfaces all developed within a single Phoenix application.  Naturally in the better examples of these kinds of applications there are boundaries and separations of concerns, but these are primarily matters of developer practice rather than strict, technically enforced boundaries.  The MuseBMS does not follow this typical model.

The MuseBMS is structured as many small Elixir Projects which are dedicated to narrowly defined and specific scopes of functionality.  In many ways, these small Elixir Projects look and behave like typical Elixir libraries.  They are independently testable, they offer well defined APIs, and they could be reused in different business system scenarios.  This model of development was inspired by <a href="https://pragdave.me" target="_blank">Dave Thomas</a>'s <a href="https://pragdave.me/thoughts/active/2017-07-13-decoupling-interface-and-implementation-in-elixir.html" target="_blank">ideas</a> and <a href="https://github.com/pragdave/component" target="_blank">work</a>.

In terms of trade-offs between the conventional Elixir/Phoenix model and the model we adopt here, our sense is that we
gain:

  * Clearer, technically enforced boundaries between different features and functions including a strict isolation of internal logic.

  * Greater chance of building re-usable components for use in other projects we may undertake.

  * Increased safety during refactoring or maintenance related efforts.

  * Greater ease in swapping out feature/functionality implementations with new implementations.

However we buy those gains with the cost of:

  * Increased boiler-plate code and repetitive configuration to maintain since each component is an Elixir project.

  * Increased time identifying the correct feature/function boundaries.

  * Increased indirection as different layers of the system expose or re-expose lower level Component functionality.

  * Time lost explaining our unique project organization to Elixir developers otherwise well versed in more conventional Elixir development.

In the end, we obviously consider the gains of this unconventional approach greater than the costs, at least for the MuseBMS. For some costs such as increased boiler-plate code, there are automated solutions which can mitigate the negative impacts.  While increased time and consideration of identifying correct boundaries is listed as a negative, in many ways the forcing of that practice also is a positive since it discourages deferring some more difficult questions which could be more costly to address later in the process.

## The MuseBMS Component Model

The MuseBMS software is organized into three different levels of abstractions:

### Components

These are Elixir Projects which are base level implementations of basic functionality out of which higher level parts of the application are constructed.  Some Components are simpler (lower level Components) and some Components can be more complex (higher level Components), even depending on other lower level Components.  In all cases the key is that all the features implemented by a single component are all closely related to a single idea at the core of the component: these are the building blocks out which our other levels of abstraction are built.

Typically, Components should be used to encapsulate logic or define services which can then be used by higher level abstractions.  For example a Component may define a GenServer or a Supervision Tree, but the Component should not itself instantiate those pieces as running processes; consumers of the Component, typically Subsystems, should be responsible for managing those runtime concerns.

### Subsystems

At this level of implementation we are combining many of our Components together into a complete implementation of what we'd call an "application" (as opposed to an Elixir Project) with the exception of user interfaces.  The stitching together of Components into complete, and possibly complex, chains of business logic operations is our concern here.  At this level we're expecting to cross the boundaries of single functional ideas and instead are interested in building the most efficient end-to-end business operations.

As with Components, Subsystems are implemented as independent Elixir Projects including their own test suites, documentation, and well defined APIs.  Unlike Components, Subsystems are only allowed to depend on Components; they should never depend on other Subsystems and in most cases Subsystems should not depend on third party libraries either as doing so would suggest that there is a missing Component.  The expectation is there will be many fewer Subsystems created than Components.

Finally this is the level at which most runtime concerns will exist.  A Subsystem will typically be responsible for starting and supervising any required services defined by its dependencies.  Exceptions to this rule chiefly deal with web and API interfaces provided by the Phoenix framework and managed at the Platform level.

### Platforms

This is the implementation layer in which we use the Phoenix Framework to deliver web interfaces and external APIs to users of the application in addition to hosting the runtime services of the various hosted applications.  The Platform depends on our different application Subsystems to incorporate core business logic, but the platform provides the logic responsible to connecting the web interface/API to the business logic.

The Platform level is designed to host multiple distinct user applications.  Currently there are two applications expected to be hosted on the platform: 1) a central application responsible for administration of the platform as a whole including the creation and maintenance of instances of the other applications available in the Platform and authentication; 2) the MuseBMS application itself.  It is conceivable that other applications could also be supported alongside MuseBMS, such as specialized versions of the MuseBMS dedicated to specific industrial verticals.

There are substantial third party dependencies due to the nature of Phoenix Framework, but of our logic we should only be depending on the created Subsystems as dependencies; note there are a couple exceptions to this rule, for example the web form components are implemented as a Component level Elixir/OTP Application (<a href="/musebms/technical/system-components-list/#mscmpsystforms">MscmpSystForms</a>) and that Component is directly depended on by the Platform.

It is expected that there will only be one Platform level Elixir Application, though that Application may have different release profiles depending on which Subsystems are to be released to the final user.

{{< alert title="Note" color="info" >}}
We try to use language, terminology, and other jargon in consistent ways but this isn't always possible.  In this document we'll be reusing some terms we have given specific meanings to in their more general forms.  For example, we use "Component" to refer to a specific level of software abstraction, but we'll also use "components" generically to refer to the code units of all levels of abstraction collectively.  We have similar issues with "Application" which can mean specifically an Elixir/OTP Application or simply the MuseBMS application which is a collection of Elixir/OPT Applications and components.  Hopefully the usage context and our use of capitalization for jargon terms and lower case for generalized usage will make it clear which meaning should be assumed.
{{< /alert >}}

## Database Handling and the Component Model

Another of our departures from typical Elixir/Phoenix related software development is that we do not use Ecto migrations for database deployment, but rather use our own database management Component (<a href="/musebms/technical/system-components-list/#mscmpsystdb">MscmpSystDb</a>) for managing and deploying the database related code.

As it relates to our levels of abstraction, the Component level is where the database schemas for persistence and other required database support is defined.  Migrations are built and deployed at the Subsystem level; all of the database sources of the Subsystem's dependencies are incorporated into the migrations of the Subsystem and at runtime the Subsystem will ensure that any unapplied migrations required by that Subsystem are applied as needed.

Currently, the database Component's migration builder expects all of the database source code to live in a dedicated database source tree.  Each Component that defines database code will therefore not only have an Elixir Project defining its application code, but will also have a corresponding directory in the database source tree as well.  The details of source code organization will be addressed elsewhere.
