# Source File: mscmp_syst_telemetry.ex
# Location:    musebms/app_server/components/system/mscmp_syst_telemetry/lib/api/mscmp_syst_telemetry.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystTelemetry do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias MscmpSystError.Types.Context, as: ErrorContext
  alias MscmpSystTelemetry.Impl.Events
  alias MscmpSystTelemetry.Impl.Handlers.Logger, as: LoggerHandler

  ##############################################################################
  #
  # __using__
  #
  #

  @doc """
  Sets up the calling module to use MscmpSystTelemetry.

  ## Options

    * `:component` (atom, required) - The atom identifying the component (e.g., `:mscmp_syst_db`).
    * `:categories` (list of atoms, required) - The list of valid categories for this component
      (e.g., `[:database, :api, :worker]`). Each component must explicitly define its categories.

  This macro defines `@component` and `@categories` in the calling module.
  """
  @spec __using__(keyword()) :: Macro.t()
  defmacro __using__(opts) do
    component = Keyword.fetch!(opts, :component)
    categories = Keyword.fetch!(opts, :categories)

    quote do
      Module.register_attribute(__MODULE__, :component, persist: true)
      Module.register_attribute(__MODULE__, :categories, persist: true)
      @component unquote(component)
      @categories unquote(categories)
      import MscmpSystTelemetry,
        only: [
          api_telemetry: 3,
          log_debug: 3,
          log_info: 3,
          log_warn: 3,
          log_error: 3
        ]
    end
  end

  ##############################################################################
  #
  # api_telemetry
  #
  #

  @doc """
  Used to instrument Component API calls.

  The telemetry event names will be `[@component, category, :api_call, :start]`
  and `[@component, category, :api_call, :stop]`.
  The `context` argument is added to the telemetry metadata under the
  `:context` key, and the calling module is added under the `:module` key.

  It is the developer's responsibility to ensure that the provided `context`
  does not contain sensitive information. The context should be a keyword list
  or map containing only data that is safe and useful for telemetry.

  ## Examples

  ```elixir
  def my_api_function(user, account_id) do
    # Provide an explicit map of safe-to-log context.
    context = %{user_id: user.id, account_id: account_id}
    api_telemetry :api, context do
      # ... function body ...
      {:ok, "result"}
    end
  end

  def my_database_function do
    # For functions where no extra context is needed, pass an empty list.
    api_telemetry :database, [] do
      # ...
    end
  end
  ```
  """
  @spec api_telemetry(atom(), any(), keyword()) :: Macro.t()
  defmacro api_telemetry(category, context, do: block) do
    component = Module.get_attribute(__CALLER__.module, :component)
    categories = Module.get_attribute(__CALLER__.module, :categories)

    # Validate category at compile time
    if category not in categories do
      raise ArgumentError,
            "Invalid category #{inspect(category)}. Valid categories are: #{inspect(categories)}"
    end

    quote do
      event_prefix = [unquote(component), unquote(category), :api_call]
      {function, arity} = __ENV__.function

      metadata = %{
        function: function,
        arity: arity,
        module: __MODULE__,
        context: unquote(context)
      }

      :telemetry.span(event_prefix, metadata, fn ->
        result = unquote(block)
        {result, metadata}
      end)
    end
  end

  ##############################################################################
  #
  # log_debug
  #
  #

  @doc """
  Logs a `debug` event with context via telemetry.

  The event name will be `[@component, category, :log_debug]`.
  The message and context are passed as metadata, along with the calling module.
  It is the developer's responsibility to ensure that the provided context does
  not contain sensitive information.
  """
  @spec log_debug(atom(), String.t(), keyword() | map()) :: Macro.t()
  defmacro log_debug(category, message, context) do
    component = Module.get_attribute(__CALLER__.module, :component)
    categories = Module.get_attribute(__CALLER__.module, :categories)

    # Validate category at compile time
    if category not in categories do
      raise ArgumentError,
            "Invalid category #{inspect(category)}. Valid categories are: #{inspect(categories)}"
    end

    quote do
      {function, arity} = __ENV__.function
      base_metadata = %{message: unquote(message), context: unquote(context)}
      mfa_metadata = %{function: function, arity: arity, module: __MODULE__}
      metadata = Map.merge(base_metadata, mfa_metadata)

      :telemetry.execute(
        [unquote(component), unquote(category), :log_debug],
        %{},
        metadata
      )
    end
  end

  ##############################################################################
  #
  # log_info
  #
  #

  @doc """
  Logs an `info` event with context via telemetry.

  The event name will be `[@component, category, :log_info]`.
  The message and context are passed as metadata, along with the calling module.
  It is the developer's responsibility to ensure that the provided context does
  not contain sensitive information.
  """
  @spec log_info(atom(), String.t(), keyword() | map()) :: Macro.t()
  defmacro log_info(category, message, context) do
    component = Module.get_attribute(__CALLER__.module, :component)
    categories = Module.get_attribute(__CALLER__.module, :categories)

    # Validate category at compile time
    if category not in categories do
      raise ArgumentError,
            "Invalid category #{inspect(category)}. Valid categories are: #{inspect(categories)}"
    end

    quote do
      {function, arity} = __ENV__.function
      base_metadata = %{message: unquote(message), context: unquote(context)}
      mfa_metadata = %{function: function, arity: arity, module: __MODULE__}
      metadata = Map.merge(base_metadata, mfa_metadata)

      :telemetry.execute(
        [unquote(component), unquote(category), :log_info],
        %{},
        metadata
      )
    end
  end

  ##############################################################################
  #
  # log_warn
  #
  #

  @doc """
  Logs a `warn` event with context via telemetry.

  The event name will be `[@component, category, :log_warn]`.
  The message and context are passed as metadata, along with the calling module.
  It is the developer's responsibility to ensure that the provided context does
  not contain sensitive information.
  """
  @spec log_warn(atom(), String.t(), keyword() | map()) :: Macro.t()
  defmacro log_warn(category, message, context) do
    component = Module.get_attribute(__CALLER__.module, :component)
    categories = Module.get_attribute(__CALLER__.module, :categories)

    # Validate category at compile time
    if category not in categories do
      raise ArgumentError,
            "Invalid category #{inspect(category)}. Valid categories are: #{inspect(categories)}"
    end

    quote do
      {function, arity} = __ENV__.function
      base_metadata = %{message: unquote(message), context: unquote(context)}
      mfa_metadata = %{function: function, arity: arity, module: __MODULE__}
      metadata = Map.merge(base_metadata, mfa_metadata)

      :telemetry.execute(
        [unquote(component), unquote(category), :log_warn],
        %{},
        metadata
      )
    end
  end

  ##############################################################################
  #
  # log_error
  #
  #

  @doc """
  Logs an `error` event with context via telemetry.

  The event name will be `[@component, category, :log_error]`.
  The message and context are passed as metadata, along with the calling module.
  It is the developer's responsibility to ensure that the provided context does
  not contain sensitive information.
  """
  @spec log_error(atom(), String.t(), keyword() | map()) :: Macro.t()
  defmacro log_error(category, message, context) do
    component = Module.get_attribute(__CALLER__.module, :component)
    categories = Module.get_attribute(__CALLER__.module, :categories)

    # Validate category at compile time
    if category not in categories do
      raise ArgumentError,
            "Invalid category #{inspect(category)}. Valid categories are: #{inspect(categories)}"
    end

    quote do
      {function, arity} = __ENV__.function
      base_metadata = %{message: unquote(message), context: unquote(context)}
      mfa_metadata = %{function: function, arity: arity, module: __MODULE__}
      metadata = Map.merge(base_metadata, mfa_metadata)

      :telemetry.execute(
        [unquote(component), unquote(category), :log_error],
        %{},
        metadata
      )
    end
  end

  ##############################################################################
  #
  # attach_logger_handler
  #
  #

  @doc """
  Attaches the MscmpSystTelemetry logger handler to telemetry events.

  This function sets up a handler that will log telemetry events using Elixir's
  `Logger`. The handler is attached to events that match
  `[component, category, event_kind]`.

  ## Parameters

    * `handler_id` (term, required) - A unique identifier for this handler.
      Must be unique across all telemetry handlers in the system.
    * `component` (atom, required) - The component atom to listen for events
      from.
    * `categories` (list of atoms, required) - The list of category atoms to
      attach to. Events will be attached for each category in the list. Must be
      non-empty.
    * `event_kinds` (list of atoms, required) - The list of event kinds to
      listen for. Valid values are: `:log_debug`, `:log_info`, `:log_warn`,
      `:log_error`, `:api_call_start`, `:api_call_stop`. Must be non-empty.

  ## Example

      MscmpSystTelemetry.attach_logger_handler(
        {MyApp.Logger, :my_component, self()},
        :my_component,
        [:database, :api, :worker],
        [:log_info, :log_error, :api_call_stop]
      )
  """
  @spec attach_logger_handler(term(), atom(), [atom()], [atom()]) ::
          :ok | {:error, Mserror.TelemetryError.t()}
  def attach_logger_handler(handler_id, component, categories, event_kinds) do
    handler_opts = [
      handler_id: handler_id,
      component: component,
      categories: categories,
      event_kinds: event_kinds
    ]

    with :ok <- Events.validate_categories(categories),
         :ok <- Events.validate_event_kinds(event_kinds),
         :ok <- LoggerHandler.attach_logger_handler(handler_opts) do
      :ok
    else
      {:error, _reason} = error ->
        {:error,
         Mserror.TelemetryError.new(:handler, "Failed to attach telemetry logger handler.",
           parse_error: error,
           context: %ErrorContext{
             origin: {__MODULE__, :attach_logger_handler, 4},
             parameters: %{
               handler_id: handler_id,
               component: component,
               categories: categories,
               event_kinds: event_kinds
             }
           }
         )}
    end
  end

  ##############################################################################
  #
  # detach_logger_handler
  #
  #

  @doc """
  Detaches the MscmpSystTelemetry logger handler.

  The handler_id provided must match the handler_id used when attaching the handler.

  ## Parameters

    * `handler_id` (term, required) - The unique identifier that was used when attaching.

  ## Example

      MscmpSystTelemetry.detach_logger_handler(
        {MyApp.Logger, :my_component, self()}
      )
  """
  @spec detach_logger_handler(term()) :: :ok | {:error, Mserror.TelemetryError.t()}
  def detach_logger_handler(handler_id) do
    case LoggerHandler.detach_logger_handler(handler_id: handler_id) do
      :ok ->
        :ok

      {:error, _reason} = error ->
        {:error,
         Mserror.TelemetryError.new(:handler, "Failed to detach telemetry logger handler.",
           parse_error: error,
           context: %ErrorContext{
             origin: {__MODULE__, :detach_logger_handler, 1},
             parameters: %{handler_id: handler_id}
           }
         )}
    end
  end

  ##############################################################################
  #
  # generate_events
  #
  #

  @doc """
  Generates the list of telemetry event names for the given component, categories,
  and event kinds.

  This function provides the canonical mapping from event kinds to actual telemetry
  event names. It can be used by handlers, external libraries, or for testing to
  determine what events will be generated.

  This function validates the provided event kinds and returns an error if any
  invalid event kinds are provided.

  ## Parameters

    * `component` (atom, required) - The component atom.
    * `categories` (list of atoms, required) - The list of category atoms. Must
      be non-empty.
    * `event_kinds` (list of atoms, required) - The list of event kinds.
      Valid values are: `:log_debug`, `:log_info`, `:log_warn`, `:log_error`,
      `:api_call_start`, `:api_call_stop`. Must be non-empty.

  ## Returns

  * `{:ok, events}` - A tuple containing the list of telemetry event names
    (lists of atoms).
  * `{:error, reason}` - An error tuple if validation fails.

  ## Example

      iex> MscmpSystTelemetry.generate_events(
      ...>   :my_component,
      ...>   [:database, :api],
      ...>   [:log_info, :api_call_stop]
      ...> )
      {:ok, [
        [:my_component, :database, :log_info],
        [:my_component, :database, :api_call, :stop],
        [:my_component, :api, :log_info],
        [:my_component, :api, :api_call, :stop]
      ]}

      iex> {:error, %Mserror.TelemetryError{}} =
      ...>   MscmpSystTelemetry.generate_events(
      ...>     :my_component,
      ...>     [:database],
      ...>     [:invalid_event]
      ...>   )

  """
  @spec generate_events(atom(), [atom()], [atom()]) ::
          {:ok, [list(atom())]} | Mserror.TelemetryError.t()
  def generate_events(component, categories, event_kinds) do
    with :ok <- Events.validate_categories(categories),
         :ok <- Events.validate_event_kinds(event_kinds) do
      {:ok, MscmpSystTelemetry.Impl.Events.generate_events(component, categories, event_kinds)}
    else
      {:error, _reason} = error ->
        {:error,
         Mserror.TelemetryError.new(:handler, "Failed to generate the requested events list.",
           parse_error: error,
           context: %ErrorContext{
             origin: {__MODULE__, :generate_events, 3},
             parameters: %{
               component: component,
               categories: categories,
               event_kinds: event_kinds
             }
           }
         )}
    end
  end
end
