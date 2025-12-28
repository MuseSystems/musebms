+++
title = "Entity/Entity Relationships"
linkTitle = "Entity/Entity Relationships"
description = """
Business Relationships of various kinds can be formed between two Entities.  These Relationships
define how the Entities interact in different contexts."""

draft = false

weight = 60
+++

Entity to Entity Relationships, individually, are directional meaning that the "first party
Entity" has a specific, but different role in the Relationship as compared to the role of the
"external Entity".  These roles are not reversible and therefore we say the Relationship is
directional.

## Relationship Kinds

There are many ways to divide Relationships into categories of like kinds, but for our purposes
we'll define the top level of Entity/Entity Relationship kinds as follows:

### Sales

A Relationship where the first party Entity is the seller and the external Entity is the customer
in sales related transactions.

  * __Subordinate Relationships__

      * Accounts Receivable

  * __Person Roles__

      * Fulfillment Recipient

      * Accounts Receivable

      * Customer Agent

### Purchasing

A Relationship where the first party Entity is the buyer and the external Entity is the vendor in
purchasing transactions.

  * __Subordinate Relationships__

    * Accounts Payable

  * __Person Roles__

    * Accounts Payable

    * Account Manager/Sales Representative

    * Shipping

### Employment

A directional Relationship where the first party Entity is the employer and the external Entity is
the employee/contractor/etc.  In this case the external Entity is also an individual person.

  * __Person Roles__

    * Emergency Contact

### Banking

A directional Relationship where the first party Entity is the consumer of banking services and
the external Entity is a bank, lending institution, brokerage, etc. Banking Relationships are
usually used to facilitate the creation of banking related ledger accounts rather than to
facilitate the processing of specific transactions.

  * __Person Roles__

    * Account Manager

    * Payments

    * Receipts

    * Support

### Ledger

A directional Relationship where the first party Entity is a parent company and the "external
Entity" is a subsidiary company such that the subsidiary financials are consolidated into the
financial reporting of the parent Entity.

### Tax Authority

A Relationship where the first party Entity is the tax payer and the external Entity is the
government agency to whom taxes are paid.

  * __Person Roles__

    * Remittances

    * Support
