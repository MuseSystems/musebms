# MscmpSystError - Exception Handling Component

API for defining a standard for error handling and reporting.

This module defines a nested structure for reporting errors in contexts where a result should be
represented by an error result.  By capturing lower level errors and reporting them in a
standard way, various application errors, especially non-fatal errors, can be handled as
appropriate and logged for later analysis.

The basic form of a reportable application error is: `{:error, %MscmpSystError{}}` where
`%MscmpSystError{}` contains basic fields to identify the kind of error, the source of the
error, and other error related data.

Functions in this API are used to work with the returned exception.
