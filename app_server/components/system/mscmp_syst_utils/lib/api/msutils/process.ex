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
  alias MscmpSystUtils.Impl.Process, as: ProcessUtils
  alias Msutils.Types.Process, as: ProcessTypes

  @doc """
  Looks up a process by its name and returns its PID.

  ## Parameters

    * `name` - The name of the process whose PID is to be retrieved.

  ## Returns

    * `{:ok, pid}` - The PID of the process if found.

    * `{:error, %Mserror.ProcessUtilsError{cause: :process_not_found}}` -
      If the process doesn't exist

    * `{:error, %Mserror.ProcessUtilsError{cause: :invalid_name}}` -
      If the provided name does not comply with `t:Msutils.Types.Process.name/0`
      naming conventions.

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
  @spec whereis(ProcessTypes.name()) :: {:ok, pid()} | {:error, Mserror.ProcessUtilsError.t()}
  def whereis(name) do
    case ProcessUtils.get_pid(name) do
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

  @doc """
  Looks up a process by its name and returns its PID.

  Typically `whereis/2` is called when neither the registry name (or kind) or
  process name are known until runtime.  Since `t:Msutils.Types.Process.name/0`,
  and likewise `t:GenServer.name/0`, values vary in construction based on the
  specific kind of registry, this function provides a convenient way to not have
  to worry about the name construction.  If the registry kind is known at
  compile time, then `whereis/1` is preferred as it should be slightly more
  efficient.

  ## Parameters

    * `registry` - The registry to use for the lookup.
    * `name` - The name of the process whose PID is to be retrieved.

  ## Returns

    * `{:ok, pid}` - The PID of the process if found.

    * `{:error, %Mserror.ProcessUtilsError{cause: :process_not_found}}` -
      If the process doesn't exist

    * `{:error, %Mserror.ProcessUtilsError{cause: :invalid_name}}` -
      If the provided name does not comply with `t:Msutils.Types.Process.name/0`
      naming conventions.

  ## Examples

  A simple local process name lookup:

      iex> {:ok, pid} = Agent.start_link(fn -> %{} end, name: :example2_local_name)
      iex> {:ok, ^pid} = Msutils.Process.whereis(:local, :example2_local_name)

  A global process name lookup:

      iex> {:ok, global_pid} = Agent.start_link(fn -> %{} end, name: {:global, :example2_global_process})
      iex> {:ok, ^global_pid} = Msutils.Process.whereis(:global, :example2_global_process)

  A via process name lookup:

      iex> {:ok, via_pid} = Agent.start_link(fn -> %{} end, name: {:via, Registry, {MscmpSystUtils.TestRegistry, :example2_via_process}})
      iex> {:ok, ^via_pid} = Msutils.Process.whereis({Registry, MscmpSystUtils.TestRegistry}, :example2_via_process)

  Attempted lookup of a non-existent process:

      iex> {:error, error} = Msutils.Process.whereis(:local, :nonexistent_process)
      iex> %Mserror.ProcessUtilsError{kind: :lookup, cause: :process_not_found} = error

  Attempted lookup of an invalid or unsupported process name:

      iex> {:error, error} = Msutils.Process.whereis(:local, {:invalid, :name})
      iex> %Mserror.ProcessUtilsError{kind: :lookup, cause: :invalid_name} = error

  """
  @spec whereis(ProcessTypes.registry(), term()) ::
          {:ok, pid()} | {:error, Mserror.ProcessUtilsError.t()}
  def whereis(registry, name) do
    case ProcessUtils.get_pid(registry, name) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, _cause} = error ->
        {:error,
         Mserror.ProcessUtilsError.new(:lookup, "Failed to lookup process",
           parse_error: error,
           context: %ErrorContext{
             origin: {__MODULE__, :whereis, 2},
             parameters: %{registry: registry, name: name}
           }
         )}
    end
  end

  @doc """
  Registers the current process under the given name.

  This function must be called from within the process that is to be registered.
  Attempting to register a process from outside that process will fail.

  ## Parameters

    * `name` - The name under which to register the current process.

  ## Returns

    * `:ok` - The process was successfully registered.

    * `{:error, %Mserror.ProcessUtilsError{cause: :registration_failed}}` -
      If the registration failed.

    * `{:error, %Mserror.ProcessUtilsError{cause: :invalid_name}}` -
      If the provided name does not comply with `t:Msutils.Types.Process.name/0`
      naming conventions.

  ## Examples

  Register a process locally:

      iex> {:ok, pid} = Agent.start_link(fn ->
      ...>   Msutils.Process.register(:my_process)
      ...>   %{}
      ...> end)
      iex> {:ok, ^pid} = Msutils.Process.whereis(:my_process)

  Register a process globally:

      iex> {:ok, pid} = Agent.start_link(fn ->
      ...>   Msutils.Process.register({:global, :my_global_process})
      ...>   %{}
      ...> end)
      iex> {:ok, ^pid} = Msutils.Process.whereis({:global, :my_global_process})

  Register a process via a registry:

      iex> {:ok, pid} = Agent.start_link(fn ->
      ...>   Msutils.Process.register({:via, Registry, {MscmpSystUtils.TestRegistry, :my_process}})
      ...>   %{}
      ...> end)
      iex> {:ok, ^pid} = Msutils.Process.whereis({:via, Registry, {MscmpSystUtils.TestRegistry, :my_process}})

  Attempt to register with an already taken name:

      iex> {:ok, pid1} = Agent.start_link(fn ->
      ...>   Msutils.Process.register(:taken_name)
      ...>   %{}
      ...> end)
      iex> {:ok, ^pid1} = Msutils.Process.whereis(:taken_name)
      iex> {:ok, pid2} = Agent.start_link(fn ->
      ...>   {:error, error} = Msutils.Process.register(:taken_name)
      ...>   %Mserror.ProcessUtilsError{kind: :registration, cause: :registration_failed} = error
      ...>   %{}
      ...> end)
  """
  @spec register(ProcessTypes.name()) :: :ok | {:error, Mserror.ProcessUtilsError.t()}
  def register(name) do
    case ProcessUtils.register(name) do
      :ok ->
        :ok

      {:error, _cause} = error ->
        {:error,
         Mserror.ProcessUtilsError.new(:registration, "Failed to register process",
           parse_error: error,
           context: %ErrorContext{
             origin: {__MODULE__, :register, 1},
             parameters: %{name: name}
           }
         )}
    end
  end

  @doc """
  Registers the current process under the given registry and name.

  This function must be called from within the process that is to be registered.
  Attempting to register a process from outside that process will fail.

  This function provides a convenient way to register processes when the registry and
  name are known separately at runtime.

  ## Parameters

    * `registry` - The registry to use for registration.
    * `name` - The name under which to register the current process.

  ## Returns

    * `:ok` - The process was successfully registered.

    * `{:error, %Mserror.ProcessUtilsError{cause: :registration_failed}}` -
      If the registration failed.

    * `{:error, %Mserror.ProcessUtilsError{cause: :invalid_name}}` -
      If the provided registry or name combination is invalid.

  ## Examples

  Register a process locally:

      iex> {:ok, pid} = Agent.start_link(fn ->
      ...>   Msutils.Process.register(:local, :my_process)
      ...>   %{}
      ...> end)
      iex> {:ok, ^pid} = Msutils.Process.whereis(:local, :my_process)

  Register a process globally:

      iex> {:ok, pid} = Agent.start_link(fn ->
      ...>   Msutils.Process.register(:global, :my_global_process)
      ...>   %{}
      ...> end)
      iex> {:ok, ^pid} = Msutils.Process.whereis(:global, :my_global_process)

  Register a process via a registry:

      iex> {:ok, pid} = Agent.start_link(fn ->
      ...>   Msutils.Process.register({Registry, MscmpSystUtils.TestRegistry}, :my_process)
      ...>   %{}
      ...> end)
      iex> {:ok, ^pid} = Msutils.Process.whereis({Registry, MscmpSystUtils.TestRegistry}, :my_process)
  """
  @spec register(ProcessTypes.registry(), term()) ::
          :ok | {:error, Mserror.ProcessUtilsError.t()}
  def register(registry, name) do
    case ProcessUtils.register(registry, name) do
      :ok ->
        :ok

      {:error, _cause} = error ->
        {:error,
         Mserror.ProcessUtilsError.new(:registration, "Failed to register process",
           parse_error: error,
           context: %ErrorContext{
             origin: {__MODULE__, :register, 2},
             parameters: %{registry: registry, name: name}
           }
         )}
    end
  end
end
