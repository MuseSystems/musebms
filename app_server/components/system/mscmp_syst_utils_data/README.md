# MscmpSystUtilsData - Common Data Oriented Utilities

<!-- MDOC !-->

This is a set of utilities for working with data which is generally
useful across components.


> #### Note {: .info}
>
> `Changeset Validators` do not check their `opts` parameter for validity.  This
> is expected to be handled by the caller prior to calling these functions.  See
> the `Msutils.Data.common_validator_options/1` macro for more information on
> adding the standard options which can be used to validate changesets.
