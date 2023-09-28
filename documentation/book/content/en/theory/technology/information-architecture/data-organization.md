+++
title = "Data Organization"
linkTitle = "Data Organization"
description = """
Business Management Systems often contain a large number of relations, often into the hundreds of
database tables, with some systems exceeding one thousand relations.  And while the number of
relations required to support the broad functional concerns of the typical business management
system can be large, this data can be generalized into a relatively small handful of categories of
data."""

draft = false

weight = 10
+++
## Principal Classifications

Most broadly speaking, our basic data breaks down into "business domain objects": the records defining customers,
products, warehouses, etc. which the application users maintain as needed; and "transactions" records: the recorded
actions which are taken by the business referencing the business domain objects.  We can refine these broad definitions
further.

### Master Data

Master Data are relations which enumerate business domain objects along with the attributes which configures each object
for use by the system.  The Master Data establishes the definition of the business domain object in the system.
Examples of Master Data include relations defining [Entities]({{< ref "theory/business-relationships/entity" >}}),
[Relationships]({{< ref "theory/business-relationships/relationships" >}}), and Products.

The primary trait of each Master Data record is that it represents information which is true "now", meaning in the
current moment.  If the business domain object represented by a Master Record changes, such as a customer changing its
mailing address, the Master Data record is changed to reflect the new reality so that at any given moment a Master Data
record represents the authoritative definition of the specific business domain object being described.  When the Master
Record changes, there is no sense of history kept; the record behaves as if the updated data was always the data.

Master Data records have life-cycle stages which determine how they can be used by the system.  These stages can be
generalized as:

  * __Preliminary Planning__

    In this stage the record exists, may be needed for certain longer range planning usage, but isn't available for
    regular transaction processing or reporting.  This life-cycle stage indicates future intention.

  * __Regular Use (Active)__

    Records in this stage are actively used in daily business activities and reporting.

  * __Obsolescence__

    Over time, some records will represent specific business domain objects which are planned to go out of use.  As that
    time approaches, certain transaction processing should cease (e.g. purchasing transactions), while others remain
    available as the Out of Use stage approaches.

  * __Out of Use (Inactive)__

    At the end of the Obsolescence stage, the record is not available for use in regular transaction processing.  The
    record will still be visible to business users as there is expected to be historical/reporting relevance.

  * __Purge Eligible__

    Once the record is no longer referenced by prior transaction histories, the record may become eligible to be deleted
    from the database outright.  It is important to reiterate that any existing transaction history referencing the
    record should prevent this stage from being reached to keep the data integral.

While all Master Data follows these general stages, any specific Master Data record or relation may only do so
informally within the business nor will the business management system always have well defined recognition of these
stages.  The business management system may provide alternative stage names, subdivide the stages, or allow the
definition of the recognized stages to be configured as suits the specific purpose at hand.  In all cases however, the
stages as listed are the functionally distinct stages which will matter during the course of executing application
logic.

Because Master Data records are reused during the course of multiple business activities, Master Data relations will
constitute significantly less of the overall application data retained when compared to other kinds of data.  Record
counts may be low, in the tens of records, but may commonly be in the thousands of records.  It is feasible, though
rare, for some Master Data relations to grow into the

### Supporting Data

Supporting Data relations carry records which exist to support other, more fundamental, kinds of data such Master Data
or Transaction Data.  Supporting data is Master Data-like in that the records also posses the Master Data primary trait
of being a representation of the present state of the Supporting Data.

Supporting Data comes in some basic sub-types:

  * __Simple Enumerations__

    Most (if not all) business management systems use "lists of values" to provide predefined acceptable values used by
    attributes in our primary data records.  Examples of these Simple Enumerations include, lists of available order
    statuses, approval process states, and product categorization.

    It is not uncommon for business management systems to allow many of these Simple Enumerations to be configured, as
    needed, by the user as current business requirements dictate.  While user management of Simple Enumerations suggests
    the possibility of life-cycle stages, most often the business management system mandates that all values existing
    as records of the Simple Enumeration are considered "Active" and the records are simply deleted when no longer of
    use.  Naturally, systems which recognize all existing records as "Active" should only allow for the deletion of
    Simple Enumeration records when such records are no longer referenced.

  * __Quantitative Data__

    For certain Master Data records, it can be convenient to track summarized Quantitative Data. Consider the simplified
    example of a Master Data relation defining products sold from a single warehouse.  While the Master Data records for
    a product will define the configuration of the product, there is also Quantitative Data such as how much quantity on
    hand of the product is currently present, the value of the product on hand, etc.

    Any one Quantitative Data record will always correspond to a single Master Data "parent" record.  This data could be
    stored in the same relation as the corresponding Master Data, and in some business management systems it is.
    However, there can be technical considerations for storing this quantitative data separately using Quantitative Data
    relations.  Quantitative Data tends to be updated much more frequently than the corresponding Master Data; this can
    give rise to lock contention in the database due to the competing uses.  In addition Quantitative Data usually
    consists of a small number of numeric fields taking much less space per row than the corresponding Master Data,
    which can have many more fields including text fields; since updating a row causes the copying of all row data, we
    can be more efficient by separating our frequently changing data from our infrequently changing data.

    Quantitative Data doesn't express any sort of life-cycle stages.  Any Quantitative Data record will assume the
    life-cycle stage of its corresponding Master Data parent record.

Supporting Data retention needs are of trivial concern in the broader context of the application data retained.


### Transaction Data

Transaction Data relations describe specific instances of business activity.  Examples of Transaction Data include sales
orders, order fulfillment and shipping, customer and vendor invoices, and customer support tickets. Transaction Data
records depend on Master Data and make use of Supporting Data to describe these business activities.

The primary trait of Transaction Data is that each Transaction Data record represents an instance of a business
activity which is finite in time.  While the business activity is underway, the Transaction Data records allow for the
coordination of the business operations required to execute the business activity.  Once the business activity is
concluded the Transaction Data acts as a historical reference as to what business operations were performed, to provide
data for later analysis, and the support the resolution of any later disputes that might arise related to the
performance of the business activity.

{{< alert title="Transaction Data Use of Master Data" color="warning">}}
The nature of Master Data is that it consists of long lived records which evolve over time to describe how business
domain objects exist "now".  The nature of Transaction Data, however, is to record business activities as they happened
at the time which means that once a business activity is concluded the Transaction Data record representing it is static
over time.

This disparity between the natures of Master Data and Transaction Data means that the Transaction Data records must
duplicate many of the attributes obtained from the Master Data, rather than rely on a foreign key reference to the
Master Data records.  This isn't to say that Transaction Data should not record foreign key references to Master Data
records, they should, but rather that such references are not sufficient to record transactions correctly.
{{< /alert >}}

Transaction Data has a generalized life-cycle consisting of the following stages:

  * __Preliminary Planning__

    During this stage, a Transaction Data record is being authored, awaiting approvals, or otherwise not yet actionable.
    During this time the Transaction Data record is not generally visible to business operations or involved third
    parties.

  * __In Progress (Open)__

    Once all preliminary work is completed the Transaction Data record may be opened and made visible/usable to the
    various business operations, including third parties if appropriate, that will work the transaction to completion.
    Arriving in this stage may be given a number of names: "opening", "releasing", "posting", etc.  they all indicate
    that the Transaction Data record is actionable.

  * __Cancelled__

    Certain kinds of opened business activities may be terminated prior to successful completion.  When this happens the
    Transaction Data record is no longer actionable and becomes part of the historical record, but only insofar as
    unsuccessful activities are concerned.

    Note that this ending stage is only appropriate for business activities which never reached any state of completion.
    Some business activities may be partially successful, for example a sales order which shipped 5 out of 10 units of
    an ordered item.  All business activities which are partial completed prior to termination are, for our purposes,
    not considered cancelled.

    At the point of being Cancelled, the Transaction Data record should be considered immutable, except for the
    possibility of deletion once the record is no longer useful for reporting or analytics.

  * __Closed__

    Upon the successful, or partially successful, completion of a business activity, the associated Transaction Data
    record will be considered "Closed".  Closed transactions are not eligible for further business operations to be
    performed and the Transaction Data becomes part of the historical record for analysis and reference purposes.

    Closed Transaction Data records may be referenced by new, related Transactions.  For example a closed sales order
    reference may be required to process a new customer return transaction.

    At the point of being Closed, the Transaction Data record should be considered immutable, except for the possibility
    of deletion once the record is no longer useful for reporting or analytics.

    {{< alert title="Exceptions to Closed Transaction Immutability" color="info">}}
For a variety of reasons, some good and some bad, many business management systems support the idea of re-opening
previously Closed transactions for further business activities to be conducted.  However, in principle Closed
transactions should be considered final and we will adopt this as an axiomatic assumption in this documentation.
    {{< /alert >}}

  * __Purge Eligible__

    Transaction Data records may be purged when their history is no longer relevant to supporting business reporting or
    analysis.  Such records may be set as eligible to be purged by any process or batch job which runs to delete the records from the database.  The conditions which allow Transaction Data records to become Purge Eligible are:

      1. Either already in the Preliminary Planning, Closed, or Cancelled life-cycle stages.

      2. Are not referenced by other Transaction Data records which are not themselves Purge Eligible.

    In practice, Transaction Data in the Preliminary Planning and Cancelled stages have little barrier to being purged
    from the system, but Closed transactions will usually have time based constraints on Purge Eligibility; detailed
    Transaction Data must be retained for various periods of time to support financial and tax audits and for
    reference when communicating with different business partners.

Transaction Data constitutes the majority of the data retained by the application.  Care must be taken in structuring
and managing this data at the database level to ensure acceptable application performance in operations, reporting, and
analytics.  Transaction Data relations can easily reach into the millions of records for the class of application
contemplated here.

## Secondary Classifications

There are some classes of data which exist for technical reasons and/or are optional components which are not essential
to business management system operations.

### Analytic Data

Analytic Data exists to facilitate reporting and analytic workloads.  The Analytic Data consists of summarized
Transaction Data with some facts drawn from the Master Data.  In terms of structure, Analytic Data resembles typical
data warehousing tables which serve the same purpose.

The goals of Analytic Data in the business management system includeL

  * Allowing for the long term reporting of otherwise Purge Eligible Transaction data.

  * Providing the means to reporting contextually relevant Analytic Data within the user interface of the business
    management system.  Examples might include monthly customer sales on a customer form or weekly sales of items on an
    item form.

It is not a goal of business management system Analytic Data to make proper data warehouses and analytic tools
unnecessary.  Maintaining Analytic Data in the transaction processing system does come with database and application
performance penalties.  Taking in-application Analytic Data too far risks overall application usability; choosing what
Analytic Data should be available in the application must be done with care.

When Analytic Data doesn't enhance the normal transaction processing functions of the application, but may still be of
analytic value within the business, a data warehouse solution with the appropriate reporting tools should be considered.

Analytic Data may constitute a significant portion of the overall data retained in the database, but should still be
smaller than the Transaction Data (assuming the limitations on Analytic Data capture previously discussed).

### System Data

There is a need to retain certain data simply to facilitate the technical operations of the business management system
itself.  This is the role of System Data.  System Data can include relations for system oriented configurations and
relations that exist to manage user logins or auditing.

Typically System Data will consume an insignificant amount of data storage space.
