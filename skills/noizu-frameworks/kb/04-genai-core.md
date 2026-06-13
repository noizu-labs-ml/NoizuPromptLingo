# genai_core (0.3.0)

Core protocols, type system, and graph-based execution model for the GenAI framework.

## Installation
```elixir
{:genai_core, "~> 0.3.0"}
# Pulls in noizu_labs_core
```

## Quick Start
```elixir
alias GenAI.Thread.Standard, as: Thread

thread = Thread.new()
|> GenAI.with_model(:"claude-sonnet-4-20250514")
|> GenAI.with_message(:user, "Hello!")
|> GenAI.with_setting(:temperature, 0.7)

{:ok, response} = GenAI.run(thread, context)
```

## ThreadProtocol

The central protocol — all thread operations go through it. `GenAI` module delegates to the thread's implementation.

### Model & Provider Configuration
```elixir
GenAI.with_model(thread, model_id)
GenAI.with_api_key(thread, provider, key)
GenAI.with_api_org(thread, provider, org)
```

### Message Management
```elixir
GenAI.with_message(thread, role, content)           # role: :system | :user | :assistant
GenAI.with_message(thread, message_struct)           # GenAI.Message struct
GenAI.with_messages(thread, [message1, message2])    # Batch add
```

### Tool Configuration
```elixir
GenAI.with_tool(thread, tool)        # Single GenAI.Tool
GenAI.with_tools(thread, [tools])    # Multiple tools
```

### Settings
```elixir
GenAI.with_setting(thread, :temperature, 0.7)
GenAI.with_setting(thread, :max_tokens, 4096)
GenAI.with_setting(thread, setting_struct)
GenAI.with_settings(thread, [settings])

# Provider-specific settings
GenAI.with_provider_setting(thread, provider, key, value)

# Model-specific settings
GenAI.with_model_setting(thread, model, key, value)

# Safety settings (native on Gemini, emulated via prompting elsewhere)
GenAI.with_safety_setting(thread, category, threshold)
```

### Execution
```elixir
GenAI.run(thread, context)                           # Simple run
GenAI.execute(thread, provider, context, options)    # Provider-explicit
GenAI.stream(thread, context, options)               # Streaming
```

### Resolving Effective Settings
```elixir
GenAI.effective_model(thread)
GenAI.effective_settings(thread)
GenAI.effective_tools(thread)
```

## Thread Types

### GenAI.Thread.Standard
Simple linear chat. Implements ThreadProtocol. Best for single-turn or multi-turn conversations without complex state.

### GenAI.Thread.Session
Stateful session management. Tracks conversation state across multiple interactions. Use when you need persistent conversation context.

### GenAI.Thread.State
Internal state container used by thread implementations.

## Type System

### GenAI.Message
```elixir
%GenAI.Message{
  role: :system | :user | :assistant | :tool,
  content: String.t() | list(),
  tool_calls: list() | nil,
  tool_call_id: String.t() | nil,
  metadata: map()
}
```

### GenAI.ChatCompletion
```elixir
%GenAI.ChatCompletion{
  choices: [%{message: GenAI.Message.t(), finish_reason: atom()}],
  usage: %{prompt_tokens: integer(), completion_tokens: integer(), total_tokens: integer()},
  provider: atom(),
  model: atom() | String.t(),
  metadata: map()
}
```

### GenAI.Tool
```elixir
%GenAI.Tool{
  name: String.t(),
  description: String.t(),
  parameters: map()  # JSON Schema format
}
```

### GenAI.Model
```elixir
%GenAI.Model{
  model: atom(),
  provider: atom(),
  encoder: module(),
  details: map()
}
```

### GenAI.ExternalModel
Wrapper for runtime-loaded models (e.g., local GGUF files).

### GenAI.Setting.*
Hierarchical setting system:
- `GenAI.Setting` — Global settings (temperature, max_tokens, etc.)
- Provider-level settings
- Model-level settings
- Safety settings

## Graph Execution (VNext)

DAG-based execution for complex inference pipelines.

```elixir
# Graph nodes: Message, Setting, Model, Tool, SafetySetting, ProviderSetting, ModelSetting
# Execution follows topological order through the DAG
```

`GenAI.Graph` manages node/edge relationships and execution ordering. Primarily used internally by the thread system for resolving effective settings.

## Protocol-Based Extensibility

### GenAI.ModelProtocol
Abstract model interface — implement for custom model types.

### GenAI.Model.EncoderBehaviour
Per-model message encoding. Each provider's encoder translates GenAI.Message to provider-specific format.

### GenAI.InferenceProviderBehaviour
The contract every provider must implement:
```elixir
@callback models(settings) :: {:ok, list()} | {:error, any()}
@callback do_run(session, context, options) :: {:ok, GenAI.ChatCompletion.t()} | {:error, any()}
```

### GenAI.Setting.MessageProtocol
Controls how settings are encoded into provider requests.

### GenAI.Tool.ToolProtocol
Controls how tools are marshaled for each provider.

## Configuration Hierarchy (Resolution Order)
1. Thread-level: `GenAI.with_setting(thread, :temperature, 0.7)`
2. Model-level: `GenAI.with_model_setting(thread, model, :temperature, 0.5)`
3. Provider-level: `GenAI.with_provider_setting(thread, provider, key, value)`
4. Global config: `config :genai, :provider_name, key: value`

Lower numbers override higher numbers.

## Key Concepts
1. **Protocol-based design** — Everything is a protocol implementation for runtime flexibility
2. **Graph execution** — DAG resolves settings/tools/messages in correct order
3. **Message normalization** — All providers translate to/from unified GenAI.Message
4. **Tool integration** — Native where supported, emulated via system prompt elsewhere
5. **Safety settings** — Native on Gemini, prompt-based fallback for other providers
6. **Encoder pattern** — Each provider/model has custom request encoding
