# Source File: types.ex
# Location:    musebms/components/system/mscmp_syst_perms/lib/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystPerms.Types do
  @moduledoc """
  Types used by the Perms component.
  """

  #
  # Note that the ordering of typespecs here is alphabetical.
  #

  @typedoc """
  Defines the return value type for certain functions returning existing
  Permission Grants.

  Functions which retrieve Permission Grant Role records for specific selection
  criteria will often return a simplified value indicating the Permissions
  granted including the Scope granted for each of the Permission's Rights.

  In some cases a specific requested Permission may not be granted at all.  In
  this scenario, an Msdata.SystPermRoleGrants role record won't exist, but the
  function should still return a `t:perm_grants/0` value with the default Scopes
  for the requested Permission's Rights (usually `:deny`).

  The keys for this map should be `t:perm_name/0` value of the Permission record
  in question.
  """
  @type perm_grants() :: %{required(perm_name()) => MscmpSystPerms.Types.PermGrantValue.t()}

  @typedoc """
  The type of the Permission record ID value.
  """
  @type perm_id() :: Ecto.UUID.t()

  @typedoc """
  The Internal Name type for Permission records.
  """
  @type perm_name() :: atom()

  @typedoc """
  A map defining the data used in creating or updating Permission records.

  For additional context and documentation of concepts discussed here and below
  see the top level `MscmpSystPerms` documentation.

  ## Attributes

    * `internal_name` - a candidate key useful for programmatic references to
    individual records.  This is required data and the value must be unique in
    the system.  Update operations may only change this attribute when the
    record is not system defined.

    * `display_name` - a candidate key used in user interface representations of
    the record.  This is required data and the value must be unique in the
    system.  This value may be updated for both system and user defined records
    so long as the new value remains unique in the system.


    * `user_description` - a custom, user defined description which overrides
    the system description, if it exists.  This attribute is optional and may be
    set `nil` in which case the system description will be used.  This value may
    be changed for system defined Permission records.


    * `perm_functional_type_id` - identifies the Permission Functional Type of
    which this Permission record is part.  This value is required data and may
    only be set during the creation of user defined permissions.  This attribute
    may not be changed for system defined Permission records or after record
    creation.


    * `view_scope_options` - a list of `t:MscmpSystPerms.Types.rights_scope/0`
    values defining the Permission record's recognized Scopes for its View
    Right.  A value for this attribute must be set to a list containing at least
    one Scope; if the View Right is not used by the Permission then the value of
    this attribute should be set to `["unused"]`.  This attribute may only be
    updated for user defined Permission records.


    * `maint_scope_options` - a list of `t:MscmpSystPerms.Types.rights_scope/0`
    values defining the Permission record's recognized Scopes for its
    Maintenance Right.  A value for this attribute must be set to a list
    containing at least one Scope; if the Maintenance Right is not used by the
    Permission then the value of this attribute should be set to `["unused"]`.
    This attribute may only be updated for user defined Permission records.

    * `admin_scope_options` - a list of `t:MscmpSystPerms.Types.rights_scope/0`
    values defining the Permission record's recognized Scopes for its
    Administration Right.  A value for this attribute must be set to a list
    containing at least one Scope; if the Administration Right is not used by
    the Permission then the value of this attribute should be set to
    `["unused"]`.  This attribute may only be updated for user defined
    Permission records.


    * `ops_scope_options` - a list of `t:MscmpSystPerms.Types.rights_scope/0`
    values defining the Permission record's recognized Scopes for its Operations
    Right.  A value for this attribute must be set to a list containing at least
    one Scope; if the Operations Right is not used by the Permission then the
    value of this attribute should be set to `["unused"]`.  This attribute may
    only be updated for user defined Permission records.

  """
  @type perm_params() :: %{
          optional(:internal_name) => perm_name(),
          optional(:display_name) => String.t(),
          optional(:user_description) => String.t(),
          optional(:perm_functional_type_id) => perm_functional_type_id(),
          optional(:view_scope_options) => list(rights_scope()),
          optional(:maint_scope_options) => list(rights_scope()),
          optional(:admin_scope_options) => list(rights_scope()),
          optional(:ops_scope_options) => list(rights_scope())
        }

  @typedoc """
  Establishes the type of the Permission Role Grant record.
  """
  @type perm_role_grant_id() :: Ecto.UUID.t()

  @typedoc """
  A map of attributes used in creating or updating Permission Role Grant
  records.

  Permission Role Grant records are considered either "System Defined" or
  "User Defined" based on their parent `Msdata.SystPermRoles` record's
  `syst_defined` value.  The usage of some attributes described below will
  depend on that parent record definition.

  ## Attributes

    * `perm_role_id` - a `t:MscmpSystPerms.Types.perm_role_id/0` reference to
    this record's parent Permission Role.  On user defined Permission Role Grant
    creation this is is a required value.  This value may not be changed after
    record creation.

    * `perm_id` - a `t:MscmpSystPerms.Types.perm_id/0` reference to the
    Permission record for the Permission being granted by the Permission Role.
    On user defined Permission Role Grant creation this is is a required value.
    This value may not be changed after record creation time.  Note that all
    Permissions being granted by the Permission Role Grant record must share the
    same Permission Functional Type as the Permission Role Grant's parent
    Permission Role record.

    * `view_scope` - the `t:MscmpSystPerms.Types.rights_scope` value of the View
    Right being granted by the Permission Role Grant record.  This value is
    required and must be one of the available Scopes defined by the Permission
    being granted.  This value may not be changed if the Permission Role Grant
    record is considered system defined.

    * `maint_scope` - the `t:MscmpSystPerms.Types.rights_scope` value of the
    Maintenance Right being granted by the Permission Role Grant record.  This
    value is required and must be one of the available Scopes defined by the
    Permission being granted.  This value may not be changed if the Permission
    Role Grant record is considered system defined.

    * `admin_scope` - the `t:MscmpSystPerms.Types.rights_scope` value of the
    Administration Right being granted by the Permission Role Grant record.
    This value is required and must be one of the available Scopes defined by
    the Permission being granted.  This value may not be changed if the
    Permission Role Grant record is considered system defined.

    * `ops_scope` - the `t:MscmpSystPerms.Types.rights_scope` value of the
    Operations Right being granted by the Permission Role Grant record.  This
    value is required and must be one of the available Scopes defined by the
    Permission being granted.  This value may not be changed if the Permission
    Role Grant record is considered system defined.

  """
  @type perm_role_grant_params() :: %{
          optional(:perm_role_id) => perm_role_id(),
          optional(:perm_id) => perm_id(),
          optional(:view_scope) => rights_scope(),
          optional(:maint_scope) => rights_scope(),
          optional(:admin_scope) => rights_scope(),
          optional(:ops_scope) => rights_scope()
        }

  @typedoc """
  The data type of the record ID for the Permission Role record.
  """
  @type perm_role_id() :: Ecto.UUID.t()

  @typedoc """
  The data type of the Permission Role record Internal Name value.
  """
  @type perm_role_name() :: String.t()

  @typedoc """
  A map of attributes describing Permission Role record values for use in record
  creation and update.

  ## Attributes

    * `internal_name` - a record candidate key used to identify the record in
    programmatic contexts.  The Internal Name value is a required data value and
    it must be unique in the system.  User defined Permission Role records may
    change this value so long as the uniqueness requirement is met.  System
    defined Permission Role records may not change this value.

    * `display_name` - a record candidate key used to identify the record in
    user interface contexts.  A non-nil, system unique value is required for the
    attribute.  This value may be changed for both user defined and system
    defined Permission Role records so long as the uniqueness requirement is
    observed.

    * `perm_functional_type_id` - a required value which establishes for which
    Permission Functional Type the Permission Role is being defined.  Permission
    Roles will only be able to grant the Rights of Permissions of the same
    Permission Functional Type.  This value may only be set at user defined
    Permission Role record creation time and may not be updated later.

    * `user_description` - a custom, user defined description which overrides
    the system description, if any exists.  This attribute is optional and may
    be set `nil` in which case the system description will be used.  This value
    may updated for system defined Permission Role records.

  """
  @type perm_role_params() :: %{
          optional(:internal_name) => perm_functional_type_name(),
          optional(:display_name) => String.t(),
          optional(:perm_functional_type_id) => perm_functional_type_id(),
          optional(:user_description) => String.t()
        }

  @typedoc """
  The data type of the Permission Functional Type record.
  """
  @type perm_functional_type_id() :: Ecto.UUID.t()

  @typedoc """
  The data type of the Permission Functional Type Internal Name value.
  """
  @type perm_functional_type_name() :: String.t()

  @typedoc """
  A map of user updatable Permission Functional Type attributes.

  While all Permission Functional Type records are considered system defined
  which prevents most data changes, those that effect the display of the record
  to system users are still permitted.

  ## Attributes

    * `display_name` - a record candidate key displayed in user interfaces as
    the name of the record.  This value is required, may not be set `nil`, and
    must be unique in the system.

    * `user_description` - a custom, user defined description which overrides
    the system description, if any exists.  This attribute is optional and may
    be set `nil` in which case the system description will be used.

  """
  @type perm_functional_type_params() :: %{
          optional(:display_name) => String.t(),
          optional(:user_description) => String.t()
        }

  @typedoc """
  Defines the system recognized Scopes which can be assigned to Permission
  Rights options.

  Note that any given Permission may support all or only some of these Scopes.
  See the description of any specific Permission to understand which specific
  Scopes it supports.

  ## Scopes

    * `:deny` - in some cases it is desirable to grant some Rights of a
    Permission, but not others.  The `:deny` Scope supports not granting all
    rights of a Permission when other Rights are granted.

    * `:same_user` - the Right of the Permission is granted to the user, but
    is limited to records for which they are designated as owner is some way.
    Precisely how this designation is determined will be specified by each
    function recognizing this Scope of Rights.

    * `:same_group` - the Right of the Permission is granted to the user, but
    is limited to records for which they are designated belonging to a group or
    groups to which the user also has rights. Precisely how this determination
    made will depend on the implementation details of the functionality in
    question.

    * `:all` - the Right of the Permission is granted to the user without any
    Scope dependent limitations.

    * `:unused` - when a permission does not support one of the standard Rights,
    this value is assigned to the Right's options and any Permission Role Grant
    for that Right.

  """
  @type rights_scope() :: :deny | :same_user | :same_group | :all | :unused
end
