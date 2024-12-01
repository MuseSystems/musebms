# Source File: mscmp_syst_perms.ex
# Location:    musebms/app_server/components/system/mscmp_syst_perms/lib/api/mscmp_syst_perms.ex
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
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias MscmpSystError.Types.Context, as: ErrorContext
  alias MscmpSystPerms.Impl
  alias MscmpSystPerms.Types

  # ==============================================================================================
  #
  # Perm Functional Type Data
  #
  # ==============================================================================================

  ##############################################################################
  #
  # update_perm_functional_type
  #
  #

  @doc section: :perms_data
  @doc """
  Updates Permission Functional Type user maintainable data.

  This record type is usually maintained via database migrations and most
  changes are not possible at the application server level.  However the user
  facing `display_name` and `user_description` fields are available for update.

  On successful update, a success tuple is returned including a copy of the
  updated Permission Functional Type record (`{:ok, <record>}`).  On failure
  an error tuple is returned indicating the reason for failure
  (`{:error, %Mserror.PermsError{}}`).

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
          {:ok, Msdata.SystPermFunctionalTypes.t()} | {:error, Mserror.PermsError.t()}
  def update_perm_functional_type(perm_functional_type, perm_functional_type_params) do
    case Impl.PermFunctionalType.update_perm_functional_type(
           perm_functional_type,
           perm_functional_type_params
         ) do
      {:ok, perm} ->
        {:ok, perm}

      {:error, error} ->
        {:error,
         Mserror.PermsError.new(
           :perms_data,
           "Error updating Permission Functional Type",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :update_perm_functional_type, 2},
             parameters: %{
               perm_functional_type: perm_functional_type,
               perm_functional_type_params: perm_functional_type_params
             }
           }
         )}
    end
  end

  # ==============================================================================================
  #
  # Perm Data
  #
  # ==============================================================================================

  ##############################################################################
  #
  # create_perm
  #
  #

  @doc section: :perms_data
  @doc """
  Creates a new user defined Permission record.

  Upon creation this function returns a success tuple in the form
  `{:ok, %Msdata.SystPerms{}}` where the struct is the data of the newly created
  record.  On error an error tuple is returned (`{:error, %Mserror.PermsError{}}`).

  ## Parameters

    * `perm_params` - a map of values which describe the Permission record to
    create.  For details see `t:MscmpSystPerms.Types.perm_params/0`.
  """
  @spec create_perm(Types.perm_params()) ::
          {:ok, Msdata.SystPerms.t()} | {:error, Mserror.PermsError.t()}
  def create_perm(perm_params) do
    case Impl.Perm.create_perm(perm_params) do
      {:ok, perm} ->
        {:ok, perm}

      {:error, error} ->
        {:error,
         Mserror.PermsError.new(
           :perms_data,
           "Error creating Permission",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :create_perm, 1},
             parameters: %{perm_params: perm_params}
           }
         )}
    end
  end

  ##############################################################################
  #
  # update_perm
  #
  #

  @doc section: :perms_data
  @doc """
  Updates an existing Permission record.

  Upon update this function returns a success tuple in the form
  `{:ok, %Msdata.SystPerms{}}` where the struct is the data of the updated
  record.  On error an error tuple is returned (`{:error, %Mserror.PermsError{}}`).

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
          {:ok, Msdata.SystPerms.t()} | {:error, Mserror.PermsError.t()}
  def update_perm(perm, perm_params) do
    case Impl.Perm.update_perm(perm, perm_params) do
      {:ok, perm} ->
        {:ok, perm}

      {:error, error} ->
        {:error,
         Mserror.PermsError.new(
           :perms_data,
           "Error updating Permission",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :update_perm, 2},
             parameters: %{perm: perm, perm_params: perm_params}
           }
         )}
    end
  end

  ##############################################################################
  #
  # delete_perm
  #
  #

  @doc section: :perms_data
  @doc """
  Deletes a user defined Permission record.

  On successful deletion of the record this function returns `:ok`.  If the
  requested record is not found an error tuple in the form of
  `{:error, %Mserror.PermsError{cause: :not_found}}` is returned.  On any other
  error an error tuple is returned (`{:error, %Mserror.PermsError{}}`).

  ## Parameters

    * `perm` - either a populated `Msdata.SystPerms` struct or the record ID
    value of the Permission record to delete.
  """
  @spec delete_perm(Msdata.SystPerms.t() | Types.perm_id()) ::
          :ok | {:error, Mserror.PermsError.t()}
  def delete_perm(perm) do
    case Impl.Perm.delete_perm(perm) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.PermsError.new(
           :perms_data,
           "Error deleting Permission",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :delete_perm, 1},
             parameters: %{perm: perm}
           }
         )}
    end
  end

  # ==============================================================================================
  #
  # Perm Role Data
  #
  # ==============================================================================================

  ##############################################################################
  #
  # create_perm_role
  #
  #

  @doc section: :perms_data
  @doc """
  Creates a new user defined Permission Role record.

  On successful record creation this function returns a success tuple in the
  form `{:ok, %Msdata.SystPermRoles{}}` where the struct is the data of the
  created record.  On error an error tuple is returned
  (`{:error, %Mserror.PermsError{}}`).

  ## Parameters

    * `perm_role_params` - a map describing the new Permission Role record's
    values.  For more about see `t:MscmpSystPerms.Types.perm_role_params/0`.
  """
  @spec create_perm_role(Types.perm_role_params()) ::
          {:ok, Msdata.SystPermRoles.t()} | {:error, Mserror.PermsError.t()}
  def create_perm_role(perm_role_params) do
    case Impl.PermRole.create_perm_role(perm_role_params) do
      {:ok, perm} ->
        {:ok, perm}

      {:error, error} ->
        {:error,
         Mserror.PermsError.new(
           :perms_data,
           "Error creating Permission Role",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :create_perm_role, 1},
             parameters: %{perm_role_params: perm_role_params}
           }
         )}
    end
  end

  ##############################################################################
  #
  # update_perm_role
  #
  #

  @doc section: :perms_data
  @doc """
  Updates Permission Role records.

  Upon update this function returns a success tuple in the form
  `{:ok, %Msdata.SystPermRoles{}}` where the struct is the data of the updated
  record.  On error an error tuple is returned (`{:error, %Mserror.PermsError{}}`).

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
          {:ok, Msdata.SystPermRoles.t()} | {:error, Mserror.PermsError.t()}
  def update_perm_role(perm_role, perm_role_params) do
    case Impl.PermRole.update_perm_role(perm_role, perm_role_params) do
      {:ok, perm} ->
        {:ok, perm}

      {:error, error} ->
        {:error,
         Mserror.PermsError.new(
           :perms_data,
           "Error updating Permission Role",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :update_perm_role, 2},
             parameters: %{perm_role: perm_role, perm_role_params: perm_role_params}
           }
         )}
    end
  end

  ##############################################################################
  #
  # delete_perm_role
  #
  #

  @doc section: :perms_data
  @doc """
  Deletes user defined Permission Role records.

  On successful deletion of the record this function returns `:ok`.  If the
  requested record is not found an error tuple in the form of
  `{:error, %Mserror.PermsError{cause: :not_found}}` is returned.  On any other
  error an error tuple is returned (`{:error, %Mserror.PermsError{}}`).

  System defined Permission Role records may not be deleted using this API.

  ## Parameters

    * `perm_role` - either the record ID value of the Permission Role record to
    delete or a populated `Msdata.SystPermRoles` struct representing the
    Permission Role record.
  """
  @spec delete_perm_role(Msdata.SystPermRoles.t() | Types.perm_role_id()) ::
          :ok | {:error, Mserror.PermsError.t()}
  def delete_perm_role(perm_role) do
    case Impl.PermRole.delete_perm_role(perm_role) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.PermsError.new(
           :perms_data,
           "Error deleting Permission Role",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :delete_perm_role, 1},
             parameters: %{perm_role: perm_role}
           }
         )}
    end
  end

  ##############################################################################
  #
  # get_perm_role_id_by_name
  #
  #

  @doc section: :perms_data
  @doc """
  Retrieves the Permission Role record ID as found by its functional type name
  and Internal Name.

  The function will return a success tuple containing the record ID of the
  requested Permission Role if found.  If the requested record is not found an
  error tuple in the form of `{:error, %Mserror.PermsError{cause: :not_found}}`
  is returned.  If any other error occurs an error tuple is returned.

  ## Parameters

   * `perm_func_type_name` - the Internal Name of the Permission Functional Type
   to which the search should be restricted.  While the Permission Role name
   itself is unique, specifying the Permission Functional Type serves as a check
   that request context is correct.

   * `perm_role_name` - the Internal Name value of the Permission Role to search
   for.

  ## Examples

  Retrieve the record ID of a Permission Role record.

      iex> {:ok, _perm_role_id} =
      ...>   MscmpSystPerms.get_perm_role_id_by_name("func_type_1", "perm_role_1")

  Searching for a non-existent record returns error tuple.

      iex> {:error, %Mserror.PermsError{cause: :not_found}} =
      ...>   MscmpSystPerms.get_perm_role_id_by_name("func_type_1", "nonexistent_role")

  """
  @spec get_perm_role_id_by_name(Types.perm_functional_type_name(), Types.perm_role_name()) ::
          {:ok, Types.perm_role_id()} | {:error, Mserror.PermsError.t()}
  def get_perm_role_id_by_name(perm_func_type_name, perm_role_name) do
    case Impl.PermRole.get_perm_role_id_by_name(perm_func_type_name, perm_role_name) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.PermsError.new(:perms_data, "Error getting Permission Role ID by name",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :get_perm_role_id_by_name, 2},
             parameters: %{
               perm_func_type_name: perm_func_type_name,
               perm_role_name: perm_role_name
             }
           }
         )}
    end
  end

  # ==============================================================================================
  #
  # Perm Role Grant Data
  #
  # ==============================================================================================

  ##############################################################################
  #
  # create_perm_role_grant
  #
  #

  @doc section: :perms_data
  @doc """
  Creates a new Permission Role Grant to a user defined Permission Role.

  On successful record creation this function returns a success tuple in the
  form `{:ok, %Msdata.SystPermRoleGrants{}}` where the struct is the data of the
  created record.  On error an error tuple is returned
  (`{:error, %Mserror.PermsError{}}`).

  New Permission Role Grant records can only be created for parent Permission
  Role records that are not set as being system defined.

  ## Parameters

    * `perm_role_grant_params` - a map describing the new Permission Role Grant
    record's values.  For more about see
    `t:MscmpSystPerms.Types.perm_role_grant_params/0`.
  """
  @spec create_perm_role_grant(Types.perm_role_grant_params()) ::
          {:ok, Msdata.SystPermRoleGrants.t()} | {:error, Mserror.PermsError.t()}
  def create_perm_role_grant(perm_role_grant_params) do
    case Impl.PermRoleGrant.create_perm_role_grant(perm_role_grant_params) do
      {:ok, perm} ->
        {:ok, perm}

      {:error, error} ->
        {:error,
         Mserror.PermsError.new(
           :perms_data,
           "Error creating Permission Role Grant",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :create_perm_role_grant, 1},
             parameters: %{perm_role_grant_params: perm_role_grant_params}
           }
         )}
    end
  end

  ##############################################################################
  #
  # update_perm_role_grant
  #
  #

  @doc section: :perms_data
  @doc """
  Updates the Permission Role Grant records of user defined Permission Roles.

  Upon update this function returns a success tuple in the form
  `{:ok, %Msdata.SystPermRoleGrants{}}` where the struct is the data of the
  updated record.  On error an error tuple is returned
  (`{:error, %Mserror.PermsError{}}`).

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
          {:ok, Msdata.SystPermRoleGrants.t()} | {:error, Mserror.PermsError.t()}
  def update_perm_role_grant(perm_role_grant, perm_role_grant_params) do
    case Impl.PermRoleGrant.update_perm_role_grant(perm_role_grant, perm_role_grant_params) do
      {:ok, perm} ->
        {:ok, perm}

      {:error, error} ->
        {:error,
         Mserror.PermsError.new(
           :perms_data,
           "Error updating Permission Role Grant",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :update_perm_role_grant, 2},
             parameters: %{
               perm_role_grant: perm_role_grant,
               perm_role_grant_params: perm_role_grant_params
             }
           }
         )}
    end
  end

  ##############################################################################
  #
  # delete_perm_role_grant
  #
  #

  @doc section: :perms_data
  @doc """
  Deletes the Permission Role Grant records of user defined Permission Roles.

  On successful deletion of the record this function returns `:ok`.  If the
  requested record is not found an error tuple in the form
  `{:error, %Mserror.PermsError{cause: :not_found}}` is returned.  On any other
  error an error tuple is returned (`{:error, %Mserror.PermsError{}}`).

  Permission Role Grant records belonging to System defined Permission Roles may
  not be deleted using this API.

  ## Parameters

    * `perm_role_grant` - either the record ID value of the Permission Role
    Grant record to delete or a populated `Msdata.SystPermRoleGrants` struct
    representing the Permission Role Grant record.
  """
  @spec delete_perm_role_grant(Msdata.SystPermRoleGrants.t() | Types.perm_role_grant_id()) ::
          :ok | {:error, Mserror.PermsError.t()}
  def delete_perm_role_grant(perm_role_grant) do
    case Impl.PermRoleGrant.delete_perm_role_grant(perm_role_grant) do
      :ok ->
        :ok

      {:error, error} ->
        {:error,
         Mserror.PermsError.new(
           :perms_data,
           "Error deleting Permission Role Grant",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :delete_perm_role_grant, 1},
             parameters: %{perm_role_grant: perm_role_grant}
           }
         )}
    end
  end

  ##############################################################################
  #
  # compare_scopes
  #
  #

  @doc section: :perms_data
  @doc """
  Compares two Scope values and returns a value indicating the relative
  expansiveness of Scope.

  Scopes restrict, to varying degrees, how much data a user might access for a
  given Right.  We can compare Scopes relative to how much more or less data
  a Scope grants to a user and that's what this function does.  Scopes granting
  more expansive access to data are considered greater than Scopes granting data
  on more restrictive terms.  Of course any two scopes may be equal as well.

  The return value is an atom indicating whether the Scope in the first
  parameter position is greater than, less than, or equal to the expansiveness
  of Scope in the second parameter position.  These return values are:

    * `:eq` - both the first and second Scopes are equal in terms of the
    expansiveness and are considered 'equal' to each other.

    * `:gt` - the first Scope parameter confers a greater expansiveness than the
    second Scope parameter and is considered 'greater than' the Scope of the
    second parameter.

    * `:lt` - the first Scope parameter confers a lesser expansiveness than the
    second Scope parameter and is considered 'less than' the Scope of the second
    parameter.

  """
  @spec compare_scopes(Types.rights_scope() | String.t(), Types.rights_scope() | String.t()) ::
          :eq | :gt | :lt
  defdelegate compare_scopes(test_scope, standard_scope), to: Impl.PermRoleGrant

  # ==============================================================================================
  #
  # Permissions Protocol API
  #
  # ==============================================================================================

  ##############################################################################
  #
  # Protocol Options Definition
  #
  #

  protocol_option_defs = [
    permissions: [
      type: {:or, [{:in, [:all]}, :string, {:list, :string}]},
      default: :all,
      doc: """
      Optionally filters the permissions returned to the single requested
      permission or a list of permissions.  The special value of `:all` will
      return all permissions.
      """
    ],
    preload_perms: [
      type: :boolean,
      default: false,
      doc: """
      A boolean option which, when `true`, will preload the
      `Msdata.SystPermRoleGrants` `perm` data.
      """
    ]
  ]

  ##############################################################################
  #
  # get_effective_perm_grants
  #
  #

  @get_effective_perm_grant_opts NimbleOptions.new!(
                                   Keyword.take(protocol_option_defs, [:permissions])
                                 )

  @doc section: :perms_management
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

    * `opts` - a Keyword List of optional parameters which may be provided.

  ## Options

      #{NimbleOptions.docs(@get_effective_perm_grant_opts)}
  """
  @spec get_effective_perm_grants(struct()) ::
          {:ok, Types.perm_grants()} | {:error, Mserror.PermsError.t()}
  @spec get_effective_perm_grants(struct(), Keyword.t()) ::
          {:ok, Types.perm_grants()} | {:error, Mserror.PermsError.t()}
  def get_effective_perm_grants(selector, opts \\ []) do
    validated_opts = NimbleOptions.validate!(opts, @get_effective_perm_grant_opts)

    case MscmpSystPerms.Protocol.get_effective_perm_grants(selector, validated_opts) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.PermsError.new(
           :perms_management,
           "Error getting effective Permission Grants",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :get_effective_perm_grants, 2},
             parameters: %{selector: selector, opts: validated_opts}
           }
         )}
    end
  end

  ##############################################################################
  #
  # list_perm_grants
  #
  #

  @list_perm_grant_opts NimbleOptions.new!(Keyword.take(protocol_option_defs, [:preload_perms]))

  @doc section: :perms_management
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

    * `opts` - a Keyword List of optional parameters which may be provided.

  ## Options

    #{NimbleOptions.docs(@list_perm_grant_opts)}
  """
  @spec list_perm_grants(struct()) ::
          {:ok, [Msdata.SystPermRoles.t()]} | {:error, Mserror.PermsError.t()}
  @spec list_perm_grants(struct(), Keyword.t()) ::
          {:ok, [Msdata.SystPermRoles.t()]} | {:error, Mserror.PermsError.t()}
  def list_perm_grants(selector, opts \\ []) do
    validated_opts = NimbleOptions.validate!(opts, @list_perm_grant_opts)

    case MscmpSystPerms.Protocol.list_perm_grants(selector, validated_opts) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.PermsError.new(
           :perms_management,
           "Error listing Permission Grants",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :list_perm_grants, 2},
             parameters: %{selector: selector, opts: validated_opts}
           }
         )}
    end
  end

  ##############################################################################
  #
  # list_perm_denials
  #
  #

  @list_perm_denial_opts NimbleOptions.new!(Keyword.take(protocol_option_defs, [:preload_perms]))

  @doc section: :perms_management
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
    to use in selecting which Permission denial records to retrieve.  Specific
    details about what records are involved and how the selection return values
    are determine are implementation specific and will be documented on a case-
    by-case basis.

    * `opts` - a Keyword List of optional parameters which may be provided.

  ## Options

    #{NimbleOptions.docs(@list_perm_denial_opts)}
  """
  @spec list_perm_denials(struct()) ::
          {:ok, [Msdata.SystPerms.t()] | []} | {:error, Mserror.PermsError.t()}
  @spec list_perm_denials(struct(), Keyword.t()) ::
          {:ok, [Msdata.SystPerms.t()] | []} | {:error, Mserror.PermsError.t()}
  def list_perm_denials(selector, opts \\ []) do
    validated_opts = NimbleOptions.validate!(opts, @list_perm_denial_opts)

    case MscmpSystPerms.Protocol.list_perm_denials(selector, validated_opts) do
      {:ok, result} ->
        {:ok, result}

      {:error, error} ->
        {:error,
         Mserror.PermsError.new(
           :perms_management,
           "Error listing Permission Denials",
           cause: error,
           context: %ErrorContext{
             origin: {__MODULE__, :list_perm_denials, 2},
             parameters: %{selector: selector, opts: validated_opts}
           }
         )}
    end
  end

  ##############################################################################
  #
  # grant_perm_role
  #
  #

  @doc section: :perms_management
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
  @spec grant_perm_role(struct(), Types.perm_role_id()) :: :ok | {:error, Exception.t()}
  defdelegate grant_perm_role(selector, perm_role_id), to: MscmpSystPerms.Protocol

  ##############################################################################
  #
  # revoke_perm_role
  #
  #

  @doc section: :perms_management
  @doc """
  Revokes a previously granted Permission Role from the given selector.

  On successful execution a success tuple is returned.  If the grant was
  actually deleted this tuple will take the form `:ok`.  If the
  grant was not found for the user context identified by the `selector` then an
  appropirate error tuple is returned.  Any other outcome is an error
  resulting in an error tuple being returned.

  ## Parameters

    * `selector` - this value is a struct which determines the specific
    implementation of this function to call and which contains the keys/values
    to use as the unique identifier of the user context from which you are
    revoking Permission Roles.

    * `perm_role_id` - the record ID value of the Permission Role record which
    you are revoking from the user context identified by the `selector`.
  """
  @spec revoke_perm_role(struct(), Types.perm_role_id()) :: :ok | {:error, Exception.t()}
  defdelegate revoke_perm_role(selector, perm_role_id), to: MscmpSystPerms.Protocol
end
