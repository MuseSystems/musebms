# Source File: bootstrap_live.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp_web/lib/msapp_mcp_web/live/bootstrap_live.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsappMcpWeb.BootstrapLive do
  use MsappMcpWeb, :live_view

  @moduledoc false

  def mount(_, _, socket) do
    changeset =
      MsdataApi.McpBootstrap.changeset(%MsdataApi.McpBootstrap{})
      |> then(&if connected?(socket), do: Map.put(&1, :action, :insert), else: &1)

    starting_params = %{
      current_step: :welcome,
      page_title: "New System Startup",
      form_data_def: MsdataApi.McpBootstrap.get_data_definition(),
      disallowed_list_state:
        determine_disallowed_list_state(MssubMcp.disallowed_passwords_populated?()),
      records_state: determine_records_state(changeset),
      changeset: changeset
    }

    {:ok, assign(socket, starting_params)}
  end

  def handle_event("validate", %{"mcp_bootstrap" => form_data}, socket) do
    changeset =
      MsdataApi.McpBootstrap.changeset(%MsdataApi.McpBootstrap{}, form_data)
      |> Map.put(:action, :insert)

    {:noreply,
     assign(socket, changeset: changeset, records_state: determine_records_state(changeset))}
  end

  def handle_event("save", %{"mcp_bootstrap" => form_data}, socket) do
    Task.Supervisor.async_nolink(
      MsappMcpWeb.TaskSupervisor,
      fn ->
        form_data
        |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
        |> MsappMcp.Impl.Bootstrap.process_bootstrap_data()

        send(self(), :records_saved)
      end
    )

    {:noreply, assign(socket, current_step: :finish)}
  end

  def handle_event("change_step", %{"step" => step}, socket) do
    {:noreply, assign(socket, current_step: String.to_existing_atom(step))}
  end

  def handle_event("load_disallowed", _params, socket) do
    Task.Supervisor.async_nolink(
      MsappMcpWeb.TaskSupervisor,
      fn ->
        case MsappMcp.load_disallowed_passwords() do
          :ok ->
            send(self(), :disallowed_list_loaded)

          error ->
            raise MscmpSystError,
              code: :undefined_error,
              message: "Unexpected failure loading Disallowed Passwords starter list.",
              cause: error
        end
      end,
      shutdown: 300_000
    )

    {:noreply, assign(socket, disallowed_list_state: :processing)}
  end

  def handle_event("finish_redirect", params, socket) do
    {:noreply, redirect(socket, to: ~p"/login")}
  end

  def handle_info({ref, :disallowed_list_loaded}, socket) do
    Process.demonitor(ref, [:flush])

    disallowed_state =
      MssubMcp.disallowed_passwords_populated?() |> determine_disallowed_list_state()

    socket =
      socket
      |> assign(disallowed_list_state: disallowed_state)
      |> then(&if disallowed_state == :message, do: assign(&1, current_step: :records), else: &1)

    {:noreply, socket}
  end

  def handle_info({ref, :records_saved}, socket) do
    Process.demonitor(ref, [:flush])
    {:noreply, assign(socket, records_state: :message)}
  end

  def handle_info({:DOWN, _, _, _, _}, socket), do: {:noreply, socket}

  defp determine_records_state(%Ecto.Changeset{valid?: true}), do: :action
  defp determine_records_state(%Ecto.Changeset{valid?: false}), do: :message

  defp determine_disallowed_list_state(true), do: :message
  defp determine_disallowed_list_state(false), do: :action
end
