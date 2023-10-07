+++
title = "Trigger Naming Conventions"
linkTitle = "Trigger Naming Conventions"
description = """Database trigger naming conventions not only serve the purpose of identifying
specific triggers easily, but also in ordering trigger execution at runtime.
"""

draft = false

weight = 40
+++
{{< alert title="Temporary Entry" color="warning" >}}
This entry into the Technical Book is temporary until time can be found to move this content to a
more appropriate, permanent home.
{{< /alert >}}

## Trigger Name Prefixes

Triggers are executed by the database in trigger name order according to the database collation.
To facilitate the organization of our code and to allow the execution ordering to proceed in a
deterministic way, we adopt the following trigger name prefixes.

  * a00_ - a99_ : These are early validations designed to stop later,
    possibly more expensive processing later in the trigger sequences.
    We shouldn't be changing or setting data in this class of function,
    though we might look up data in other tables.

  * b00_ - b99_ : Data manipulation functions.  These are the functions
    we want updating or setting values that are appropriate for the
    limits of database maintained business logic (data integrity/
    consistency focused).

  * c00_ - c99_ : Late validation functions.  These are the functions
    which validate data after the data manipulation phase.  In reality
    most data validation should probably be here since the "b" class
    triggers can take a starting invalid record and make it valid.

  * z00_ - z99_ : Utility/Auxiliary processing functions.  This class
    of trigger processes records/data/etc that aren't directly related
    to the business data in the record.  For example, the diagnostic
    columns such as last updated or updated by or functions that record
    data changes to an audit table are the kinds of functions which
    should be in the "z" class.  These functions should not make
    business validation judgements or take transformative actions on
    business data.  These functions are really operational in nature
    and work on records which, from a business data perspective, are in
    their final form.

{{< alert title="Temporary Entry" color="info" >}}
Note that the above applies to the names of the actual triggers defined on tables and not the
names of the trigger functions executed by the triggers.
{{< /alert >}}
