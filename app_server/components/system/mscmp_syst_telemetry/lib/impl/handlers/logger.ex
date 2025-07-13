# Source File: logger.ex
# Location:    musebms/app_server/components/system/mscmp_syst_telemetry/lib/impl/handlers/logger.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystTelemetry.Impl.Handlers.Logger do
  @moduledoc false

  alias MscmpSystError.Types

  require Logger

  ##############################################################################
  #
  # handle_event
  #
  #

  @spec handle_event(
          :telemetry.event_name(),
          :telemetry.event_measurements(),
          :telemetry.event_metadata(),
          :telemetry.handler_config()
        ) :: :ok
  def handle_event(
        [component, category, :event_debug],
        _measurements,
        %{} = metadata,
        _config
      ) do
    log_message(:debug, component, category, metadata)
  end

  def handle_event(
        [component, category, :event_info],
        _measurements,
        %{} = metadata,
        _config
      ) do
    log_message(:info, component, category, metadata)
  end

  def handle_event(
        [component, category, :event_warn],
        _measurements,
        %{} = metadata,
        _config
      ) do
    log_message(:warning, component, category, metadata)
  end

  def handle_event(
        [component, category, :event_error],
        _measurements,
        %{} = metadata,
        _config
      ) do
    log_message(:error, component, category, metadata)
  end

  def handle_event(
        [component, category, :api_call, :stop],
        %{duration: duration},
        %{} = metadata,
        _config
      ) do
    duration_us = System.convert_time_unit(duration, :native, :microsecond)

    message =
      "Telemetry Event: #{inspect([component, category, :api_call, :stop])}"

    logger_metadata = [
      component: component,
      category: category,
      module: metadata[:module],
      function: metadata.function,
      arity: metadata.arity,
      context: inspect(metadata.context),
      duration_us: duration_us
    ]

    Logger.info(message, logger_metadata)
  end

  def handle_event(_event, _measurements, _metadata, _config), do: :ok

  defp log_message(level, component, category, metadata) do
    logger_metadata = [
      component: component,
      category: category,
      module: metadata[:module],
      function: metadata.function,
      arity: metadata.arity,
      context: inspect(metadata.context)
    ]

    Logger.log(level, metadata.message, logger_metadata)
  end

  ##############################################################################
  #
  # attach_logger_handler
  #
  #

  @spec attach_logger_handler(keyword()) :: :ok | Types.parsable_error()
  def attach_logger_handler(opts) do
    component = Keyword.fetch!(opts, :component)
    events = generate_events(component, opts)
    # Create a unique handler ID based on component and categories
    categories = Keyword.fetch!(opts, :categories)
    handler_id = {__MODULE__, component, categories}

    Enum.reduce_while(events, [], fn event, acc ->
      case :telemetry.attach({handler_id, event}, event, &handle_event/4, nil) do
        :ok ->
          {:cont, [event | acc]}

        {:error, :already_exists} ->
          # Detach what we've attached so far
          for attached_event <- acc do
            :ok = :telemetry.detach({handler_id, attached_event})
          end

          {:halt,
           {:error,
            {:already_exists, "Telemetry handler already exists for event: #{inspect(event)}"}}}
      end
    end)
    |> case do
      {:error, _reason} = error -> error
      _ -> :ok
    end
  end

  ##############################################################################
  #
  # detach_logger_handler
  #
  #

  @spec detach_logger_handler(keyword()) :: :ok | Types.parsable_error()
  def detach_logger_handler(opts) do
    component = Keyword.fetch!(opts, :component)
    events = generate_events(component, opts)
    # Create the same unique handler ID used in attach
    categories = Keyword.fetch!(opts, :categories)
    handler_id = {__MODULE__, component, categories}

    Enum.reduce_while(events, [], fn event, acc ->
      case :telemetry.detach({handler_id, event}) do
        :ok ->
          {:cont, [event | acc]}

        {:error, :not_found} ->
          {:halt,
           {:error, {:not_found, "Telemetry handler not found for event: #{inspect(event)}"}}}
      end
    end)
    |> case do
      {:error, _reason} = error -> error
      _ -> :ok
    end
  end

  ##############################################################################
  #
  # General Private Functions
  #
  #

  defp generate_events(component, opts) do
    log_levels = Keyword.get(opts, :log, [])
    log_api_calls = Keyword.get(opts, :api_calls, false)
    categories = Keyword.fetch!(opts, :categories)

    # Generate events for each category and log level combination
    events =
      for category <- categories, level <- log_levels do
        [component, category, :"event_#{level}"]
      end

    # Add API call events if requested
    api_events =
      if log_api_calls do
        for category <- categories, do: [component, category, :api_call, :stop]
      else
        []
      end

    events ++ api_events
  end
end
