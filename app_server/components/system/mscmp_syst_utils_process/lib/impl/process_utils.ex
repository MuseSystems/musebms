# Source File: process_utils.ex
# Location:    musebms/app_server/components/system/mscmp_syst_utils_process/lib/impl/process_utils.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystUtilsProcess.Impl.Process do
  @moduledoc false

  ##############################################################################
  #
  # get_pid
  #
  #

  @spec get_pid(GenServer.name()) ::
          {:ok, pid()} | {:error, {:process_not_found | :invalid_name, String.t()}}
  def get_pid(name) when is_pid(name), do: {:ok, name}

  def get_pid(name) when is_atom(name) do
    case Process.whereis(name) do
      pid when is_pid(pid) -> {:ok, pid}
      nil -> {:error, {:process_not_found, "The process was not found locally."}}
    end
  end

  def get_pid({:global, name}) do
    case :global.whereis_name(name) do
      pid when is_pid(pid) ->
        {:ok, pid}

      :undefined ->
        {:error, {:process_not_found, "The process was not found in the :global registry."}}
    end
  end

  def get_pid({:via, module, name}) do
    case module.whereis_name(name) do
      pid when is_pid(pid) ->
        {:ok, pid}

      :undefined ->
        {:error, {:process_not_found, "The process was not found in the named process registry."}}
    end
  end

  def get_pid(_invalid_name),
    do: {:error, {:invalid_name, "The provided name is not a valid process name."}}
end
