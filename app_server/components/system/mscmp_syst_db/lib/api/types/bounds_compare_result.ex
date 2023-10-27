# Source File: bounds_compare_result.ex
# Location:    musebms/app_server/components/system/mscmp_syst_db/lib/api/types/bounds_compare_result.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.Types.BoundsCompareResult do
  @moduledoc """
  The comparison operators for both the lower and upper bounds of a range type.

  There are cases where normal comparisons are too coarse-grained to provide a
  meaningful result when dealing with ranges.  In these cases you need the
  detailed lower/upper comparison results.
  """

  @enforce_keys [:lower_comparison, :upper_comparison]
  defstruct [:lower_comparison, :upper_comparison]

  @typedoc """
  The comparison operators for both the lower and upper bounds of a range type.

  See `MscmpSystDb.Types.BoundsCompareResult` for more.
  """
  @type t :: %__MODULE__{
          lower_comparison: MscmpSystDb.Types.db_type_comparison_operators(),
          upper_comparison: MscmpSystDb.Types.db_type_comparison_operators()
        }
end
