# MscmpSystInstance - Application Instance Management

API allowing for the management of application Instances.

"Instances" are instances of running application environments.  Instances are
established to host the application for different purposes, such as for
running the application for production, training, and testing purposes; or as
a means to implement multi-tenancy where each tenant application environment
is an Instance.

Each Instance also requires supporting data in order to facilitate runtime
actions, such as defining database roles with which to access database data.
Such supporting information is also managed via this component.

## Concepts

Instances are organized into a framework of other data types which allows us
to better analyze and manage them and provides supplemental information
required for Instance operation.

#### Datastores & Datastore Contexts

Each Instance is associated with a single Datastore.  A Datastore is the
database created to store the Instance's application data.  Datastore Contexts
are the database roles with which the Instance will access the database; this
allows for application database connections secured to an appropriate range
of actions and limited to an appropriate number of concurrent database
connections.  Or to put it another way, Datastore Contexts can be thought of
as "Database Access Contexts".

Datastore and Datastore Context management is provided by the
`MscmpSystDb` component.

#### Owners

Owners represent the known tenants of the system.  An Owner will own Instances
of Applications.  Owners have states which determine if they are active, not
active, or even if they may be purged from the system.

#### Applications

Each Instance is an operational instance of a specific Application.  An
Application is simply what an end user would understand to be application:
computer software which solves some problem for them better than could be
solved without such software.

Applications in this component are added and maintained directly via database
migrations therefore there is no API provided to manage applications and there
are no user maintainable Application attributes.

#### Application Contexts

Application Context records define the expected Datastore Context records that
must be created for each Instance.  Each Application Context will be
represent data ownership, data access restriction, and/or connection pool
resource constraint.  When created Instances will have its own database roles
created for each of the defined Application Contexts.

#### Instance Types

Instance Type records are used to define the default resource utilization
classes that are available for creating new Instances.  These defaults include
such starting values as the number of database connections to use for each
Application Context and which server pools may host the Instance.

After Instance creation, the Instance Type serves no further role for the
Instance.

Note that Instance Type records are a special case of the
`Msdata.SystEnumItems` record.  The Enum Name for Instance Type
is, unsurprisingly, `instance_types`.

#### Instance Type Applications

Establishes that a given Instance Type will support a particular Application.

#### Instance Type Contexts

Defines defaults used in creating Instance Context records at Instance
creation time.

When an association is made between an Instance Type and an Application via
a Instance Type Application association, a new Instance Type Context record is
created for the combination of the Instance Type and each of the Application's
defined Application Contexts.

At Instance creation time, the Instance Type Context defaults are copied
into Instance specific Instance Context records to define the actual database
roles which the instance will use to interact with the database.

Note that Instance Type Context records are automatically created and
destroyed via the creation of Instance Type Application records by way of
database triggers; therefore the only application API related to these
records is for updating them.

#### Instances

An Instance represents the single environment of a specific Application and a
specific Owner.  Instance records are used to know which database server to
connect to, what Instance Context records are used for connecting to the
database, and the current state of the Instance including whether or not it's
been updated with the Application database definition, is in a usable state,
or can be purged from the system.

#### Instance Contexts

An Instance's Instance Context records define specifically how an Instance
will connect to its Datastore including such information as how many
connections should be opened to the database.

Database triggers are responsible for creating and destroying Instance Context
records.  On creation, the Instance Context is created with default values
defined by Instance Type Context records for the type of Instance being
created.  The default values set on Instance Context creation may be
overridden via this API as desired.

## Special Notes

This component requires that an instance of the `MscmpSystEnums` service has
been configured and started.  Many of the API calls in this component will
fail if the `MscmpSystEnums` services are not available.
