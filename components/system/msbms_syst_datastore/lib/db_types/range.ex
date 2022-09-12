# Source File: range.ex
# Location:    musebms/components/system/msbms_syst_datastore/lib/db_types/range.ex
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

  @moduledoc """
  Defines the common functions which should be implemented for all database
  range types.
  """
  @spec bounds_compare(t, t) :: Types.bounds_compare_result()
  def(bounds_compare(left, right))
end
