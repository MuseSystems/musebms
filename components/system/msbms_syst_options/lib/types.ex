# Source File: types.ex
# Location:    components/system/msbms_syst_options/lib/types.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystOptions.Types do
  @moduledoc """
  Provides the typespecs and related typing documentation for the
  MsbmsSystOptions module.
  """

  @typedoc """
  Server pools allow for the categorization for dbservers which relate to their
  targeted workload or other operational constraints.

  The available server pools are defined at the top level of the options file
  under the `available_server_pools` configuration point.
  """
  @type server_pool :: String.t()
end
