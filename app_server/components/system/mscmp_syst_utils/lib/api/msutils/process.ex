# Source File: api/msutils/process.ex
# Location:    musebms/app_server/components/system/mscmp_syst_utils/lib/api/msutils/process.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msutils.Process do
  @moduledoc """
  This module provides utilities for working with processes.
  """

  alias MscmpSystError.Types.Context, as: ErrorContext
  alias MscmpSystUtils.Impl.Process

  @doc """
  Looks up a process by its name and returns its PID.

  ## Parameters

    * `name` - A `t:GenServer.name/0` style name (atom, {:global, term},
      {:via, module, term}, or pid)

  ## Returns

    * `{:ok, pid}` - The PID of the process if found

    * `{:error, %Mserror.ProcessUtilsError{cause: :process_not_found}}` -
      If the process doesn't exist

    * `{:error, %Mserror.ProcessUtilsError{cause: :invalid_name}}` -
      If the provided name does not comply with `t:GenServer.name/0` naming
      conventions.

  ## Examples

  A simple local process name lookup:

      iex> {:ok, pid} = Agent.start_link(fn -> %{} end, name: :example_local_name)
      iex> {:ok, ^pid} = Msutils.Process.whereis(:example_local_name)

  A global process name lookup:

      iex> {:ok, global_pid} = Agent.start_link(fn -> %{} end, name: {:global, :example_global_process})
      iex> {:ok, ^global_pid} = Msutils.Process.whereis({:global, :example_global_process})

  A via process name lookup:
      iex> {:ok, via_pid} = Agent.start_link(fn -> %{} end, name: {:via, Registry, {MscmpSystUtils.TestRegistry, :example_via_process}})
      iex> {:ok, ^via_pid} = Msutils.Process.whereis({:via, Registry, {MscmpSystUtils.TestRegistry, :example_via_process}})

  Attempted lookup of a non-existent process:

      iex> {:error, error} = Msutils.Process.whereis(:nonexistent_process)
      iex> %Mserror.ProcessUtilsError{kind: :lookup, cause: :process_not_found} = error

  Attempted lookup of an invalid or unsupported process name:

      iex> {:error, error} = Msutils.Process.whereis({:invalid, :name})
      iex> %Mserror.ProcessUtilsError{kind: :lookup, cause: :invalid_name} = error

  """
  @spec whereis(GenServer.name()) :: {:ok, pid()} | {:error, Mserror.ProcessUtilsError.t()}
  def whereis(name) do
    case Process.get_pid(name) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, _cause} = error ->
        {:error,
         Mserror.ProcessUtilsError.new(:lookup, "Failed to lookup process",
           parse_error: error,
           context: %ErrorContext{
             origin: {__MODULE__, :whereis, 1},
             parameters: %{name: name}
           }
         )}
    end
  end
end
