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
  alias MssubMcp.Runtime

  @moduledoc false

  use MssubMcp.Macros

  mcp_constants()

  @default_owner_name "mssub_mcp_owner"
  @default_app_access_role_name "mssub_mcp_app_access"

  def start_link(opts) do
    opts =
      MscmpSystUtils.resolve_options(opts,
        owner_name: @default_owner_name,
        app_access_role_name: @default_app_access_role_name,
        name: opts[:datastore_name]
      )

    with %{} = datastore_options <- Runtime.Options.get_datastore_options(opts),
         {:ok, :ready, _} = datastore_state <- process_bootstrap_sequence(datastore_options),
         {:ok, :ready, _} <- process_context_changes(datastore_state, datastore_options, opts),
         {:ok, _} <-
           MscmpSystDb.upgrade_datastore(
             datastore_options,
             "mssub_mcp",
             [ms_owner: opts[:owner_name], ms_appusr: opts[:app_access_role_name]],
             migrations_root_dir: Path.join([:code.priv_dir(:mssub_mcp), "database"])
           ) do
      start_link_opts = [{:datastore_options, datastore_options} | opts]
      MscmpSystDb.Datastore.start_link(start_link_opts)
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
