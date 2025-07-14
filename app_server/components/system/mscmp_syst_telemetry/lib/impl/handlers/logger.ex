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
  alias MscmpSystTelemetry.Impl.Events

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
        [component, category, :log_debug],
        _measurements,
        %{} = metadata,
        _config
      ) do
    log_message(:debug, component, category, metadata)
  end

  def handle_event(
        [component, category, :log_info],
        _measurements,
        %{} = metadata,
        _config
      ) do
    log_message(:info, component, category, metadata)
  end

  def handle_event(
        [component, category, :log_warn],
        _measurements,
        %{} = metadata,
        _config
      ) do
    log_message(:warning, component, category, metadata)
  end

  def handle_event(
        [component, category, :log_error],
        _measurements,
        %{} = metadata,
        _config
      ) do
    log_message(:error, component, category, metadata)
  end

  def handle_event(
        [component, category, :api_call, :start],
        %{system_time: system_time},
        %{} = metadata,
        _config
      ) do
    message =
      "Telemetry Event: #{inspect([component, category, :api_call, :start])}"

    logger_metadata = [
      component: component,
      category: category,
      module: metadata[:module],
      function: metadata.function,
      arity: metadata.arity,
      context: inspect(metadata.context),
      system_time: system_time
    ]

    Logger.info(message, logger_metadata)
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
    categories = Keyword.fetch!(opts, :categories)
    event_kinds = Keyword.fetch!(opts, :event_kinds)
    handler_id = Keyword.fetch!(opts, :handler_id)

    events = Events.generate_events(component, categories, event_kinds)

    case :telemetry.attach_many(handler_id, events, &__MODULE__.handle_event/4, nil) do
      :ok ->
        :ok

      {:error, :already_exists} ->
        {:error,
         {:already_exists,
          "Telemetry handler already exists for handler_id: #{inspect(handler_id)}"}}
    end
  end

  ##############################################################################
  #
  # detach_logger_handler
  #
  #

  @spec detach_logger_handler(keyword()) :: :ok | Types.parsable_error()
  def detach_logger_handler(opts) do
    handler_id = Keyword.fetch!(opts, :handler_id)

    case :telemetry.detach(handler_id) do
      :ok ->
        :ok

      {:error, :not_found} ->
        {:error,
         {:not_found, "Telemetry handler not found for handler_id: #{inspect(handler_id)}"}}
    end
  end

  ##############################################################################
  #
  # General Private Functions
  #
  #
end
