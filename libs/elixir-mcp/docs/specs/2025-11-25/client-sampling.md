<!-- Source: https://modelcontextprotocol.io/specification/2025-11-25/client/sampling -->
<!-- Fetched: 2026-06-13 -->

# Sampling

The Model Context Protocol (MCP) provides a standardized way for servers to request LLM sampling ("completions" or "generations") from language models via clients. This flow allows clients to maintain control over model access, selection, and permissions while enabling servers to leverage AI capabilities -- with no server API keys necessary. Servers can request text, audio, or image-based interactions and optionally include context from MCP servers in their prompts.

## User Interaction Model

Sampling in MCP allows servers to implement agentic behaviors, by enabling LLM calls to occur *nested* inside other MCP server features.

> For trust & safety and security, there **SHOULD** always be a human in the loop with the ability to deny sampling requests.

## Tools in Sampling

Servers can request that the client's LLM use tools during sampling by providing a `tools` array and optional `toolChoice` configuration. This enables servers to implement agentic behaviors where the LLM can call tools, receive results, and continue the conversation within a single sampling request flow.

Clients **MUST** declare support for tool use via the `sampling.tools` capability. Servers **MUST NOT** send tool-enabled sampling requests to clients that have not declared this support.

## Capabilities

Clients that support sampling **MUST** declare the `sampling` capability during initialization:

**Basic sampling:**

```json
{
  "capabilities": {
    "sampling": {}
  }
}
```

**With tool use support:**

```json
{
  "capabilities": {
    "sampling": {
      "tools": {}
    }
  }
}
```

> The `includeContext` parameter values `"thisServer"` and `"allServers"` are soft-deprecated. Servers **SHOULD** avoid using these values.

## Protocol Messages

### Creating Messages

To request a language model generation, servers send a `sampling/createMessage` request:

**Request:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "sampling/createMessage",
  "params": {
    "messages": [
      {
        "role": "user",
        "content": {
          "type": "text",
          "text": "What is the capital of France?"
        }
      }
    ],
    "modelPreferences": {
      "hints": [
        {
          "name": "claude-3-sonnet"
        }
      ],
      "intelligencePriority": 0.8,
      "speedPriority": 0.5
    },
    "systemPrompt": "You are a helpful assistant.",
    "maxTokens": 100
  }
}
```

**Response:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "role": "assistant",
    "content": {
      "type": "text",
      "text": "The capital of France is Paris."
    },
    "model": "claude-3-sonnet-20240307",
    "stopReason": "endTurn"
  }
}
```

### Sampling with Tools

Servers can include `tools` and optionally `toolChoice` in the request. When the LLM returns tool use requests (`stopReason: "toolUse"`), the server executes the tools and sends a new sampling request with the tool results appended.

### Multi-turn Tool Loop

After receiving tool use requests from the LLM, the server typically:

1. Executes the requested tool uses
2. Sends a new sampling request with the tool results appended
3. Receives the LLM's response (which might contain new tool uses)
4. Repeats as needed

## Message Content Constraints

### Tool Result Messages

When a user message contains tool results (type: "tool_result"), it **MUST** contain ONLY tool results. Mixing tool results with other content types is not allowed.

### Tool Use and Result Balance

Every assistant message containing `ToolUseContent` blocks **MUST** be followed by a user message consisting entirely of `ToolResultContent` blocks, with each tool use matched by a corresponding tool result.

## Cross-API Compatibility

### Message Roles

MCP uses two roles: "user" and "assistant". Tool use requests use "assistant" role. Tool results use "user" role.

### Tool Choice Modes

* `{mode: "auto"}`: Model decides whether to use tools (default)
* `{mode: "required"}`: Model MUST use at least one tool before completing
* `{mode: "none"}`: Model MUST NOT use any tools

### Parallel Tool Use

MCP allows models to make multiple tool use requests in parallel.

## Data Types

### Messages

Sampling messages can contain: Text Content, Image Content, Audio Content.

### Model Preferences

Model selection uses abstract capability priorities with optional model hints:

#### Capability Priorities

* `costPriority`: How important is minimizing costs? (0-1)
* `speedPriority`: How important is low latency? (0-1)
* `intelligencePriority`: How important are advanced capabilities? (0-1)

#### Model Hints

* Hints are treated as substrings that can match model names flexibly
* Multiple hints are evaluated in order of preference
* Clients **MAY** map hints to equivalent models from different providers
* Hints are advisory -- clients make final model selection

## Error Handling

Clients **SHOULD** return errors for common failure cases:

* User rejected sampling request: `-1`
* Tool result missing in request: `-32602` (Invalid params)
* Tool results mixed with other content: `-32602` (Invalid params)

## Security Considerations

1. Clients **SHOULD** implement user approval controls
2. Both parties **SHOULD** validate message content
3. Clients **SHOULD** respect model preference hints
4. Clients **SHOULD** implement rate limiting
5. Both parties **MUST** handle sensitive data appropriately
6. Servers **MUST** ensure tool use/result matching
7. Both parties **SHOULD** implement iteration limits for tool loops
