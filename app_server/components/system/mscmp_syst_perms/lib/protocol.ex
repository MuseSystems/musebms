# Source File: protocol.ex
# Location:    musebms/components/system/mscmp_syst_perms/lib/protocol.ex
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
  alias MscmpSystPerms.Types

  @moduledoc """
  Defines a common API for the various higher level implementations which use
  `MscmpSystPerms` as a core for permission management.
  """

  @doc """
  Returns the Permission Role Grant records for the given selector.

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
  @spec get_perm_grants(struct(), Keyword.t()) ::
          {:ok, Types.perm_grants()} | {:error, MscmpSystError.t()}
  def get_perm_grants(selector, opts)
end
