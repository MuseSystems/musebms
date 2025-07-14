# Source File: events.ex
# Location:    musebms/app_server/components/system/mscmp_syst_telemetry/lib/impl/events.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystTelemetry.Impl.Events do
  @moduledoc false

  @event_kinds [
    :log_debug,
    :log_info,
    :log_warn,
    :log_error,
    :api_call_start,
    :api_call_stop
  ]

  ##############################################################################
  #
  # generate_events
  #
  #

  @doc """
  Generates telemetry event names based on component, categories, and event kinds.

  This function provides the canonical mapping from event kinds to actual telemetry
  event names.
  """
  @spec generate_events(atom(), [atom()], [atom()]) :: [list(atom())]
  def generate_events(component, categories, event_kinds) do
    categories
    |> Enum.flat_map(fn category ->
      Enum.map(event_kinds, &build_event_name(component, category, &1))
    end)
  end

  @spec build_event_name(atom(), atom(), atom()) :: list(atom())
  defp build_event_name(component, category, event_kind) do
    case event_kind do
      :log_debug -> [component, category, :log_debug]
      :log_info -> [component, category, :log_info]
      :log_warn -> [component, category, :log_warn]
      :log_error -> [component, category, :log_error]
      :api_call_start -> [component, category, :api_call, :start]
      :api_call_stop -> [component, category, :api_call, :stop]
    end
  end

  ##############################################################################
  #
  # validate_categories
  #
  #

  @spec validate_categories([atom()]) :: :ok | MscmpSystError.Types.parsable_error()
  def validate_categories([_ | _]), do: :ok

  def validate_categories([]),
    do: {:error, {:empty_categories, "At least one category must be provided."}}

  def validate_categories(_categories),
    do: {:error, {:invalid_categories, "Categories must be a non-empty list of atoms."}}

  ##############################################################################
  #
  # validate_event_kinds
  #
  #

  @spec validate_event_kinds([atom()]) :: :ok | MscmpSystError.Types.parsable_error()
  def validate_event_kinds([]) do
    {:error, {:empty_event_kinds, "At least one event kind must be provided."}}
  end

  def validate_event_kinds(event_kinds) do
    case Enum.find(event_kinds, &(&1 not in @event_kinds)) do
      nil ->
        :ok

      invalid_kind ->
        {:error, {:invalid_event_kind, "Event kind #{inspect(invalid_kind)} is unknown."}}
    end
  end
end
