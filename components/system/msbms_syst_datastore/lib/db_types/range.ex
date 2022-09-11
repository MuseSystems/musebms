# Source File: db_types.ex
# Location:    musebms/components/system/msbms_syst_datastore/lib/db_types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defprotocol MsbmsSystDatastore.DbTypes.Range do
  alias MsbmsSystDatastore.Types

  @spec compare(t, t) :: Types.db_type_comparison_operators()
  def(compare(left, right))

  @spec test_compare(t, t, Types.db_type_comparison_operators()) :: boolean()
  def(test_compare(left, right, operator))
end
