+++
title = "Entity/Place Relationships"
linkTitle = "Entity/Place Relationships"
description = """
Places can have varied Relationships with Entities. Enity/Place Relationships describe the roles,
privileges, and responsibilities which an Entity has in regard to a specific place."""

draft = false

weight = 70
+++

Entity to Place Relationships may be recognized between any Entity and any Place. In fact, any one
Place may have Relationships with more than a single Entity. Consider the example of "third party
logistics", where the first party Entity may locate their inventory in an external Entity's
warehouse; in this case the warehouse is under management of the external Entity, but the first
party Entity owns, manages, ships/receives, and accounts for inventory at that warehouse.  Under
our model the warehouse is a single Place and the Relationships with different Entities inform our understanding of the complete picture.

## Relationship Kinds

Different kinds of Entity to Place Relationships inform us about which Entities have legal
responsibilities in regard to the place, the people we will find at the Place and why they are
there, and the tangible personal property that is stored at the place.

More formally we define this as:

### Management

This Relationship indicates that the Entity in the Relationship has a management responsibility
for the Place.  This Relationship may be indicative of the Entity being in an ownership role, as
the legal occupant, or merely having a facilities management responsibility for the Place.

  * __Subordinate Relationships__

    * Lessor (to [Purchasing Relationship](/theory/business-relationships/entity-entity/#purchasing))

    * Tenant (to [Sales Relationship](/theory/business-relationships/entity-entity/#sales))

### Staffing

The Entity in the Relationship will employ staff at this Place.  This kind of Relationship allows
the Entity to manage staffing levels, rules, and legal requirements related to employing staff at
the Place.

  * __Subordinate Relationships__

    * Staff Member (to [Employment Relationship](/theory/business-relationships/entity-entity/#employment))

### Inventory

The Entity in the Relationship will own units of inventory items at the Place. This kind of
Relationship implies a Place related boundary which may delineate financial inventory control,
inventory availability for use in manufacturing or directly consumed, or inventory available for
fulfillment needs.

It is plausible for Entities to have more than a single Inventory Relationship to any single
Place.  For example, the Entity may differentiate between units of items that have not been
inspected vs. those that have or the Entity may wish to segregate inventories available for
distribution, those available for consumer sales, or even rental inventories.
