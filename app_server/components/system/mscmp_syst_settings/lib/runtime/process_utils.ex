# Source File: process_utils.ex
# Location:    musebms/components/system/mscmp_syst_settings/lib/runtime/process_utils.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystSettings.Runtime.ProcessUtils do
  @moduledoc false

  ######
  #
  # Small utility functions to deal with the Process dependent state.
  #
  ######

  # Greatly inspired by what Ecto.Repo is doing to make dynamic repos work.
  # Our use case is similar in that our service naming is typically static for
  # the life of the process where it is set and may be called on frequently for
  # the life of the process.  This feels like the appropriate use of the Process
  # Dictionary and it doesn't feel like abusive of use of process global state.

  @spec put_settings_service(MscmpSystSettings.Types.service_name() | nil) ::
          MscmpSystSettings.Types.service_name() | nil
  def put_settings_service(service_name),
    do: Process.put({__MODULE__, :service_name}, service_name)

  @spec get_settings_service() :: MscmpSystSettings.Types.service_name() | nil
  def get_settings_service, do: Process.get({__MODULE__, :service_name})
end
