+++
title = "Subordinate Relationships"
linkTitle = "Subordinate Relationships"
description = """
The Relationships concept isn't limited to relationships between the "things" of our system, such
as Entity/Entity or Entity/Place Relationships.  Some Relationships act as the Subject of
a subordinate Relationship."""

draft = true

weight = 50
+++
Take an example from the Person Relationships section: Sales Relationship/Person.  In this case
we want to establish Person Relationships that are specific to and only have relevance for the
Sales Relationship between two Entities; we may want to know who the customer's buyers are, or who
we need to contact for support.  These Roles are only valid within the context of a specific Sales
Relationship.

More complex examples exist where the Subordinate Relationship is itself richer than that we
expect with a "Role".  Some of these examples include: