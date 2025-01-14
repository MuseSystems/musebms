# Source File: process_utils.ex
# Location:    musebms/app_server/components/system/mscmp_syst_utils/lib/impl/process_utils.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystUtils.Impl.Process do
  @moduledoc false

  import Msutils.Guards, only: [is_reg_atom: 1]

  alias Msutils.Types.Process, as: ProcessTypes

  ##############################################################################
  #
  # get_pid
  #
  #

  @spec get_pid(ProcessTypes.name()) ::
          {:ok, pid()} | {:error, MscmpSystError.Types.parsable_error()}
  def get_pid(name) when is_pid(name), do: {:ok, name}

  def get_pid(name) when is_reg_atom(name) do
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

  @spec get_pid(ProcessTypes.registry(), term()) ::
          {:ok, pid()} | {:error, MscmpSystError.Types.parsable_error()}
  def get_pid(_, name) when is_pid(name), do: {:ok, name}
  def get_pid(:local, name), do: get_pid(name)
  def get_pid(:global, name), do: get_pid({:global, name})

  def get_pid({registry_module, registry_name}, name),
    do: get_pid({:via, registry_module, {registry_name, name}})

  def get_pid(_, _invalid_name),
    do: {:error, {:invalid_name, "The provided registry or name is not valid."}}

  ##############################################################################
  #
  # register
  #
  #

  @spec register(ProcessTypes.name()) ::
          :ok | {:error, MscmpSystError.Types.parsable_error()}
  def register(name) when is_reg_atom(name) do
    try do
      Process.register(self(), name)
      :ok
    rescue
      ArgumentError ->
        {:error,
         {:registration_failed,
          "Registering the current process into the local process registry failed."}}
    end
  end

  def register({:global, name}) do
    case :global.register_name(name, self()) do
      :yes ->
        :ok

      :no ->
        {:error,
         {:registration_failed,
          "Registering the current process into the global registry failed."}}
    end
  end

  def register({:via, module, name}) do
    case module.register_name(name, self()) do
      :yes ->
        :ok

      :no ->
        {:error,
         {:registration_failed, "Failed registering the current process using a via tuple."}}
    end
  end

  def register(_invalid_name),
    do: {:error, {:invalid_name, "The provided name is not a valid process name."}}

  @spec register(ProcessTypes.registry(), term()) ::
          :ok | {:error, MscmpSystError.Types.parsable_error()}
  def register(:local, name) do
    try do
      Process.register(self(), name)
      :ok
    rescue
      ArgumentError ->
        {:error, {:name_already_registered, "The name is already registered."}}
    end
  end

  def register(:global, name), do: register({:global, name})

  def register({registry_module, registry_name}, name),
    do: register({:via, registry_module, {registry_name, name}})

  def register(_, _name),
    do: {:error, {:invalid_name, "The provided registry or name is not valid."}}
end
