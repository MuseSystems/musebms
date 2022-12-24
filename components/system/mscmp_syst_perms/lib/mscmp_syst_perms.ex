# Source File: mscmp_syst_perms.ex
# Location:    musebms/components/system/mscmp_syst_perms/lib/mscmp_syst_perms.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystPerms do
  alias MscmpSystPerms.Impl

  @external_resource "README.md"

  @moduledoc File.read!(Path.join([__DIR__, "..", "README.md"]))

  # ==============================================================================================
  #
  # Perm Functional Type Data
  #
  # ==============================================================================================

  @doc section: :perms_data
  @doc """
  Updates Permission Functional Type user maintainable data.

  This record type is usually maintained via database migrations and most
  changes are not possible at the application server level.  However the user
  facing `display_name` and `user_description` fields are available for update.

  On successful update, a success tuple is returned including a copy of the
  updated Permission Functional Type record (`{:ok, <record>}`).  On failure
  an error tuple is returned indicating the reason for failure
  (`{:error, reason}`).

  ## Parameters

    * `perm_functional_type` - a required value which is either the populated
    `Msdata.SystPermFunctionalTypes` struct or ID value of the record to be
    updated.

    * `perm_functional_type_params` - a map of values which define the change to
    be made to the database.  For details on which fields may be maintained see
    `t:MscmpSystPerms.Types.perm_functional_type_params/0`.

  """
  @spec update_perm_functional_type(
          Types.perm_functional_type_id() | Msdata.SystPermFunctionalTypes.t(),
          Types.perm_functional_type_params()
        ) ::
          {:ok, Msdata.SystPermFunctionalTypes.t()} | {:error, MscmpSystError.t()}
  defdelegate update_perm_functional_type(perm_functional_type, perm_functional_type_params),
    to: Impl.PermFunctionalType

  # ==============================================================================================
  #
  # Perm Data
  #
  # ==============================================================================================

  @doc section: :perms_data
  @doc """
  Creates a new user defined Permission record.

  Upon creation this function returns a success tuple in the form
  `{:ok, %Msdata.SystPerms{}}` where the struct is the data of the newly created
  record.  On error an error tuple is returned (`{:error, %MscmpSystError{}}`).

  ## Parameters

    * `perm_params` - a map of values which describe the Permission record to
    create.  For details see `t:MscmpSystPerms.Types.perm_params/0`.
  """
  @spec create_perm(Types.perm_params()) ::
          {:ok, Msdata.SystPerms.t()} | {:error, MscmpSystError.t()}
  defdelegate create_perm(perm_params), to: Impl.Perm

  @doc section: :perms_data
  @doc """
  Updates an existing Permission record.

  Upon update this function returns a success tuple in the form
  `{:ok, %Msdata.SystPerms{}}` where the struct is the data of the updated
  record.  On error an error tuple is returned (`{:error, %MscmpSystError{}}`).

  System defined Permission records only allow the user interface display fields
  to be updated (`display_name`, `user_description`).  User defined permissions
  allow a broader range of changes.

  ## Parameters

    * `perm` - either a fully populated `Msdata.SystPerms` struct representing
    the before-update state of the Permission record or the record ID of the
    Permission record to update.

    * `perm_params` - a map of values which describe the desired update fields
    and their new values.  For details see `t:MscmpSystPerms.Types.perm_params/0`.
  """
  @spec update_perm(Types.perm_id() | Msdata.SystPerms.t(), Types.perm_params()) ::
          {:ok, Msdata.SystPerms.t()} | {:error, MscmpSystError.t()}
  defdelegate update_perm(perm, perm_params), to: Impl.Perm

  @doc section: :perms_data
  @doc """
  Deletes a user defined Permission record.

  On successful deletion of the record this function returns a success tuple in
  the form `{:ok, :deleted}`.  If the requested record is not found a success
  tuple in the form `{:ok, :not_found}` is returned.  On error an error tuple is
  returned (`{:error, %MscmpSystError{}}`).

  ## Parameters

    * `perm` - either a populated `Msdata.SystPerms` struct or the record ID
    value of the Permission record to delete.
  """
  @spec delete_perm(Msdata.SystPerms.t() | Types.perm_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  defdelegate delete_perm(perm), to: Impl.Perm

  # ==============================================================================================
  #
  # Perm Role Data
  #
  # ==============================================================================================

  @doc section: :perms_data
  @doc """
  Creates a new user defined Permission Role record.

  On successful record creation this function returns a success tuple in the
  form `{:ok, %Msdata.SystPermRoles{}}` where the struct is the data of the
  created record.  On error an error tuple is returned
  (`{:error, %MscmpSystError{}}`).

  ## Parameters

    * `perm_role_params` - a map describing the new Permission Role record's
    values.  For more about see `t:MscmpSystPerms.Types.perm_role_params/0`.
  """
  @spec create_perm_role(Types.perm_role_params()) ::
          {:ok, Msdata.SystPermRoles.t()} | {:error, MscmpSystError.t()}
  defdelegate create_perm_role(perm_role_params), to: Impl.PermRole

  @doc section: :perms_data
  @doc """
  Updates Permission Role records.

  Upon update this function returns a success tuple in the form
  `{:ok, %Msdata.SystPermRoles{}}` where the struct is the data of the updated
  record.  On error an error tuple is returned (`{:error, %MscmpSystError{}}`).

  System defined Permission Role records only allow the user interface display
  fields to be updated (`display_name`, `user_description`).  User defined
  Permission Roles allow a broader range of changes.

  ## Parameters

    * `perm_role` - either the record ID of the Permission Role record to update
    or a populated `Msdata.SystPermRoles` struct representing the pre-update
    version of the record's data.

    * `perm_role_params` - a map describing the new Permission Role record's
    values.  For more about see `t:MscmpSystPerms.Types.perm_role_params/0`.

  """
  @spec update_perm_role(
          Types.perm_role_id() | Msdata.SystPermRoles.t(),
          Types.perm_role_params()
        ) ::
          {:ok, Msdata.SystPermRoles.t()} | {:error, MscmpSystError.t()}
  defdelegate update_perm_role(perm_role, perm_role_params), to: Impl.PermRole

  @doc section: :perms_data
  @doc """
  Deletes user defined Permission Role records.

  On successful deletion of the record this function returns a success tuple in
  the form `{:ok, :deleted}`.  If the requested record is not found a success
  tuple in the form `{:ok, :not_found}` is returned.  On error an error tuple is
  returned (`{:error, %MscmpSystError{}}`).

  System defined Permission Role records may not be deleted using this API.

  ## Parameters

    * `perm_role` - either the record ID value of the Permission Role record to
    delete or a populated `Msdata.SystPermRoles` struct representing the
    Permission Role record.
  """
  @spec delete_perm_role(Msdata.SystPermRoles.t() | Types.perm_role_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  defdelegate delete_perm_role(perm_role), to: Impl.PermRole

  # ==============================================================================================
  #
  # Perm Role Grant Data
  #
  # ==============================================================================================

  @doc section: :perms_data
  @doc """
  Creates a new Permission Role Grant to a user defined Permission Role.

  On successful record creation this function returns a success tuple in the
  form `{:ok, %Msdata.SystPermRoleGrants{}}` where the struct is the data of the
  created record.  On error an error tuple is returned
  (`{:error, %MscmpSystError{}}`).

  New Permission Role Grant records can only be created for parent Permission
  Role records that are not set as being system defined.

  ## Parameters

    * `perm_role_grant_params` - a map describing the new Permission Role Grant
    record's values.  For more about see
    `t:MscmpSystPerms.Types.perm_role_grant_params/0`.
  """
  @spec create_perm_role_grant(Types.perm_role_grant_params()) ::
          {:ok, Msdata.SystPermRoleGrants.t()} | {:error, MscmpSystError.t()}
  defdelegate create_perm_role_grant(perm_role_grant_params), to: Impl.PermRoleGrant

  @doc section: :perms_data
  @doc """
  Updates the Permission Role Grant records of user defined Permission Roles.

  Upon update this function returns a success tuple in the form
  `{:ok, %Msdata.SystPermRoleGrants{}}` where the struct is the data of the
  updated record.  On error an error tuple is returned
  (`{:error, %MscmpSystError{}}`).

  Permission Role Grant records which are children of system defined Permission
  Roles may not be updated using this API.

  ## Parameters

    * `perm_role_grant` - either the record ID of the Permission Role Grant
    record to update or a populated `Msdata.SystPermRoleGrants` struct
    representing the pre-update version of the record's data.

    * `perm_role_grant_params` - a map describing the Permission Role Grant
    record values to update.  For more about see
    `t:MscmpSystPerms.Types.perm_role_grant_params/0`.
  """
  @spec update_perm_role_grant(
          Types.perm_role_grant_id() | Msdata.SystPermRoleGrants.t(),
          Types.perm_role_grant_params()
        ) ::
          {:ok, Msdata.SystPermRoleGrants.t()} | {:error, MscmpSystError.t()}
  defdelegate update_perm_role_grant(perm_role_grant, perm_role_grant_params),
    to: Impl.PermRoleGrant

  @doc section: :perms_data
  @doc """
  Deletes the Permission Role Grant records of user defined Permission Roles.

  On successful deletion of the record this function returns a success tuple in
  the form `{:ok, :deleted}`.  If the requested record is not found a success
  tuple in the form `{:ok, :not_found}` is returned.  On error an error tuple is
  returned (`{:error, %MscmpSystError{}}`).

  Permission Role Grant records belonging to System defined Permission Roles may
  not be deleted using this API.

  ## Parameters

    * `perm_role_grant` - either the record ID value of the Permission Role
    Grant record to delete or a populated `Msdata.SystPermRoleGrants` struct
    representing the Permission Role Grant record.
  """
  @spec delete_perm_role_grant(Msdata.SystPermRoleGrants.t() | Types.perm_role_grant_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  defdelegate delete_perm_role_grant(perm_role_grant), to: Impl.PermRoleGrant
end
