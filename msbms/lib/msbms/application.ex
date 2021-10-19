# Source File: application.ex
# Location:    musebms/lib/msbms/application.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from thrid parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com  : : https: //muse.systems

defmodule Msbms.Application do
  @moduledoc false
  use Application

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    children = [
      Msbms.System.DataAccessSupervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
