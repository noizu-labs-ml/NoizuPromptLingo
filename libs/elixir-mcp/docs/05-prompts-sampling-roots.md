# MCP Specification: Prompts, Sampling, and Roots

Reference documentation for implementing the Model Context Protocol (MCP) 2025-03-26
specification covering server-exposed prompt templates, server-initiated LLM sampling,
and client-exposed filesystem roots.

> **Baseline note:** this document describes the **2025-03-26** revision. The
> library targets **2025-11-25**; the major addition since this baseline is
> **elicitation** (server→client user-input requests, 2025-06-18) — see
> [07-changelog-2025-06-18.md](07-changelog-2025-06-18.md) and
> [08-changelog-2025-11-25.md](08-changelog-2025-11-25.md).

Source: <https://modelcontextprotocol.io/specification/2025-03-26>

---

## Table of Contents

- [1. Prompts](#1-prompts)
  - [1.1 Overview](#11-overview)
  - [1.2 Capability Declaration](#12-capability-declaration)
  - [1.3 Listing Prompts — `prompts/list`](#13-listing-prompts--promptslist)
  - [1.4 Getting a Prompt — `prompts/get`](#14-getting-a-prompt--promptsget)
  - [1.5 Prompt Messages and Content Types](#15-prompt-messages-and-content-types)
  - [1.6 Prompt List Changes — `notifications/prompts/list_changed`](#16-prompt-list-changes--notificationspromptslist_changed)
  - [1.7 Dynamic vs Static Prompts](#17-dynamic-vs-static-prompts)
  - [1.8 Error Handling](#18-error-handling)
- [2. Sampling](#2-sampling)
  - [2.1 Overview](#21-overview)
  - [2.2 Capability Declaration](#22-capability-declaration)
  - [2.3 Creating Messages — `sampling/createMessage`](#23-creating-messages--samplingcreatemessage)
  - [2.4 Model Preferences](#24-model-preferences)
  - [2.5 Sampling Response](#25-sampling-response)
  - [2.6 Human-in-the-Loop](#26-human-in-the-loop)
  - [2.7 Security Considerations](#27-security-considerations)
- [3. Roots](#3-roots)
  - [3.1 Overview](#31-overview)
  - [3.2 Capability Declaration](#32-capability-declaration)
  - [3.3 Listing Roots — `roots/list`](#33-listing-roots--rootslist)
  - [3.4 Root List Changes — `notifications/roots/list_changed`](#34-root-list-changes--notificationsrootslist_changed)
  - [3.5 Data Types](#35-data-types)
  - [3.6 Error Handling](#36-error-handling)
  - [3.7 Security Considerations](#37-security-considerations)
- [4. Implementation Notes for Elixir](#4-implementation-notes-for-elixir)

---

## 1. Prompts

### 1.1 Overview

Prompts are reusable prompt templates exposed by MCP servers to clients. They provide a
standardized way for servers to offer structured messages and instructions for
interacting with language models. Clients discover available prompts, retrieve their
contents, and supply arguments to customize them.

**Key design principle:** Prompts are **user-controlled**. They are exposed from servers
to clients with the intention that users explicitly select them for use (e.g., as slash
commands in a UI). The protocol does not mandate any specific user interaction model --
implementors may surface prompts however they choose.

**Direction:** Client calls Server.

| Method                              | Direction        | Description                     |
|-------------------------------------|------------------|---------------------------------|
| `prompts/list`                      | Client -> Server | Discover available prompts      |
| `prompts/get`                       | Client -> Server | Retrieve a specific prompt      |
| `notifications/prompts/list_changed`| Server -> Client | Signal prompt list has changed  |

### 1.2 Capability Declaration

Servers that support prompts MUST declare the `prompts` capability during initialization.
The `listChanged` field indicates whether the server will emit notifications when the
available prompts change.

```json
{
  "capabilities": {
    "prompts": {
      "listChanged": true
    }
  }
}
```

### 1.3 Listing Prompts -- `prompts/list`

Retrieves the set of prompts the server exposes. Supports
[pagination](https://modelcontextprotocol.io/specification/2025-03-26/server/utilities/pagination)
via an optional `cursor` parameter.

**Request:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "prompts/list",
  "params": {
    "cursor": "optional-cursor-value"
  }
}
```

The `params` object is optional. When omitted, the server returns the first page.

**Response:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "prompts": [
      {
        "name": "code_review",
        "description": "Asks the LLM to analyze code quality and suggest improvements",
        "arguments": [
          {
            "name": "code",
            "description": "The code to review",
            "required": true
          }
        ]
      }
    ],
    "nextCursor": "next-page-cursor"
  }
}
```

**Prompt descriptor fields:**

| Field         | Type               | Required | Description                          |
|---------------|--------------------|----------|--------------------------------------|
| `name`        | `string`           | Yes      | Unique identifier for the prompt     |
| `description` | `string`           | No       | Human-readable description           |
| `arguments`   | `PromptArgument[]` | No       | List of arguments for customization  |

**PromptArgument fields:**

| Field         | Type      | Required | Description                        |
|---------------|-----------|----------|------------------------------------|
| `name`        | `string`  | Yes      | Argument name                      |
| `description` | `string`  | No       | Human-readable description         |
| `required`    | `boolean` | No       | Whether the argument is required   |

**Pagination:** When `nextCursor` is present in the response, additional pages are
available. Pass the cursor value as `params.cursor` in the next request. When
`nextCursor` is absent or null, all prompts have been returned.

### 1.4 Getting a Prompt -- `prompts/get`

Retrieves a specific prompt by name, optionally with arguments. Arguments may be
auto-completed through the
[completion API](https://modelcontextprotocol.io/specification/2025-03-26/server/utilities/completion).

**Request:**

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "prompts/get",
  "params": {
    "name": "code_review",
    "arguments": {
      "code": "def hello():\n    print('world')"
    }
  }
}
```

| Field       | Type                    | Required | Description                          |
|-------------|-------------------------|----------|--------------------------------------|
| `name`      | `string`                | Yes      | Name of the prompt to retrieve       |
| `arguments` | `map<string, string>`   | No       | Key-value pairs of argument values   |

**Response:**

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "description": "Code review prompt",
    "messages": [
      {
        "role": "user",
        "content": {
          "type": "text",
          "text": "Please review this Python code:\ndef hello():\n    print('world')"
        }
      }
    ]
  }
}
```

The response `result` contains:

| Field         | Type               | Required | Description                         |
|---------------|--------------------|----------|-------------------------------------|
| `description` | `string`           | No       | Description of this prompt instance |
| `messages`    | `PromptMessage[]`  | Yes      | The prompt content as messages      |

### 1.5 Prompt Messages and Content Types

Each `PromptMessage` has a `role` and `content`:

| Field     | Type                            | Description                     |
|-----------|---------------------------------|---------------------------------|
| `role`    | `"user"` or `"assistant"`       | Speaker role                    |
| `content` | `TextContent`, `ImageContent`, `AudioContent`, or `EmbeddedResource` | Message payload |

#### Text Content

```json
{
  "type": "text",
  "text": "The text content of the message"
}
```

The most common content type for natural language interactions.

#### Image Content

```json
{
  "type": "image",
  "data": "base64-encoded-image-data",
  "mimeType": "image/png"
}
```

The `data` field MUST be base64-encoded. The `mimeType` MUST be a valid image MIME type.

#### Audio Content

```json
{
  "type": "audio",
  "data": "base64-encoded-audio-data",
  "mimeType": "audio/wav"
}
```

The `data` field MUST be base64-encoded. The `mimeType` MUST be a valid audio MIME type.

#### Embedded Resource

Allows referencing server-side resources directly within prompt messages:

```json
{
  "type": "resource",
  "resource": {
    "uri": "resource://example",
    "mimeType": "text/plain",
    "text": "Resource content"
  }
}
```

For binary resources, use `blob` instead of `text`:

```json
{
  "type": "resource",
  "resource": {
    "uri": "resource://image-example",
    "mimeType": "image/png",
    "blob": "base64-encoded-data"
  }
}
```

Resource fields:

| Field      | Type     | Required         | Description                        |
|------------|----------|------------------|------------------------------------|
| `uri`      | `string` | Yes              | Valid resource URI                  |
| `mimeType` | `string` | Yes              | MIME type of the resource           |
| `text`     | `string` | One of text/blob | Text content                       |
| `blob`     | `string` | One of text/blob | Base64-encoded binary content      |

Embedded resources enable prompts to incorporate server-managed content such as
documentation, code samples, or reference materials directly into the conversation.

#### Multi-message example

A prompt can return multiple messages to set up a conversation:

```json
{
  "messages": [
    {
      "role": "user",
      "content": {
        "type": "text",
        "text": "Please review this code for security issues."
      }
    },
    {
      "role": "user",
      "content": {
        "type": "resource",
        "resource": {
          "uri": "file:///project/src/auth.ex",
          "mimeType": "text/x-elixir",
          "text": "defmodule MyApp.Auth do\n  # ...\nend"
        }
      }
    }
  ]
}
```

### 1.6 Prompt List Changes -- `notifications/prompts/list_changed`

When the list of available prompts changes, servers that declared `listChanged: true`
in their capability SHOULD send this notification. The notification has no params.

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/prompts/list_changed"
}
```

Upon receiving this notification, clients SHOULD re-fetch the prompt list via
`prompts/list`.

### 1.7 Dynamic vs Static Prompts

The MCP specification does not formally distinguish "dynamic" from "static" prompts at
the protocol level, but the design supports both patterns:

**Static prompts** have a fixed set of prompts that do not change after initialization.
Servers declare `listChanged: false` (or omit it). The prompt list returned by
`prompts/list` remains constant for the session lifetime.

**Dynamic prompts** change over time -- prompts may be added, removed, or modified based
on server-side state (e.g., database changes, configuration updates, user context).
Servers declare `listChanged: true` and emit `notifications/prompts/list_changed` when
the set changes.

Additionally, the `prompts/get` response itself can be dynamic. Even if the list of
prompt names is static, the messages returned for a given prompt can vary based on the
arguments provided or server-side state. This is the primary mechanism for
parameterized/template prompts.

### 1.8 Error Handling

Servers SHOULD return standard JSON-RPC errors:

| Code     | Meaning          | When                              |
|----------|------------------|-----------------------------------|
| `-32602` | Invalid params   | Invalid prompt name               |
| `-32602` | Invalid params   | Missing required arguments        |
| `-32603` | Internal error   | Server-side processing failure    |

---

## 2. Sampling

### 2.1 Overview

Sampling is the mechanism by which an MCP **server** can request LLM completions
("generations") through the **client**. This inverts the typical flow: instead of the
client calling the LLM, the server asks the client to perform an LLM call on its behalf.

This design enables:
- **Agentic behaviors** where LLM calls occur nested inside other MCP server features
- **No server API keys** -- the client maintains control over model access, selection,
  and permissions
- **Human-in-the-loop** -- the client can present requests to the user for approval

Servers can request text, audio, or image-based interactions and optionally include
context from MCP servers in their prompts.

**Direction:** Server calls Client.

| Method                      | Direction        | Description                      |
|-----------------------------|------------------|----------------------------------|
| `sampling/createMessage`    | Server -> Client | Request an LLM generation        |

### 2.2 Capability Declaration

Clients that support sampling MUST declare the `sampling` capability during
initialization:

```json
{
  "capabilities": {
    "sampling": {}
  }
}
```

Servers should check for this capability before attempting to send sampling requests.

### 2.3 Creating Messages -- `sampling/createMessage`

The server sends this request to ask the client to perform an LLM generation.

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
        { "name": "claude-3-sonnet" }
      ],
      "intelligencePriority": 0.8,
      "speedPriority": 0.5
    },
    "systemPrompt": "You are a helpful assistant.",
    "maxTokens": 100
  }
}
```

**Request params:**

| Field              | Type               | Required | Description                                 |
|--------------------|--------------------|----------|---------------------------------------------|
| `messages`         | `SamplingMessage[]`| Yes      | Conversation messages to send to the LLM    |
| `modelPreferences` | `ModelPreferences` | No       | Hints and priorities for model selection     |
| `systemPrompt`     | `string`          | No       | System prompt to prepend                    |
| `maxTokens`        | `integer`         | Yes      | Maximum tokens to generate                  |
| `stopSequences`    | `string[]`        | No       | Sequences that stop generation              |
| `metadata`         | `object`          | No       | Additional provider-specific parameters     |

**SamplingMessage** uses the same content types as PromptMessage:

| Field     | Type                                         | Description          |
|-----------|----------------------------------------------|----------------------|
| `role`    | `"user"` or `"assistant"`                    | Speaker role         |
| `content` | `TextContent`, `ImageContent`, or `AudioContent` | Message payload  |

### 2.4 Model Preferences

Model selection requires abstraction because servers and clients may use different AI
providers. A server cannot request a specific model by name since the client may not
have access to that model or may prefer a different provider's equivalent.

MCP solves this with a preference system combining capability priorities with optional
model hints.

#### Capability Priorities

Three normalized values (0.0 to 1.0):

| Field                  | Description                                           |
|------------------------|-------------------------------------------------------|
| `costPriority`         | Importance of minimizing cost. Higher = prefer cheaper models.     |
| `speedPriority`        | Importance of low latency. Higher = prefer faster models.          |
| `intelligencePriority` | Importance of advanced capabilities. Higher = prefer more capable. |

#### Model Hints

The `hints` array suggests specific models or model families:

```json
{
  "hints": [
    { "name": "claude-3-sonnet" },
    { "name": "claude" }
  ],
  "costPriority": 0.3,
  "speedPriority": 0.8,
  "intelligencePriority": 0.5
}
```

Hint behavior:
- Hints are treated as **substrings** that can match model names flexibly
- Multiple hints are evaluated **in order of preference**
- Clients MAY map hints to equivalent models from different providers (e.g., mapping
  `claude-3-sonnet` to `gemini-1.5-pro` if Claude is unavailable)
- Hints are **advisory** -- clients make the final model selection

#### Complete ModelPreferences structure

```json
{
  "modelPreferences": {
    "hints": [
      { "name": "claude-3-5-sonnet" },
      { "name": "claude-3-sonnet" },
      { "name": "claude" }
    ],
    "costPriority": 0.3,
    "speedPriority": 0.8,
    "intelligencePriority": 0.5
  }
}
```

### 2.5 Sampling Response

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

**Response result fields:**

| Field        | Type                            | Required | Description                        |
|--------------|---------------------------------|----------|------------------------------------|
| `role`       | `"user"` or `"assistant"`       | Yes      | Role of the generated message      |
| `content`    | `TextContent` or `ImageContent` | Yes      | Generated content                  |
| `model`      | `string`                        | Yes      | Name of the model that was used    |
| `stopReason` | `string`                        | No       | Why generation stopped (e.g., `"endTurn"`, `"stopSequence"`, `"maxTokens"`) |

### 2.6 Human-in-the-Loop

For trust, safety, and security, there SHOULD always be a human in the loop with the
ability to deny sampling requests.

The recommended approval flow:

```
Server                  Client                  User                    LLM
  |                       |                       |                      |
  |-- createMessage ----->|                       |                      |
  |                       |-- Present request --->|                      |
  |                       |                       |-- Approve/Modify     |
  |                       |<-- Approved request --|                      |
  |                       |                       |                      |
  |                       |-- Forward to LLM ------------------->|      |
  |                       |<-- Generation ----------------------|      |
  |                       |                       |                      |
  |                       |-- Present response -->|                      |
  |                       |                       |-- Approve/Modify     |
  |                       |<-- Approved response -|                      |
  |                       |                       |                      |
  |<-- Return response ---|                       |                      |
```

Applications SHOULD:
- Provide UI that makes it easy and intuitive to review sampling requests
- Allow users to view and edit prompts before sending
- Present generated responses for review before delivery back to the server

### 2.7 Security Considerations

1. Clients SHOULD implement user approval controls
2. Both parties SHOULD validate message content
3. Clients SHOULD respect model preference hints
4. Clients SHOULD implement rate limiting
5. Both parties MUST handle sensitive data appropriately

**Error example (user rejection):**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -1,
    "message": "User rejected sampling request"
  }
}
```

---

## 3. Roots

### 3.1 Overview

Roots define filesystem boundaries that a client exposes to servers. They tell servers
which directories and files they have access to, allowing servers to understand their
operational scope. Servers can request the list of roots from supporting clients and
receive notifications when the list changes.

Roots are typically exposed through workspace or project configuration interfaces (e.g.,
a workspace picker, automatic detection from VCS or project files).

**Direction:** Server calls Client.

| Method                              | Direction        | Description                      |
|-------------------------------------|------------------|----------------------------------|
| `roots/list`                        | Server -> Client | Discover available roots         |
| `notifications/roots/list_changed`  | Client -> Server | Signal root list has changed     |

### 3.2 Capability Declaration

Clients that support roots MUST declare the `roots` capability during initialization.
The `listChanged` field indicates whether the client will emit notifications when roots
change.

```json
{
  "capabilities": {
    "roots": {
      "listChanged": true
    }
  }
}
```

### 3.3 Listing Roots -- `roots/list`

Servers send this request to discover the filesystem roots exposed by the client.

**Request:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "roots/list"
}
```

Note: This method takes no params and does not support pagination.

**Response:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "roots": [
      {
        "uri": "file:///home/user/projects/myproject",
        "name": "My Project"
      }
    ]
  }
}
```

**Multiple roots example:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "roots": [
      {
        "uri": "file:///home/user/repos/frontend",
        "name": "Frontend Repository"
      },
      {
        "uri": "file:///home/user/repos/backend",
        "name": "Backend Repository"
      }
    ]
  }
}
```

### 3.4 Root List Changes -- `notifications/roots/list_changed`

When roots change, clients that declared `listChanged: true` MUST send this notification:

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/roots/list_changed"
}
```

Upon receiving this notification, servers SHOULD re-fetch the root list via `roots/list`.

### 3.5 Data Types

#### Root

| Field  | Type     | Required | Description                                                |
|--------|----------|----------|------------------------------------------------------------|
| `uri`  | `string` | Yes      | MUST be a `file://` URI in the current specification       |
| `name` | `string` | No       | Optional human-readable name for display                   |

### 3.6 Error Handling

| Code     | Meaning            | When                                 |
|----------|--------------------|--------------------------------------|
| `-32601` | Method not found   | Client does not support roots        |
| `-32603` | Internal error     | Server-side processing failure       |

**Error example:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -32601,
    "message": "Roots not supported",
    "data": {
      "reason": "Client does not have roots capability"
    }
  }
}
```

### 3.7 Security Considerations

**Clients MUST:**
- Only expose roots with appropriate permissions
- Validate all root URIs to prevent path traversal
- Implement proper access controls
- Monitor root accessibility

**Servers SHOULD:**
- Handle cases where roots become unavailable
- Respect root boundaries during operations
- Validate all paths against provided roots
- Cache root information appropriately

**Clients SHOULD:**
- Prompt users for consent before exposing roots to servers
- Provide clear UI for root management
- Validate root accessibility before exposing
- Monitor for root changes

---

## 4. Implementation Notes for Elixir

### Module Structure Suggestions

```
lib/mcp/
  server/
    prompts.ex          # Prompt registry, list/get handlers
    prompt.ex           # Prompt struct and PromptMessage types
  client/
    sampling.ex         # Sampling request handler (createMessage)
    roots.ex            # Roots list and change notification handler
  types/
    content.ex          # TextContent, ImageContent, AudioContent, EmbeddedResource
    model_preferences.ex # ModelPreferences, ModelHint structs
```

### Key Type Mappings

| MCP Type           | Elixir Representation                                       |
|--------------------|--------------------------------------------------------------|
| `Prompt`           | `%MCP.Prompt{name: String.t(), description: String.t() \| nil, arguments: [PromptArgument.t()]}` |
| `PromptArgument`   | `%MCP.PromptArgument{name: String.t(), description: String.t() \| nil, required: boolean()}` |
| `PromptMessage`    | `%MCP.PromptMessage{role: :user \| :assistant, content: content()}` |
| `TextContent`      | `%MCP.Content.Text{type: "text", text: String.t()}`         |
| `ImageContent`     | `%MCP.Content.Image{type: "image", data: String.t(), mime_type: String.t()}` |
| `AudioContent`     | `%MCP.Content.Audio{type: "audio", data: String.t(), mime_type: String.t()}` |
| `EmbeddedResource` | `%MCP.Content.Resource{type: "resource", resource: resource_body()}` |
| `ModelPreferences`  | `%MCP.ModelPreferences{hints: [hint()], cost_priority: float(), speed_priority: float(), intelligence_priority: float()}` |
| `Root`             | `%MCP.Root{uri: String.t(), name: String.t() \| nil}`       |

### Capability Negotiation

During initialization, both sides exchange capabilities. The server advertises prompt
support; the client advertises sampling and roots support:

```elixir
# Server capabilities (sent by server during initialize response)
%{
  "capabilities" => %{
    "prompts" => %{"listChanged" => true}
  }
}

# Client capabilities (sent by client during initialize request)
%{
  "capabilities" => %{
    "sampling" => %{},
    "roots" => %{"listChanged" => true}
  }
}
```

### Direction Summary

| Feature   | Who declares capability | Who initiates requests | Who sends notifications     |
|-----------|------------------------|------------------------|-----------------------------|
| Prompts   | Server                 | Client                 | Server (`list_changed`)     |
| Sampling  | Client                 | Server                 | N/A                         |
| Roots     | Client                 | Server                 | Client (`list_changed`)     |
