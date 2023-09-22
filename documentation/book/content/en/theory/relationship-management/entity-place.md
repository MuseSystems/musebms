+++
title = "Entity/Place Relationships"
linkTitle = "Entity/Place Relationships"
description = """
Places can have varied Relationships with Entities which govern the interactions that the Entity may have within the context of a given Place."""

draft = true

weight = 70
+++

## Relationship Kinds

Examples of Entity/Place Relationships include:

  * __Management__

    This Relationship indicates that the Entity in the Relationship has a management
    responsibility for the Place.  This Relationship may be indicative of the Entity being in an
    ownership role or merely having a facilities management responsibility for the Place.

  * __Staffing__

    The Entity in the Relationship will employ staff at this Place.  This kind of Relationship
    allows the Entity to manage staffing levels, rules, and legal requirements related to
    employing staff at the Place.

  * __Inventory__

    The Entity in the Relationship will own units of inventory items at the Place. This kind of
    Relationship implies a Place related boundary which may delineate financial inventory control,
    inventory availability for use in manufacturing or directly consumed, or inventory available
    for fulfillment needs.

    It is plausible for Entities to have more than a single Inventory Relationship to any single
    Place.  For example, the Entity may differentiate between units of items that have not been
    inspected vs. those that have or the Entity may wish to segregate inventories available for
    distribution vs. those available for consumer sales.

It's worth noting here that any one Place may have Relationships with more than a single Entity.
Consider the example of "third party logistics", where the first party Entity may locate their
inventory in an external Entity's warehouse; in this case the warehouse in under
management/ownership of the external Entity, but the first party Entity owns, manages,
ships/receives, and accounts for inventory at that warehouse.  Under our model the warehouse is a
single Place and the Relationships inform our understanding of how different Entities relate to
it.