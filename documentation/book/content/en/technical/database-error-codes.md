+++
title = "Database Error Codes"
linkTitle = "Database Error Codes"
description = """Database error codes are used to identify specific classes of
errors in the database.
"""

draft = false

weight = 50
+++
{{< alert title="Temporary Entry" color="warning" >}}
This entry into the Technical Book is temporary until time can be found to move this content to a
more appropriate, permanent home.
{{< /alert >}}
## Database Error Codes

This section describes the SQL Error Codes which may be emitted by the database.

### Disallowed Operations (`PM0xx`)

  * `PM001` - A change was attempted on a field which does not allow changes.

  * `PM002` - An `INSERT`, `UPDATE`, or `DELETE` operation was attempted on a
              record which does not allow that operation.

  * `PM003` - Invalid change of a system defined record or field.

### Business Logic Errors (`PM1xx`)

  * `PM101` - A logical duplicate was detected.  This can happen when the
              business rules dictate a condition of uniqueness which cannot be
              readily implemented by a `UNIQUE` constraint.

  * `PM102` - A limited resource, such as a finite numbering sequence, has been
              exhausted.

  * `PM103` - Out of range values were detected.

  * `PM104` - A parent/child mismatch was detected.

  * `PM105` - Out of order pre-requisite establishment.  This error is raised
              when an optional pre-requisite is established after records which
              would have to satisfy the pre-requisite have already been
              created.  This way you cannot make child records invalid after
              the fact by establishing a pre-requisite.

  * `PM106` - Ineligible for deletion.  This error is raised when an attempt is
              made to delete a record or child of a record which is still either
              active or not purge eligible.

  * `PM107` - Invalid change for type.  This error occurs when an operation or
              other data change is attempted where such a change is not allowed
              by the application's rules.

  * `PM108` - Invalid state change.  This error occurs when an attempt is made to
              create a record or change the existing state of a record to an
              invalid state.  This can happen in cases where records or child
              records must conform to a set of requirements prior to the state
              change being allowed to occur.

  * `PM109` - Out of order deletion.  This error occurs when an attempt is made
              to delete a record or child of a record which would leave some
              other record or child of a record orphaned in some fashion.

  * `PM110` - Missing parameter.  This error occurs when a required parameter
              value is missing or was passed as a null value.
