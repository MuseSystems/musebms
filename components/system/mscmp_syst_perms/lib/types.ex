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
  #
  # Note that the ordering of typespecs here is alphabetical.
  #

  @moduledoc """
  Types used by the Perms component.
  """

  @type perm_id() :: Ecto.UUID.t()

  @type perm_name() :: String.t()

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

  @type perm_role_grant_id() :: Ecto.UUID.t()

  @type perm_role_grant_params() :: %{
          optional(:perm_role_id) => perm_role_id(),
          optional(:perm_id) => perm_id(),
          optional(:view_scope) => rights_scope(),
          optional(:maint_scope) => rights_scope(),
          optional(:admin_scope) => rights_scope(),
          optional(:ops_scope) => rights_scope()
        }

  @type perm_role_id() :: Ecto.UUID.t()

  @type perm_role_name() :: String.t()

  @type perm_role_params() :: %{
          optional(:internal_name) => perm_functional_type_name(),
          optional(:display_name) => String.t(),
          optional(:perm_functional_type_id) => perm_functional_type_id(),
          optional(:user_description) => String.t()
        }

  @type perm_functional_type_id() :: Ecto.UUID.t()

  @type perm_functional_type_name() :: String.t()

  @type perm_functional_type_params() :: %{
          optional(:display_name) => String.t(),
          optional(:user_description) => String.t()
        }

  @type rights_scope() :: String.t()
end
