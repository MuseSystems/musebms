+++
title = "Entity/Entity Relationships"
linkTitle = "Entity/Entity Relationships"
description = """
Business Relationships of various kinds can be formed between two Entities.  These Relationships
define how the Entities interact in different contexts."""

draft = true

weight = 60
+++
## Relationship Kinds

There are many ways to divide Relationships into categories of like kinds, but for our purposes
we'll define the top level of Entity Relationship kinds as follows:

  * __Sales__

    A directional Relationship where the first party Entity is the seller and the external Entity
    is the customer in sales related transactions.

  * __Purchasing__

    A directional Relationship where the first party Entity is the buyer and the external Entity
    is the vendor in purchasing transactions.

  * __Employment__

    A directional Relationship where the first party Entity is the employer and the external
    Entity is the employee/contractor/etc.  In this case the external Entity is also an individual
    person.

  * __Banking__

    A directional Relationship where the first party Entity is the consumer of banking services
    and the external Entity is a bank, lending institution, brokerage, etc. Banking Relationships
    are usually used to facilitate the creation of banking related ledger accounts rather than to
    facilitate the processing of specific transactions.

  * __Ledger__

    A directional Relationship where the first party Entity is a parent company and the "external
    Entity" is a subsidiary company such that the subsidiary financials are consolidated into the
    financial reporting of the parent Entity.

## Simultaneous Relationships

Two Entities may have multiple, concurrent Relationships with each other, including multiple
Relationships of the same kind.  Some example scenarios include:

  * An Entity may simultaneously have a Sales Relationship with an external Entity in some
    transactions while having a Purchasing Relationship with the same external Entity in other
    transactions.

  * An external Entity representing a large company or organization may have divisional or
    departmental purchasing organizations which act fully independently.  Each of these divisional
    purchasing organizations may also have their own, independent Sales Relationship with the
    first party Entity as the terms, conditions, and people involved in transactions may vary
    across the external Entity's divisions.