# Source File: datastore.ex
# Location:    musebms/subsystems/mssub_mcp/lib/runtime/datastore.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcp.Runtime.Datastore do
  @moduledoc false

  use MssubMcp.Macros

  alias MssubMcp.Runtime

  mcp_constants()

  @default_datastore_type "mssub_mcp"
  @default_owner_name "mssub_mcp_owner"
  @default_app_access_role_name "mssub_mcp_app_access"

  def datastore_update_child_spec(opts) do
    %{
      id: __MODULE__.Updater,
      start: {MssubMcp.Runtime.Datastore, :start_link, [opts]},
      type: :supervisor,
      restart: :transient
    }
  end

  @spec start_link(Keyword.t()) :: :ignore | {:error, MscmpSystError.t() | any()}
  def start_link(opts) do
    case datastore_update(opts) do
      :ok -> :ignore
      error -> error
    end
  end

  @spec datastore_update(Keyword.t()) :: :ok | {:error, MscmpSystError.t() | any()}
  def datastore_update(opts) do
    opts =
      MscmpSystUtils.resolve_options(opts,
        datastore_type: @default_datastore_type,
        owner_name: @default_owner_name,
        app_access_role_name: @default_app_access_role_name,
        name: opts[:datastore_name]
      )

    startup_options = opts[:startup_options]
    migrations_root_dir = opts[:migrations_root_dir]

    with %{} = datastore_options <- Runtime.Options.get_datastore_options(startup_options, opts),
         {:ok, :ready, _} = datastore_state <- process_bootstrap_sequence(datastore_options),
         {:ok, :ready, _} <- process_context_changes(datastore_state, datastore_options, opts),
         {:ok, _} <-
           MscmpSystDb.upgrade_datastore(
             datastore_options,
             opts[:datastore_type],
             [ms_owner: opts[:owner_name], ms_appusr: opts[:app_access_role_name]],
             migrations_root_dir: migrations_root_dir
           ) do
      :ok
    else
      error -> {:error, error}
    end
  end

  defp process_bootstrap_sequence(datastore_options) do
    datastore_options
    |> MscmpSystDb.get_datastore_state()
    |> maybe_bootstrap_datastore(datastore_options)
  end

  defp maybe_bootstrap_datastore({:ok, :not_found, _}, datastore_options) do
    MscmpSystDb.create_datastore(datastore_options)
  end

  defp maybe_bootstrap_datastore({:ok, :ready, _} = datastore_state, _datastore_options),
    do: datastore_state

  defp maybe_bootstrap_datastore({:error, cause}, _datastore_options) do
    raise MscmpSystError,
      code: :undefined_error,
      message: "Failed retrieving MCP Datastore state.",
      cause: cause
  end

  defp process_context_changes({:ok, :ready, _} = datastore_state, datastore_options, opts) do
    {_, _, context_states} = datastore_state

    additional_contexts =
      datastore_options.contexts
      |> Enum.reject(
        &Enum.find(context_states, fn state ->
          state.context == &1.context_name or &1.context_name == nil
        end)
      )

    removal_contexts =
      context_states
      |> Enum.reject(
        &Enum.find(datastore_options.contexts, fn state ->
          state.context_name == &1.context
        end)
      )

    with {:ok, _} <-
           MscmpSystDb.create_datastore_contexts(datastore_options, additional_contexts),
         :ok <- MscmpSystDb.drop_datastore_contexts(datastore_options, removal_contexts) do
      MscmpSystDb.get_datastore_state(datastore_options, opts)
    end
  end

  @spec child_spec(Keyword.t()) :: Supervisor.child_spec()
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {MssubMcp.Runtime.Datastore, :start_link, [opts]},
      type: :supervisor,
      restart: :transient
    }
  end
end
