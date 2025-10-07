# MscmpSystEnums - Enumerations Data & Service Management

<!-- MDOC !-->

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

<!-- MDESC !-->

## Concepts

Understanding the following concepts is required for effective use of this
Component.

### Enumerations (Enum)

The Enumeration identifies a specific list of values used in the system as well
as carrying configuration for the Enum.  Configuration points include
information about if a given Enum was created by the system developers ("System
Defined") or is a custom, user defined Enum and to what extent the Enum is
"User Maintainable".

### Functional Types

Enums may optionally have defined "Functional Types" which are intended for
cases where the Enum provides choices between differing system behaviors.  The
key idea is that the Functional Types are tightly coupled with the distinct
behaviors allowed by the system.  Functional types are then assigned to each of
the available list of value options so that when the user selects a value from
the list, they are also selecting a Functional Type which the option should
invoke.

For an example of Functional Type purpose, consider a system which enables
certain capabilities when a given master record is either "Active" or
"Inactive".  "Active" and "Inactive" would be the Functional Types recognized by
the system, but for the users of the application more nuanced categorization may
be desireable.  In this example, perhaps the users want to categorize "Inactive"
records by inactive for what reason (e.g. "In Progress", "Cancelled",
"Obsolete").  All of these values are for system behavioral purposes "Inactive"
but the extended information can help users understand why records have been
made "Inactive", perhaps establishing a more complex life-cycle of record
management.

If Functional Types have been defined for an Enum, each available value defined
for the Enum must also be mapped to one of the Enum's Functional Types.

### Enumeration Item (Enum Items)

These are the actual values which, when grouped together, define the available
values in the list of values which the Enum represents.  Enum Items
establish the text displayed to the user, whether the Enum Item itself is system
defined and/or user maintainable, and, if required by the Enum, what Functional
Type is associated with the Enum Item.

If a Functional Type assignment is required by the parent Enum, the multiplicity
of Enum Items to Functional Types is Zero or Many to One.  This means that the
system doesn't require that all defined Functional Types of an Enum be mapped to
an Enum Item and that many Enum Items can refer to the same Functional Type.

Being able to assign multiple Enum Items to the same Functional Type allows for
the fine grained information capture which might be desired for a particular
parent record while invoking the same system functionality for multiple options.

Naturally, if a Functional Type has no associated Enum Items defined, that
functionality will be unreachable by users of the application.  This can be a
desirable outcome in some business application scenarios.

## Technical Implementation

Enums, Functional Types, and Enum Items are persisted in the database so that
these configuration are durable.  When the application starts, all of the Enum
data is loaded into a GenServer backed ETS table.  Processes will read Enums
data directly from the ETS table as needed.  Changes to the Enums are not
directly written to the ETS table, but are processed by the GenServer which
ensures that the changes are updated in the ETS table, but are also persisted to
the database.

This design assumes that Enum data is read often, but changed infrequently.
