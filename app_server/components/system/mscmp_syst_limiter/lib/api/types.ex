# Source File: types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_limiter/lib/api/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystLimiter.Types do
  #
  # Note that the ordering of typespecs here is alphabetical.
  #

  @moduledoc """
  Defines public types for use with the MscmpSystLimiter module.
  """

  @typedoc """
  A unique identifier for the specific counter within the requested counter
  type.
  """
  @type counter_id() :: String.t()

  @typedoc """
  The name of the counter which is derived from the counter type and counter
  id values.
  """
  @type counter_name() :: String.t()

  @typedoc """
  The kind of activity being rate limited.

  For example, a counter type might be `:login_attempt`.
  """
  @type counter_type() :: atom()

  @typedoc """
  The type of value expected for the table which holds the counters.
  """
  @type counter_table_name() :: atom()
end
