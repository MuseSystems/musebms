# Source File: protocol.ex
# Location:    musebms/app_server/components/system/mscmp_syst_perms/lib/api/protocol.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defprotocol MscmpSystPerms.Protocol do
  @moduledoc """
  Defines a common API for the various higher level implementations which use
  `MscmpSystPerms` as a core for permission management.
  """

  alias MscmpSystPerms.Types

  @doc """
  Provides the effective Permissions/Rights/Scopes for the user context
  identified by the `selector` as calculated from all effective grants and
  revocations.

  This function answers the question, "what rights does this user really have?"

  On successful execution, a success tuple is returned including a map of the
  selected Permissions and the Rights/Scopes granted.  Errors will result in the
  return of an error tuple.

  ## Parameters

    * `selector` - this value is a struct which determines the specific
    implementation of this function to call and which contains the keys/values
    to use in selecting which Permission and Permission Role Grant records to
    retrieve.  Specific details about what records are involved and how the
    selection return values are determine are implementation specific and will
    be documented on a case-by-case basis.

    * `opts` - a Keyword List of optional parameters which may be provided.  The
    only general option is listed below, each specific implementation of this
    function may extend the available options as appropriate to the
    implementation.

      * `permissions` - a list of specific Permission names to lookup.  This is
      usually supplied as a limiting filter; without this list the typical
      behavior is to return all of the permissions for a given Permission
      Functional Type filtered only by the `selector` data.  Again, the details
      of the filtering or inclusion using this option will be implementation
      specific and documented for each individual implementation.
  """
  @spec get_effective_perm_grants(struct(), Keyword.t()) ::
          {:ok, Types.perm_grants()} | {:error, MscmpSystError.t()}
  def get_effective_perm_grants(selector, opts)

  @doc """
  Lists all of the Permission Role records granted to the user context
  identified by the `selector`, including the Rights/Scopes of the grants.

  This function facilitates understanding what roles have been granted to user
  and what Permissions/Rights/Scopes those roles grant to the user.  This list
  is intended to be descriptive and not directly indicating the effective grants
  applied to the user.  Typical uses of this function are to populate lists of
  Permission Role Grants for the purposes of managing user access.

  ## Parameters

    * `selector` - this value is a struct which determines the specific
    implementation of this function to call and which contains the keys/values
    to use in selecting which Permission and Permission Role Grant records to
    retrieve.  Specific details about what records are involved and how the
    selection return values are determine are implementation specific and will
    be documented on a case-by-case basis.

    * `opts` - a Keyword List of optional parameters which may be provided.  The
    only general option is listed below, each specific implementation of this
    function may extend the available options as appropriate to the
    implementation.


      * `include_perms` - a boolean option which, when set `true`, will preload
      the `Msdata.SystPermRoleGrants` `perm` data.  The default value for this
      option is `false`.
  """
  @spec list_perm_grants(struct(), Keyword.t()) ::
          {:ok, [Msdata.SystPermRoles.t()]} | {:error, MscmpSystError.t()}
  def list_perm_grants(selector, opts)

  @doc """
  List all explicit denials of Permissions from the identified user context.

  An assumption made by this module is that Permission Roles are granted to
  users as whole roles, but individual Permissions may be explicitly denied from
  users on a Permission by Permission basis.  This function is intended to list
  Permission denials for a user context so that the denials may be managed.

  Some user contexts may not offer explicit Permission denials.  In these cases
  this function should simply return a success tuple containing an empty list as
  the value.

  ## Parameters

    * `selector` - this value is a struct which determines the specific
    implementation of this function to call and which contains the keys/values
    to use in selecting which Permission denial records to retrieve. Specific
    details about what records are involved and how the selection return values
    are determine are implementation specific and will be documented on a case-
    by-case basis.

    * `opts` - a Keyword List of optional parameters which may be provided.  The
    only general option is listed below, each specific implementation of this
    function may extend the available options as appropriate to the
    implementation.
  """
  @spec list_perm_denials(struct(), Keyword.t()) ::
          {:ok, [Msdata.SystPerms.t()] | []} | {:error, MscmpSystError.t()}
  def list_perm_denials(selector, opts)

  @doc """
  Grants a Permission Role to the given selector.

  On successful execution of the grant, the function will return a simple `:ok`.
  On error, an error tuple is returned.

  ## Parameters

    * `selector` - this value is a struct which determines the specific
    implementation of this function to call and which contains the keys/values
    to use as the unique identifier of the user context to which you are
    granting Permission Roles.

    * `perm_role_id` - the record ID value of the Permission Role record which
    you are granting to the user context identified by the `selector`.
  """
  @spec grant_perm_role(struct(), Types.perm_role_id()) :: :ok | {:error, MscmpSystError.t()}
  def grant_perm_role(selector, perm_role_id)

  @doc """
  Revokes a previously granted Permission Role from the given selector.

  On successful execution a success tuple is returned.  If the grant was
  actually deleted this tuple will take the form `{:ok, :deleted}`.  If the
  grant was not found for the user context identified by the `selector` then the
  `{:ok, :not_found}` tuple will be returned.  Any other outcome is an error
  resulting in an error tuple being returned.

  ## Parameters

    * `selector` - this value is a struct which determines the specific
    implementation of this function to call and which contains the keys/values
    to use as the unique identifier of the user context from which you are
    revoking Permission Roles.

    * `perm_role_id` - the record ID value of the Permission Role record which
    you are revoking from the user context identified by the `selector`.
  """
  @spec revoke_perm_role(struct(), Types.perm_role_id()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t()}
  def revoke_perm_role(selector, perm_role_id)
end
