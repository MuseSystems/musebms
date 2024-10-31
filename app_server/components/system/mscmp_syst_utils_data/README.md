# MscmpSystUtilsData - Common Data Oriented Utilities

<!-- MDOC !-->

This is a set of utilities for working with data which is generally
useful across components.

Currently included in these utilities are:

* ETS operations

  Functions wrap some typical ETS operations so that they return standard result 
  tuples.

* Changeset validators

  Common validation functions which can be used to validate changesets across
  Components.


> #### Note {: .info}
>
> `Changeset Validators` do not check their `opts` parameter for validity.  This
> is expected to be handled by the caller prior to calling these functions.  See
> the `Msutils.Data.common_validator_options/1` macro for more information on
> adding the standard options which can be used to validate changesets.
