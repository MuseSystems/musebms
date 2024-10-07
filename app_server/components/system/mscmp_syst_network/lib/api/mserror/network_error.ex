# Source File: network_error.ex
# Location:    musebms/app_server/components/system/mscmp_syst_network/lib/api/mserror/network_error.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Mserror.NetworkError do
  @moduledoc """
  Defines errors and related metadata for MscmpSystNetwork component errors.
  """

  use MscmpSystError,
    kinds: [
      parse_error: """
      Indicates that there were problems attempting to parse an IP Address or
      Network represented as a string.
      """,
      invalid_network: """
      The value provided does not represent a valid network.
      """
    ],
    component: MscmpSystNetwork
end
