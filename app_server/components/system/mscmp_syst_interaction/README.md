# MscmpSystInteraction - Data Maintenance State Management

<!-- MDOC !-->

A framework for mediating user interactions with business data including editing
controls, data caching, and establishing authorization requirements.

Starting with the premise that single records may be subject to concurrent read
and modification access by multiple actors and therefore require active
management. This prevents unexpected or unwanted data states and avoids
unnecessary database reads of data already in application memory.  The
`MscmpSystInteraction` Component provides a framework of services and an API for
data caching and enforcement of data maintenance rules for interested actors.
Specifically we set out the following capabilities:

  * Provide a data caching service that loads data from the database once and
    serves the cached copy to all interested actors until interest expires.

  * Establish a locking mechanism which allows individual system actors to
    assume sole editing privileges.

  * Define data access privileges for specific interactions and categories of
    information while allowing granular field level privilege overrides.

<!-- MDESC !-->

While `MscmpSystInteraction` will be useful in many data maintenance activities,
it is not expected to be used for all data representations to a user.  For
example a user editing a sales order's payment terms in the system may be
presented with a view of the sales order header data, including the order's
terms as well as a list of the individual products being sold.  The sales order
header data would be managed by `MscmpSystInteraction`, but the list of products
would not likely be unless the user elected to maintain those as well and even
then each individual line would be handled as an individual interaction as
needed.  Assuming the items list is just informational, however, means that
managing that data via this framework as an interaction isn't necessary.

## Concepts

To accomplish our goals we set out a theory of interactions which is a theory of
how the user interacts with the system and its information. To more concretely
illustrate these concepts we'll use an example scenario of a user wanting to
work with their company's products in the system.

The conceptual definitions around which our theory is built are defined below:

#### Interactions

Central to our theory is the "Interaction".  If we assume that the user comes to
the system to achieve some business goal, we can expect that they come with
the intent to "interact" in some specific way, involving some specific set of
information.  The Interaction, as defined here, can be thought of as being more
about the action or task the user is wishing to accomplish and less about the
data or information involved in achieving the desired outcome; in this sense the
data is clearly in a supporting role rather than a primary one.

In our example scenario, creating a new product is an Interaction. The user
brings product information, enters it into the system, and commits it to the
catalog. The key insight is that the Interaction represents the *goal* (creating
the product) rather than the *data* being manipulated.

#### Interaction Contexts

The "Interaction Context" is the central idea around which our framework is
built.  When a user comes to Interact with the system, the Interaction Context
establishes the capabilities, limits, and activities which the user may perform.
Interaction Contexts are principally organized around the information or data
of the system and because of this different Interactions with that data may be
encompassed by the same Interaction Context.

More directly in our framework Interaction Contexts organize collections of
"Actions" and "Fields" (concepts which will be defined shortly), and implicitly
the data record at stake itself.

Looking to our model scenario, our Interaction Context would be "Product", and
would include all the data and activities (Interactions) we could perform on a
product record.  We could restate this by saying that the key data point,
product, establishes the context in which certain activities can be performed
and under which conditions.

#### Categories

To represent the idea of unified cross-cutting concerns in our data we introduce
the idea of "Categories".  Categories arise when common ideas apply across
different data records.  For example, unit cost information is a kind of data
which can appear in product records, inventory records, purchasing records, and
sales records but as a concept is itself a control point: someone that shouldn't
see unit cost in product records should also not see that unit cost as
represented in the sales order records.  In this example we want to establish
Categorical permission to access the unit cost data rather than specify that
permission on a record (Interaction Context) by record basis.

#### Actions

An "Action" is a specific application function that a user may invoke during an
Interaction.  Activity that results in, for example, a new product record being
added to the system might be a "Create Product" Action.  Naturally there may be
a number of application functions invoked during any given activity for that
activity to come to completion, so Action in this sense considers the granular
specific application functions to complete a specific functional goal as part of
the same Action.

Actions are closely related to Interactions, but narrower in scope. A user's
Interaction might be to "maintain a product record," but the application offers
specific Actions like "change_product_number" or "deactivate_product"—each
maintaining the product in a specific, limited way.

#### Fields

Interaction Contexts will typically have close affinity to specific data records
used in the system which means that privileges and limits at the Interaction
Context level will often apply to data records as a whole.  However, that record
level sameness of treatment will not always be appropriate to all data points.
"Fields" provide for the designation of alternative privileges or privilege
derivation over and above the limits established for the record generally.

As an example, a user wishing to interact with the system to change a product's
description will have authority to generally see and change the product master
data, but the product's last cost might also be available for the product; it is
not uncommon, however, for costing related data to be more highly privileged and
therefore that individual field shouldn't necessarily be available to the user
in our scenario. Treated as a Field in our Interaction Context, we can
designate, for example, that the unit cost Category permissions should be
applied instead for this one Field.

