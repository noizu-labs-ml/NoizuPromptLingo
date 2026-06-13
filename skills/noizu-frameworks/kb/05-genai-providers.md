# GenAI Providers (genai 0.3.0)

Provider implementations for the GenAI unified LLM interface. 9 providers, each implementing `GenAI.InferenceProviderBehaviour`.

## Installation
```elixir
{:genai, "~> 0.3.0"}
# Pulls in genai_core → noizu_labs_core
```

## Provider Overview

| Provider | Module | Config Key | Models |
|----------|--------|-----------|--------|
| Anthropic | `GenAI.Provider.Anthropic` | `:anthropic` | claude-opus-4-6, claude-sonnet-4-6, claude-3-opus, claude-3-sonnet, claude-3-haiku |
| OpenAI | `GenAI.Provider.OpenAI` | `:openai` | gpt-4, gpt-4-turbo, gpt-3.5-turbo |
| Gemini | `GenAI.Provider.Gemini` | `:gemini` | gemini-pro, gemini-ultra |
| Mistral | `GenAI.Provider.Mistral` | `:mistral` | mistral-large, mistral-medium, mistral-small |
| Groq | `GenAI.Provider.Groq` | `:groq` | mixtral-8x7b, llama2-70b |
| XAI | `GenAI.Provider.XAI` | `:xai` | grok |
| DeepSeek | `GenAI.Provider.DeepSeek` | `:deepseek` | deepseek-chat, deepseek-coder |
| Ollama | `GenAI.Provider.Ollama` | `:ollama` | (local models) |
| Zai | `GenAI.Provider.Zai` | `:zai` | (emerging) |

## Configuration

```elixir
# config/config.exs or config/runtime.exs
config :genai, :anthropic,
  api_key: System.get_env("ANTHROPIC_API_KEY")

config :genai, :openai,
  api_key: System.get_env("OPENAI_API_KEY"),
  api_org: System.get_env("OPENAI_API_ORG")  # optional

config :genai, :gemini,
  api_key: System.get_env("GEMINI_API_KEY")

config :genai, :groq,
  api_key: System.get_env("GROQ_API_KEY")

config :genai, :mistral,
  api_key: System.get_env("MISTRAL_API_KEY")

config :genai, :xai,
  api_key: System.get_env("XAI_API_KEY")

config :genai, :deepseek,
  api_key: System.get_env("DEEPSEEK_API_KEY")

config :genai, :ollama,
  endpoint: "http://localhost:11434"  # default
```

## Usage Examples

### Anthropic (Claude)
```elixir
thread = GenAI.Thread.Standard.new()
|> GenAI.with_model(:"claude-sonnet-4-20250514")
|> GenAI.with_message(:system, "You are a helpful assistant.")
|> GenAI.with_message(:user, "Explain OTP in Elixir.")
|> GenAI.with_setting(:max_tokens, 1024)

{:ok, completion} = GenAI.run(thread, context)
```

### OpenAI (GPT)
```elixir
thread = GenAI.Thread.Standard.new()
|> GenAI.with_model(:"gpt-4")
|> GenAI.with_message(:user, "What is a GenServer?")

{:ok, completion} = GenAI.run(thread, context)
```

### With Tools
```elixir
weather_tool = %GenAI.Tool{
  name: "get_weather",
  description: "Get current weather for a location",
  parameters: %{
    "type" => "object",
    "properties" => %{
      "location" => %{"type" => "string", "description" => "City name"}
    },
    "required" => ["location"]
  }
}

thread = GenAI.Thread.Standard.new()
|> GenAI.with_model(:"claude-sonnet-4-20250514")
|> GenAI.with_tool(weather_tool)
|> GenAI.with_message(:user, "What's the weather in Tokyo?")

{:ok, completion} = GenAI.run(thread, context)
# completion.choices may contain tool_calls
```

## Provider Architecture

Each provider consists of:
```
GenAI.Provider.ProviderName/
├── lib/
│   ├── provider.ex           # Main module, implements InferenceProviderBehaviour
│   ├── encoder.ex            # Request encoding (GenAI → provider API format)
│   ├── encoder_protocol.ex   # Tool/message marshaling protocol
│   └── models.ex             # Model registry with capabilities
```

### InferenceProviderBehaviour
```elixir
@callback models(settings) :: {:ok, list(GenAI.Model.t())} | {:error, any()}
@callback do_run(session, context, options) :: {:ok, GenAI.ChatCompletion.t()} | {:error, any()}
```

### Encoder Pattern
Each provider's Encoder translates:
- `GenAI.Message` → provider-specific message format
- `GenAI.Tool` → provider-specific tool schema
- `GenAI.Setting` → provider-specific parameters
- Provider API response → `GenAI.ChatCompletion`

## Adding a New Provider

### Step 1: Create the module
```elixir
defmodule GenAI.Provider.MyProvider do
  @behaviour GenAI.InferenceProviderBehaviour

  def models(_settings) do
    {:ok, [
      %GenAI.Model{
        model: :"my-model-v1",
        provider: __MODULE__,
        encoder: GenAI.Provider.MyProvider.Encoder,
        details: %{context_window: 128_000}
      }
    ]}
  end

  def do_run(session, context, options) do
    # 1. Resolve effective settings from session
    # 2. Encode messages via Encoder
    # 3. Make HTTP request to provider API
    # 4. Parse response into GenAI.ChatCompletion
    {:ok, %GenAI.ChatCompletion{...}}
  end
end
```

### Step 2: Implement the Encoder
```elixir
defmodule GenAI.Provider.MyProvider.Encoder do
  @behaviour GenAI.Model.EncoderBehaviour

  def encode_message(message, options) do
    # Transform GenAI.Message → provider format
  end

  def encode_tool(tool, options) do
    # Transform GenAI.Tool → provider format
  end

  def build_request(messages, tools, settings, options) do
    # Assemble the full API request body
  end

  def parse_response(response, options) do
    # Transform provider response → GenAI.ChatCompletion
  end
end
```

### Step 3: Add configuration
```elixir
config :genai, :my_provider,
  api_key: System.get_env("MY_PROVIDER_API_KEY"),
  endpoint: "https://api.myprovider.com/v1"
```

## Provider-Specific Notes

### Anthropic
- Supports extended thinking
- Tool use via native `tools` parameter
- Messages API (not completions)

### OpenAI
- Supports function calling and tool use
- Vision support for image inputs
- Completions and chat completions

### Gemini
- Native safety settings (HARM_CATEGORY_* with thresholds)
- Multi-modal input support

### Ollama
- Local-only, no API key needed
- Endpoint defaults to localhost:11434
- Models must be pulled first (`ollama pull model-name`)

### Groq
- Extremely fast inference
- Limited model selection
- Same API format as OpenAI

## Application Startup

GenAI starts a Finch HTTP connection pool on application boot:
```elixir
# Automatic via GenAI.Application supervisor
# No manual setup needed
```

## Key Concepts
1. **Provider abstraction** — Switch providers by changing `with_model/2`, everything else stays the same
2. **Encoder isolation** — Each provider's encoding is fully isolated, no cross-contamination
3. **Model registry** — `models/1` callback lets providers dynamically report available models
4. **Finch pooling** — Shared HTTP connection pool for all providers
5. **Runtime API key override** — `with_api_key/3` overrides config at thread level
