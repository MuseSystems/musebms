+++
title = "Trigger Naming Conventions"
linkTitle = "Trigger Naming Conventions"
description = """Database trigger and trigger function naming conventions not only serve the
purpose of identifying specific triggers easily, but also in ordering trigger execution at
runtime.
"""

draft = false

weight = 40
+++
{{< alert title="Temporary Entry" color="warning" >}}
This entry into the Technical Book is temporary until time can be found to move this content to a
more appropriate, permanent home.
{{< /alert >}}

## Trigger Function Names

Trigger function names follow a convention which 1) establishes that the function is specifically
a trigger function; 2) at what transaction time the trigger runs; 3) under which operations the
trigger runs; and 4) a name relevant to the purpose of the trigger.

The form of the name is: `trig_<b/a/i>_<i/u/d>_<purpose>`

  1. **`trig_`**: the indication that this is a trigger returning function which should not be used
     outside of trigger contexts.

  2. **`<b/a/i>`**: an indicator of what phase of the transaction the trigger is expected to be
     fired. The available options are `b` for `BEFORE` triggers, `a` for `AFTER` triggers, and `i`
     for `INSTEAD OF` triggers.  If the trigger function is designed to be called in more than one
     transaction phase, multiple indicators may be placed next to each other.

  3. **`<i/u/d>`**: establishes which operations are supported by the trigger function. The
     available options are `i` for `INSERT`, 'u' for `UPDATE`, and `d` for `DELETE`.  If a trigger
     function is designed to support more than a single operation, the identifier of the supported
     operations may be placed next to each other.

  4. **`<purpose>`**: a descriptive name for the trigger function.

As an example, consider a trigger function designed to verify that a record is 'consistent' prior
to allowing an inserted or updated record to be visible to the database.  Such a trigger may be
named something like:

  * **`trig_a_iu_validate_consistency`**

This would indicate that the trigger is expected to be an `AFTER` trigger which can be run during
both `INSERT` and `UPDATE` operations.

## Trigger Names

Trigger names follow a similar naming convention to the trigger function naming conventions
discussed above.  In fact, trigger names should be closely based on the trigger function name the
trigger calls.  The first difference in naming is that an execution order setting prefix is added
prior to the `trig_` opening.  The next difference is in the way the previously defined indicators
in the name are used.  The `<b/a/i>` and `<i/u/d>` indicators present in trigger function names
indicate which runtime conditions the trigger function supports; these same indicators are used
in trigger names as well, but in trigger names the indicators specify the specific firing
conditions of the trigger and so may differ slightly from the supported indicators for the trigger
function name.

Using our example trigger function name above, lets suppose that we want to create two separate
triggers which have independent conditions for firing, but both call the same trigger function;
perhaps the `INSERT` call fires the trigger function unconditionally, but the `UPDATE` call only
fires if a specific `WHEN` condition is true.  The two trigger names could be:

  * **`a50_trig_a_i_validate_consisteny`** for the `INSERT` trigger
  * **`a50_trig_a_u_validate_consistency`** for the `UPDATE` trigger.

Note that the `i` and `u` indicators are separate in the trigger names, but are next to each other
in the trigger function name.

### Trigger Name Prefix Conventions

Triggers are executed by the database in trigger name order according to the database collation.
To facilitate the organization of our code and to allow the execution ordering to proceed in a
deterministic way, we adopt the following trigger name prefixes.

  * **`a00_ - a99_`** : These are early validations designed to stop later,
    possibly more expensive processing later in the trigger sequences.
    We shouldn't be changing or setting data in this class of function,
    though we might look up data in other tables.

  * **`b00_ - b99_`** : Data manipulation functions.  These are the functions
    we want updating or setting values that are appropriate for the
    limits of database maintained business logic (data integrity/
    consistency focused).

  * **`c00_ - c99_`** : Late validation functions.  These are the functions
    which validate data after the data manipulation phase.  In reality
    most data validation should probably be here since the "b" class
    triggers can take a starting invalid record and make it valid.

  * **`z00_ - z99_`** : Utility/Auxiliary processing functions.  This class
    of trigger processes records/data/etc that aren't directly related
    to the business data in the record.  For example, the diagnostic
    columns such as last updated or updated by or functions that record
    data changes to an audit table are the kinds of functions which
    should be in the "z" class.  These functions should not make
    business validation judgements or take transformative actions on
    business data.  These functions are really operational in nature
    and work on records which, from a business data perspective, are in
    their final form.

{{< alert title="Trigger Names Only" color="info" >}}
Note that the above applies to the names of the actual triggers defined on tables and not the
names of the trigger functions executed by the triggers.
{{< /alert >}}
