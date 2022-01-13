# Source File: data_access_supervisor.ex
# Location:    musebms/lib/msbms/system/data_access_supervisor.ex
# Project:     musebms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com  : : https: //muse.systems
defmodule Msbms.System.DataAccessSupervisor do
  @moduledoc false
  use Supervisor

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  @spec init(any) :: {:ok, {%{intensity: any, period: any, strategy: any}, list}}
  def init(_init_arg) do
    children = [
      {Registry, keys: :unique, name: Msbms.System.RepoRegistry},
      {DynamicSupervisor, name: Msbms.System.RepoSupervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
