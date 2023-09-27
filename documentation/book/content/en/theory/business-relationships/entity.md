+++
title = "Entity"
linkTitle = "Entity"
description = """
Entities are the legal entities such as a business’s customers, vendors, employees, partners, etc.
and who are the parties to transactions."""

draft = true

weight = 10
+++
## General

An Entity can be any organization, company, government, or individual which can legally enter into
a contract and with whom business is transacted.

Ideally, each relevant real world entity only has a single representation as an Entity.  Any
nuance or multiplicity of roles should be expressible via the Entity's
[Relationships]({{< ref "relationships" >}}).

## Individual Person as Entity

An individual, real world person may also be described as an Entity.  When this is the case the
individual will most often also be a [Person]({{< ref "person" >}}) with a Relationship to the
Entity indicating that the individual acts as their own agent.  Other People may be granted
Relationships to the Entity so that these others may act as agent on the Entity's behalf (lawyers,
assistants, family, etc.); it is even possible that the individual represented by the Entity does
not act as their own agent and therefore isn't recognized as a Person with a relationship to the
Entity, though this would be rare.

## Notes on Perspective

Throughout the Business Relationships section we'll be referring to different Entities from the
perspective of one working within a specific company or organization.  A "first party Entity" or
"primary Entity" therefore would be our company or organization and an "external Entity", "second
party Entity", or "third party Entity" would be some other Entity from our assumed perspective.
When we speak in terms of business systems, the first party Entity will be the one whose staff
would be using the system.