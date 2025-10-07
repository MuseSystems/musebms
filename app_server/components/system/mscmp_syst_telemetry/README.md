# MscmpSystTelemetry - Telemetry

<!-- MDOC !-->

Telemetry recording and handling library for the Muse System Business
Management System.

This library provides standardized instrumentation and telemetry handling
capabilities for MuseBMS Components, enabling observability, debugging, and
monitoring across the system.

<!-- MDESC !-->

## Core Concepts

### Components and Categories

The telemetry system is organized around **Components** and **Categories**:

- **Component**: A logical grouping representing a MuseBMS Component
  (e.g., `:mscmp_syst_db`, `:mscmp_syst_auth`)
- **Category**: A functional area within a component
  (e.g., `:database`, `:api`, `:worker`)

Each component must explicitly define its valid categories when using the library.
This creates a clear hierarchical structure for telemetry events.

### Event Kinds

**Event Kinds** represent the types of telemetry events that can be generated
and are a cross-cutting concern that applies across all components and
categories. Unlike components and categories which form a hierarchy, event
kinds determine the nature and structure of the telemetry event itself.

The supported event kinds are:

- **Log Event Kinds**: `:log_debug`, `:log_info`, `:log_warn`, `:log_error`
- **API Call Event Kinds**: `:api_call_start`, `:api_call_stop`

Event kinds are independent of the component/category hierarchy and can be
combined with any valid component/category pair to generate specific telemetry
events.

### Event Types

The library generates telemetry events based on the combination of components,
categories, and event kinds:

1. **API Call Events**: Timing and metadata for function calls
   - Event names: `[component, category, :api_call, :start]` and
     `[component, category, :api_call, :stop]`
   - Generated using `api_telemetry/3` macro
   - Creates telemetry spans with start/stop events

2. **Log Events**: Structured logging at different levels
   - Event names: `[component, category, :log_debug|info|warn|error]`
   - Generated using `log_debug/3`, `log_info/3`, `log_warn/3`, `log_error/3`
   - One-time events with message and context

### Event Naming Convention

All telemetry events follow a consistent naming pattern:
```
[component_atom, category_atom, event_kind_suffix...]
```

Examples:
- `[:mscmp_syst_db, :database, :api_call, :start]` - Database API call start
  event
- `[:mscmp_syst_db, :database, :api_call, :stop]` - Database API call stop
  event
- `[:mscmp_syst_auth, :api, :log_info]` - Authentication API info log
- `[:mscmp_syst_worker, :background, :log_error]` - Background worker error

### Handlers

Handlers are functions that process telemetry events. The library provides:

- **Logger Handler**: Routes telemetry events to Elixir's Logger

Handlers are typically attached at the Platform level for production, but
Components can attach handlers for development and testing.

## Usage Patterns

### Setting Up a Component

```elixir
defmodule MyComponent do
  use MscmpSystTelemetry,
    component: :my_component,
    categories: [:api, :database, :worker]

  # Your component code here
end
```

### Instrumenting API Calls

```elixir
def create_user(user_params) do
  # Safe context - no sensitive data
  context = %{user_type: user_params.type, tenant_id: user_params.tenant_id}

  api_telemetry :api, context do
    # Your function logic here
    {:ok, user} = Database.create_user(user_params)
    {:ok, user}
  end
end
```

### Structured Logging

```elixir
def process_payment(payment_id, amount) do
  context = %{payment_id: payment_id, amount_cents: amount}

  log_info :api, "Processing payment", context

  case PaymentGateway.charge(payment_id, amount) do
    {:ok, result} ->
      log_info :api, "Payment processed successfully",
        Map.put(context, :transaction_id, result.id)
      {:ok, result}

    {:error, reason} ->
      log_error :api, "Payment processing failed",
        Map.put(context, :error_reason, reason)
      {:error, reason}
  end
end
```

### Database Operations

```elixir
def fetch_user_data(user_id) do
  context = %{user_id: user_id}

  api_telemetry :database, context do
    case Repo.get(User, user_id) do
      nil ->
        log_warn :database, "User not found", context
        {:error, :not_found}
      user ->
        {:ok, user}
    end
  end
end
```

## Handler Management

### Development Setup

For development and testing, attach handlers in your component:

```elixir
def setup_telemetry do
  MscmpSystTelemetry.attach_logger_handler(
    {MyComponent.Logger, :my_component, self()},
    :my_component,
    [:api, :database, :worker],
    [:log_info, :log_warn, :log_error, :api_call_start, :api_call_stop]
  )
end
```

### Production Setup

In production, handlers are typically managed at the Platform level:

```elixir
# In your application supervision tree or platform configuration
def attach_component_handlers do
  # Attach handlers for all components
  components = [
    {:mscmp_syst_db, [:database, :api]},
    {:mscmp_syst_auth, [:api, :worker]},
    {:my_component, [:api, :database, :worker]}
  ]

  for {component, categories} <- components do
    MscmpSystTelemetry.attach_logger_handler(
      {MyApp.Logger, component, self()},
      component,
      categories,
      [:log_warn, :log_error]  # Production typically logs less verbose
    )
  end
end
```

## Security Considerations

**Context Data Safety**: Always ensure that context data passed to telemetry
functions contains only safe, non-sensitive information. Never include:
- User passwords or tokens
- Personal identifiable information (PII)
- API keys or secrets
- Raw user input

**Safe Context Examples**:
```elixir
# ✅ Safe - IDs and metadata
%{user_id: 123, account_id: 456, action: "create"}

# ✅ Safe - Aggregate data
%{record_count: 10, processing_time_ms: 250}

# ❌ Unsafe - Contains sensitive data
%{user_email: "user@example.com", password: "secret123"}
```

## Event Metadata

All telemetry events include standard metadata:
- `:module` - The module that generated the event
- `:function` - The function name
- `:arity` - The function arity
- `:context` - Developer-provided context data
- `:message` - Log message (for log events)

Additional metadata may be added by handlers or the telemetry system itself.

## Integration Points

### With Logging

The Logger handler integrates seamlessly with Elixir's Logger, allowing
telemetry events to appear in standard log outputs while maintaining
structured metadata.

### With Metrics

While not implemented in this library, telemetry events can be consumed
by metrics systems like Prometheus, StatsD, or custom metrics handlers.

### With Tracing

API call spans can be consumed by distributed tracing systems to provide
end-to-end request visibility across MuseBMS components.
