# GenAI Local & ExLLama

Local on-device LLM inference via Rustler NIF wrapping llama.cpp.

## Components
- **ex_llama** (0.2.3) — Low-level NIF wrapper
- **genai_local** — GenAI provider integration

## Installation
```elixir
{:ex_llama, "~> 0.2.3"}
# For GenAI integration:
{:genai_local, github: "noizu-labs/genai_local"}
```
Requires C/C++ toolchain — uses `elixir_make` compiler.

## ExLLama Core API

### Load a Model
```elixir
{:ok, model} = ExLLama.load_model("/path/to/model.gguf")
{:ok, model} = ExLLama.load_model("/path/to/model.gguf", %ExLLama.ModelOptions{})
```

### Create a Session
```elixir
{:ok, session} = ExLLama.create_session(model)
{:ok, session} = ExLLama.create_session(model, %ExLLama.SessionOptions{})
```

### Chat Completion
```elixir
messages = [
  %{role: :system, content: "You are helpful."},
  %{role: :user, content: "Hello!"}
]
{:ok, response} = ExLLama.chat_completion(model, messages, options)
```

### Low-Level Completion
```elixir
ExLLama.Session.set_context(session, context_string)
ExLLama.Session.context_size(session)               # Token count
{:ok, text} = ExLLama.completion(session, max_tokens, stop_tokens)
ExLLama.advance_context(session, new_content)         # Update context
```

### Streaming
```elixir
ExLLama.Session.start_completing_with(session, options)
# Sends tokens to caller via message passing
```

## Chat Templates (27 supported)
ExLLama.ChatTemplate handles format conversion between message lists and model-specific prompt formats.

Key templates: Llama 2, Llama 3, Mistral, Alpaca, Vicuna, ChatML, Phi, Gemma, DeepSeek, Command-R, Zephyr, etc.

```elixir
context = ExLLama.ChatTemplate.to_context(messages, model, options)
response = ExLLama.ChatTemplate.extract_response(choices, model, options)
```

## GenAI Integration

### Provider: LocalLLama
```elixir
# Config
config :genai, :local_llama,
  enable: true,
  otp_app: :my_app  # GGUF files in priv/

# Load model as GenAI.ExternalModel
model = GenAI.Provider.LocalLLama.Models.priv(:my_app, "model.gguf")

# Use in GenAI thread
thread = GenAI.Thread.Standard.new()
|> GenAI.with_model(model)
|> GenAI.with_message(:user, "Hello!")

{:ok, completion} = GenAI.run(thread, context)
```

### Supervisor Tree
`GenAI.Provider.LocalLLamaManager` manages:
- `LocalLlamaSupervisor` — Process supervision
- `LocalLlamaServer` — Session pooling

## Key Concepts
1. GGUF format models (quantized for efficient inference)
2. Seed-based deterministic generation
3. 27 chat template formats for different model families
4. Session-based context management (token window)
5. NIF performance — near-native C++ speed
