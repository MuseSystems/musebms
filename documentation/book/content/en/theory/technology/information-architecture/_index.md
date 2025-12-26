+++
title = "Information Architecture"
linkTitle = "Information Architecture"
description = """
For many applications, information architecture and data modelling is limited to providing the
application logic a means of robust persistence.  Thus the design of the information architecture
is driven purely by application logic and programming concerns.  However for effective business
management systems of the class we are concerned with, we must assume that the data is valuable in
its own right and carries uses beyond the simple transaction processing logic of the system."""

draft = false

weight = 10
+++

Data is a first class concern for our overall approach to business management system design.  We
predicate this elevation of importance on the following assumptions:

  * The business management system database will be the system of record for the majority of
    material business records.  This may be on a company, divisional, or departmental basis.

  * Third party applications will need to consume data and may produce data which properly is
    recorded in the system of record database.  There may be many such applications.

  * We expect that the third party reporting and business intelligence tools will be used to
    provide specialized presentations and insights into the data.

  * The business management system we build may be subordinate to more fundamental business
    management system which acts as the system of record.  This will likely be true if our
    application is only supporting a division or department of a larger organization.

In all of these cases we're describing scenarios where our business management system is planned
to be part of a larger ecosystem of collaborating applications.  This is called the
"best-of-breed" approach to business systems architecture and is common feature of enterprise
applications deployments.

