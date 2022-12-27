# MscmpSystPerms - Permissions System Foundation

Provides a generalized foundation for user permission system
implementations.

The principle idea of this component is to organization permissions in a way
that higher level components can introduce the concept of user and
establish contexts of applicability while keeping a cohesion in permissioning
capability.  To this end this component provides the core concepts for use in
any permissioning system using this ecosystem of components.

## Concepts

Below are the concepts used in formulating the functional design of this
component.  While these concepts are generally applicable it's worth keeping
in mind that any specific implementation of these concepts in an application
will have its own nuance and details that will have to be understood to properly
use the permissions of the system.

#### Rights

A Right is defined as the general ability to perform an action in the system.
There are a small handful of Rights:

  * "__View Right__" - the ability of a user to see data. For users lacking this
  Right for a certain data element, the element will either be presented as an
  empty field or hidden altogether.  The View Right must always be at
  least equal to or more expansive than the "Maintenance Right" defined below.

  * "__Maintenance Right__" - the ability to perform data maintenance specifically
  maintaining (editing) pre-existing data.  This Right does not include the
  idea of being able to create new records or deleting existing records; just
  changing existing records.

  * "__Administrative Right__" - the ability to perform data administration which is
  the ability to create or destroy data.  While it is typical for Administrative
  Right holders to also be granted similar Maintenance Rights, it is not
  implicitly so and there are some circumstances where it can be desirable for
  these two rights to not be equal.

  * "__Operations Right__" - whereas the previous Rights all concern being able to
  view or manipulate data, the Operations Right expresses the ability to perform
  system operations or processes.  Such an operation might be logging into the
  system, scheduling a job, starting some expensive process, or launching an
  integration job to a third party platform.  The operation or process will
  naturally likely be working with system data, but the user is not directly
  doing so and as such data related rights are not necessarily required to
  exercise a granted Operations Right.

#### Scopes

Scopes define the extent to which a granted Right applies.  For example, a user
being given View Rights to a document such as a Sales Order may be allowed to
view all Sales Orders in the system or they may be limited to those Sales Orders
for which they are designated as the "owner".  Scope is the mechanism which
allows the View to be fine tuned in that way.

Similar to Rights, a small number of Scopes are available for use:

  * "__Deny__" - the Right is not actually granted to the user but instead is
  explicitly denied to the user.  The use of the Deny Scope will become clearer
  when we discuss Permissions and Permission Role Grants.

  * "__Same User__" - the Right is limited to the current user exercising the Right.
  This is the case from the section summary example can only view their own
  Sales Orders. The Right does not extend to data owned by other users.

  * "__Same Group__" - the Right is limited to data belonging to a group or
  organizational designation to which the user is also assigned.  The details of
  group membership/designation will be specific to the implementation but the
  concept of a group based limitation of Rights is supported by this Scope.

  * "__All__" - the Right grant permits access to all applicable data or operations
  without additional limitation.  From the summary example this is the case
  where the user can see all Sales Orders.

  * "__Unused__" - is a special scope which indicates that a Right is not applicable
  to any grants in question.  The use of the Unused Scope will become clearer
  when we discuss Permissions and Permission Role Grants.

#### Permission Functional Types

Permission Functional Types provide a grouping mechanism for Permissions and
Permission Roles (discussed below).  The idea here is that an application may
define different applicability contexts for the permissions of the system.
Consider an application which supports business operations and inventory
management across multiple warehouses.  A permission such as one that grants an
employee the right to log into the system might have a "global" reach (there's
only one system) but having permission to process inventory transactions may be
specific to each warehouse, a "warehouse" reach.  The application could
accommodate this by implementing a "Global" Permission Functional Type to
include all those permissions which are global in nature and a "Warehouse"
Permission Functional Type to include all permissions which are granted
warehouse by warehouse.

Permission Functional Types are deeply tied to the implementation of application
functionality and as such they are for the most part not end user configurable.
The exception to this are the user interface representations such as the display
name and description fields.

This concept is conveyed via the `Msdata.SystPermFunctionalTypes` struct.

#### Permissions

A Permission defines the specific data point, application document, or operation
for which Rights may be granted.  For all Rights a Permission will define the
available Scopes which may be granted; this means that any given Permission may
offer all Scopes or some subset of them for a given Right.

If a Permission's functional use doesn't include a specific Right, the only
available Scope for the irrelevant Right will be the special "Unused" Scope.
For example a Permission for logging into the system doesn't include the concept
of viewing data, logging in is only an "Operation"; so the login Permission will
make the "Unused" Scope the only available scope for its View Right.

Because a Permission's functional use may include multiple Rights and it may
only be appropriate to grant some of the of those Rights to the user, a
Permission may include the Scope of "Deny" as an available Scope.  An example of
this would be viewing certain documents; it might be appropriate to grant a user
read only access to all Purchase Orders in the system.  In this case a Purchase
Order Document Permission grant to the user would use the "All" Scope for the
View Right, but would set the Maintenance and Administration Rights of that
permission to "Deny".  Since the Purchase Order Document Permission is for all
rights pertaining to Purchase Order Documents, we need that ability to
selectively deny permission.

This concept is conveyed via the `Msdata.SystPermFuncs` struct.

#### Permission Roles

Permission Roles allow for the grouping of specific Permissions and the specific
grants of Rights.  These Permission Roles are then the assigned to system users,
giving these users the collective Rights of their assigned Permission Roles.
Note that Permission Roles are intended to be additive; this means that if a
two Permission Roles are granted to a user, an one Role gives the user view only
access to Sales Orders but the other Role gives the user both Maintenance and
Administrative Rights to Sales Orders, the Role which gives Maintenance and
Administrative Rights will be the effective Role for that Permission.  Its the
greatest of grants from each granted Permission Roles which wins.

Permission Roles may be system defined, which means they cannot be changed
except for their user interface presentation elements.  This component also
supports arbitrarily defined user Permission Roles as user security policy
dictates as appropriate.

A Permission Role is defined for a specific Permission Functional Type which
becomes important to the Permission Role's child Permission Role Grants.  In
essence this means that a single Permission Role may not span the application
defined Permission Functional Type boundaries when granting Permissions to
users.

#### Permission Role Grants

A child of the Permission Role, a single Permission Role Grant grants a single
Permission and defines the specific Scope for each of the Rights from the
available Scopes defined by the Permission itself.

Only Permissions which share the same Permission Functional Type as the parent
Permission Role may be granted using the Permission Role Grants.  This ensures
that each Permission Role functions which a cohesive application context.

Permission Role Grants assume the system defined status of their parent
Permission Role.  If the parent Permission Role is system defined then the
Permission Role Grant may not be changed or deleted nor may new Permission Role
Grant records be created for that Permission Role.  User defined Permission Role
parents allow editing Scope assignments to Rights and the addition and removal
of Permission Role Grant records.

Naturally, only a single Permission Role Grant record for exist for any
combination of Permission Role and Permission records.

## A Basis for Permissions

As has been stated before, this component provides the basic concepts of what it
means to have Permissions in an application and the general aspects of
implementing these concepts.  Notably absent is what constitutes a "user", how
contexts of applicability are established, or implementations of permission
checks.

The thinking in this regard is that higher level components or applications
themselves will use MscmpSystPerms as a library providing basic Permissions data
management while providing implementations for users, Permission Role assignment
to those users in their correct contexts, and necessarily building on those next
steps the actual evaluation of whether or not a user has a permission to do
something in the system.

One recommendation for implementing applications is that the Permission Role
assignment to users should be the exclusive mechanism for granting Permission
Rights; what we mean by this is that Permission specific, one-off grants to
users are to be avoided.  From a user security perspective it becomes difficult
to consistently manage two paths for granting authority in the system,
especially if one of those paths is genuinely exceptional.  One-off revocations
of Permissions Rights from specific individual users is acceptable, however,
because the its immediately apparent to the user when user maintenance has
overlooked the removal of a one-off revocations (the user can't dont something
they expect to be able to do).
