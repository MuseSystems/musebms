+++
title = "Relationships"
linkTitle = "Relationships"
description = """
Entities, People, and Places will have "Relationships" between them.  It is these Relationships
which provide us the richest information and carry the most interesting meaning within the subject
area of Business Relationship Management. The lists of Entities, People, and Places may identify
with whom we're dealing and where, but Relationships tell us why we care and what we should expect
for any business transaction."""

draft = true

weight = 40
+++
## General

For our purposes, a Relationship describes how any two Entities/People/Places interact with each
other during the conduct of business or for which recognition of the Relationship can aid in
performing analysis of business data.  In addition to the actors involved in a Relationship, we
also limit the scope of any single Relationship to some specific area of business concern or
purpose.

A well defined Relationship describes the terms, conditions, and understandings of the two parties
involved in the Relationship when transacting business in the subject area of the Relationship.

## Refined Definition

More specifically, a Relationship as defined in our model is the uni-directional Relationship of a
Subject to an Object.  A Subject is the first party Entity, Place, or Person.  The Object is the
second party Entity, Place, or Person. The Relationship between the Subject and Object indicates a
Relationship of a specific business nature or "kind". We can therefore say: the Subject has a
Relationship of a certain kind with the Object.

<img class="center-block" width="600px" src="/theory/business-relationships/subject_object.svg" alt="Basic Relationships">

Consider an example Relationship where "Our Co." sells products to "Their Co.".  In this
case "Our Co." would be the Subject (seller) , the Relationship in question would be a Sales
Relationship, and the Object (customer) in the Relationship would be "Their Co.".

<img class="center-block" width="600px" src="/theory/business-relationships/sales_subject_object.svg" alt="Sales Relationship Example">

We can see that both Subject and Object have well defined and distinct roles relative to the
Relationship.  It should also be obvious that even though "Our Co." sells products to "Their Co.",
it doesn't necessarily mean the reverse is true and thus the Relationship is uni-directional; if
"Their Co." also sold products to "Our Co.",  we would have to acknowledge that as a different
Relationship that was parallel to the Sales Relationship described above.

## Subordinate Relationships

Defined Relationships between Entities/People/Places can also act as either the Subject or Object
of a secondary or "Subordinate Relationship" in some cases.

To illustrate this let's consider a different hypothetical scenario where "Our Co." buys products
from "Their Co." This would constitute a Purchasing Relationship where the Relationship Subject
(buyer) is "Our Co." and "Their Co." is the Relationship Object (vendor).

<img class="center-block" width="600px" src="/theory/business-relationships/purch_subject_object.svg" alt="Purchasing Relationship Example">

For a variety of reasons, some businesses sell their accounts receivable to a kind of third party
company known as a "factoring company".  The factoring company will buy the accounts receivable of
the vendor at a discount, generally speaking, and then the factoring company receives the full
payment from the customer and accepts the risk of non-payment by the customer.

Let's extend our Purchasing Relationship scenario such that "Their Co." sells their accounts
receivable to "Collect Co.", a factoring company.  In this case, while "Our Co." will purchase
products from "Their Co." under the terms established by the Purchasing Relationship, when
"Our Co." pays the invoice for the product, they'll pay it to "Collect Co."

This is where the Subordinate Relationship exists.  The Purchasing Relationship itself now extends
to a third party for a narrow, but important  aspect of purchasing.  We can allow for this in our
model by defining a "Payables Relationship" between the Purchasing Relationship (Relationship
Subject) and the Entity "Collect Co." (Object Relationship).

<img class="center-block" width="600px" src="/theory/business-relationships/factor_subject_object.svg" alt="Payables Subordinate Relationship Example">

We wouldn't directly establish a Relationship between "Our Co." and "Collect Co." because the
Relationship is unique to the Purchasing Relationship between "Our Co." and "Their Co." and isn't
generalizable beyond that Purchasing Relationship, even if other "Our Co." vendors use the same
factoring company.

## Roles

So far we've discussed rich Relationships in which the description of the Relationship itself
requires us to specify the nature of the Relationship's terms, conditions, and understandings in
addition to recognizing that the Relationship exists.  But not all Relationships need to be
thought of in such detail.  Some Relationships are simple enough that we can just recognize that
the Relationship exists without greater embellishment.  In our mental model we'll use the term
Roles to refer to Relationships which are of this simple variety.

Most frequently Roles will relate Subjects made of Entities, Places, or rich Relationships to
People acting as Relationship Objects.  These Roles can be simple because their full meaning will
require contextual inferences from the Subject of the Role.  For Example, a Purchasing
Relationship may require us to know who our account manager is with our vendor.

<img class="center-block" width="600px" src="/theory/business-relationships/purch_roles.svg" alt="Purchasing Account Manager Example">

## Simultaneity

Because we limit the scope of our Relationship and Role definitions to a single purpose, we should
expect that between any two Subject/Object actors, that multiple Relationships may exist between
them at the same time.  Less common, but still feasible for some kinds of Relationships is the
possibility for more than one Relationship of the same kind to exist.

  * A Subject Entity may simultaneously have a Sales Relationship with an Object Entity in some
    transactions while having a Purchasing Relationship with the same Object Entity in other
    transactions.

  * An Object Entity representing a large company or organization may have divisional or
    departmental purchasing organizations which act fully independently.  Each of these divisional
    purchasing organizations may also have their own, independent Sales Relationship with the
    Subject Entity as the terms, conditions, and people involved in transactions may vary across
    the Object Entity's divisions.

