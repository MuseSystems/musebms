+++
title = "Business Relationships"
linkTitle = "Business Relationships"
description = """
The modelling of business relationships has evolved over time, moving from rather simple and naive
ideas to more correct representations of real world business relationships.  Here we examine this
history and establish"""

draft = false

weight = 20
+++
## Historical Perspective

When working within a company, it is not uncommon to think about "our customers", "our vendors",
"our partners", and "our employees" as though these are specific kinds of distinct entities.
However these terms are not describing classes of entities, but are describing relationships that
exist between two entities, our company (an Entity in its own right) and the external party.  This
distinction between thinking of a "customer" as an entity vs. thinking of the "customer" as a
relationship is subtle, but appreciating the nuance of the distinction can lead to important
insights in how we might build business management systems.

Understanding the history of modelling business relationships can inform our approach to Business
Relationships and allow for capabilities which more representative models bring.

{{< alert title="Speculative, Generalized Content Ahead" color="warning" >}}
This following description of business relationship modelling over time has not been formally
researched and is purely anecdotal.

In addition, the description of historic systems and current systems is very generalized.  There
are many, and have been many, business systems in existence and each one with its own
individualized approach modelling business relationship management.

In both cases, what is written below is the author's experience of working with a variety of
business systems over a substantial length of time in a wide variety of scenarios.  While
the generalized trends and practices described below are informed by reality, they may depend too
much on the author's own direct experiences and assumptions and thus be limited thereby.
{{< /alert >}}

### Early Models

Many early business management systems were designed using the naive, but common sense approach of
representing customers, vendors, etc. as specific kinds of entities.  These systems would
implement each kind of entity with different kinds of records (tables) in the system:

<img class="center-block" width="720px" src="/theory/technology/information-architecture/early_brm_info_arch.svg" alt="Early BRM Information Architecture">

This works well enough in most cases, but the real world is more complicated than this model
allows.  For example a single external company may be a customer in some transactions, but also a
vendor in others.

Under the early business systems model you would have to create two records to handle a situation
like the example just discussed, one for the external company as customer and one for it as
vendor; including duplicating all of the common attributes such as company name, addresses, etc.
But maintenance of duplicated data is only one of the practical issues that arises out of this
model.  Representing single, external companies with multiple, unrelated records in the business
system also partitions the knowledge of the complete relationship with the external company.  The
only way to create the complete picture in a such a system is to know outside of the system that
the relationship with the external company is multi-faceted and to run independent (or specially
constructed) reports to combine outside of the system.

### Recent Models

While these complex relationships with external companies are not the most common scenario, they
happen frequently enough that business systems evolved an improved model of business
relationships.  The updated model represents the external company as an
[Entity]({{< ref "theory/business-relationships/entity" >}}) in the same sense that we defined in
the [Business Relationships]({{< ref "business-relationships" >}}) section while associating it
with a record which represents the relationship:

<img class="mx-5 d-block" width="350px" src="/theory/technology/information-architecture/later_brm_info_arch.svg" alt="Later BRM Information Architecture">

This recent model much more closely matches the reality of business relationships found in the
real world and is probably the most common model adopted by currently popular business systems.

Many older business systems which were originally designed using the early model simply tacked on
the "Entity" record type and linked it to the preexisting records representing entity classes. In
these cases the business system typically only allows a single customer/vendor/etc. relationship
to be defined for any single Entity.  However in practice, though rare, there exist scenarios
where a single, large external Entity can have multiple, simultaneously active Relationships of
the same kind with the first party Entity; this happens when the corporate structure of the
external Entity is organized into substantially independent divisions or departments.  This forces
the users of these systems to create Entities representing the divisions/departments
independently; naturally incurring the cost that a full view of the Entity is effectively broken.

Indeed, while the more recent models of business relationship data do reflect real world realities
of this data better, they still fail to model the most advanced scenarios and extended business
organizations which are seen in practice.  This weakness stems from an implicit assumption in the
recent models that ideas such as customer or vendor are simply an extension of the Entity's
description: the Entity "is a" customer, the Entity "is a" vendor.  While better than the old
model where the customer/vendor/etc. ideas represented completely different entities, the recent
models still fail to appreciate what we're actually modelling.

## Our Approach

The reason the recent models described above succeed as well as they do is that the model isn't
wrong, it's merely incomplete.  Properly understood, the recent model is not describing an Entity
with its extensions into more topically focused descriptions where needed, it's really modelling
an Entity which has different Relationships with an implied, unmodelled Entity: the first party
Entity or "us".

<img class="mx-5 d-block" width="550px" src="/theory/technology/information-architecture/later_implicit_brm_info_arch.svg" alt="Later Implicit BRM Information Architecture">

By recognizing and being mindful that we are modelling Entities and the Relationships between
them, and making that explicit in the data modelling, we can avoid the limitations of assuming too
many facts about reality.

### Explicit Model

Our basic modelling technique makes the complete Relationship picture explicit in the data model.

<img class="mx-5 d-block" width="550px" src="/theory/technology/information-architecture/final_brm_info_arch.svg" alt="Final BRM Information Architecture">

However, because we are not assuming an implicit Entity "us", we can model relationships between
arbitrary Entities.  This becomes useful when we want to use our business system to manage the
businesses of multiple Entities.  For example, consider a company with subsidiaries; each
subsidiary may operate with significant independence, yet each subsidiary's financials are
consolidated with the parent company and may act as a group in some scenarios, such as purchasing.
In cases such as that, being able to explicitly model Entity/Entity Relationships allows the use
of the same business system for management activities across the conglomerate while also allowing
independence where needed.  This same-system/independent-existence property of our model can
facilitate other business structures, but those will be discussed elsewhere.
