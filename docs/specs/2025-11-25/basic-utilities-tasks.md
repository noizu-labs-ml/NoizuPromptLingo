<!-- Source: https://modelcontextprotocol.io/specification/2025-11-25/basic/utilities/tasks -->
<!-- Fetched: 2026-06-13 -->

# Tasks

> Tasks were introduced in version 2025-11-25 of the MCP specification and are currently considered **experimental**. The design and behavior of tasks may evolve in future protocol versions.

The Model Context Protocol (MCP) allows requestors -- which can be either clients or servers, depending on the direction of communication -- to augment their requests with **tasks**. Tasks are durable state machines that carry information about the underlying execution state of the request they wrap, and are intended for requestor polling and deferred result retrieval. Each task is uniquely identifiable by a receiver-generated **task ID**.

Tasks are useful for representing expensive computations and batch processing requests, and integrate seamlessly with external job APIs.

## Definitions

* **Requestor:** The sender of a task-augmented request. This can be the client or the server.
* **Receiver:** The receiver of a task-augmented request, and the entity executing the task. This can be the client or the server.

## User Interaction Model

Tasks are designed to be **requestor-driven** - requestors are responsible for augmenting requests with tasks and for polling for the results of those tasks; meanwhile, receivers tightly control which requests (if any) support task-based execution and manages the lifecycles of those tasks.

## Capabilities

Servers and clients that support task-augmented requests **MUST** declare a `tasks` capability during initialization.

### Server Capabilities

| Capability                  | Description                                          |
| --------------------------- | ---------------------------------------------------- |
| `tasks.list`                | Server supports the `tasks/list` operation           |
| `tasks.cancel`              | Server supports the `tasks/cancel` operation         |
| `tasks.requests.tools.call` | Server supports task-augmented `tools/call` requests |

```json
{
  "capabilities": {
    "tasks": {
      "list": {},
      "cancel": {},
      "requests": {
        "tools": {
          "call": {}
        }
      }
    }
  }
}
```

### Client Capabilities

| Capability                              | Description                                                      |
| --------------------------------------- | ---------------------------------------------------------------- |
| `tasks.list`                            | Client supports the `tasks/list` operation                       |
| `tasks.cancel`                          | Client supports the `tasks/cancel` operation                     |
| `tasks.requests.sampling.createMessage` | Client supports task-augmented `sampling/createMessage` requests |
| `tasks.requests.elicitation.create`     | Client supports task-augmented `elicitation/create` requests     |

### Capability Negotiation

During initialization, both parties exchange their `tasks` capabilities. Requestors **SHOULD** only augment requests with a task if the corresponding capability has been declared by the receiver.

If `capabilities.tasks` is not defined, the peer **SHOULD NOT** attempt to create tasks.

### Tool-Level Negotiation

In `tools/list` results, tools declare support for tasks via `execution.taskSupport`:

1. If server capabilities do not include `tasks.requests.tools.call`, clients **MUST NOT** use task augmentation regardless of `execution.taskSupport`.
2. If server capabilities include `tasks.requests.tools.call`:
   * `"forbidden"` or not present (default): clients **MUST NOT** invoke the tool as a task
   * `"optional"`: clients **MAY** invoke the tool as a task or normal request
   * `"required"`: clients **MUST** invoke the tool as a task

## Protocol Messages

### Creating Tasks

To create a task, requestors send a request with the `task` field included in the request params.

**Request:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "get_weather",
    "arguments": {
      "city": "New York"
    },
    "task": {
      "ttl": 60000
    }
  }
}
```

**Response:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "task": {
      "taskId": "786512e2-9e0d-44bd-8f29-789f320fe840",
      "status": "working",
      "statusMessage": "The operation is now in progress.",
      "createdAt": "2025-11-25T10:30:00Z",
      "lastUpdatedAt": "2025-11-25T10:40:00Z",
      "ttl": 60000,
      "pollInterval": 5000
    }
  }
}
```

When a receiver accepts a task-augmented request, it returns a `CreateTaskResult` containing task data. The response does not include the actual operation result. The actual result becomes available only through `tasks/result` after the task completes.

### Getting Tasks

Requestors poll for task completion by sending `tasks/get` requests. Requestors **SHOULD** respect the `pollInterval` provided in responses.

Requestors **SHOULD** continue polling until the task reaches a terminal status (`completed`, `failed`, or `cancelled`), or until encountering the `input_required` status.

**Request:**

```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tasks/get",
  "params": {
    "taskId": "786512e2-9e0d-44bd-8f29-789f320fe840"
  }
}
```

### Retrieving Task Results

After a task completes, the operation result is retrieved via `tasks/result`. The result structure matches the original request type (e.g., `CallToolResult` for `tools/call`).

**Request:**

```json
{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "tasks/result",
  "params": {
    "taskId": "786512e2-9e0d-44bd-8f29-789f320fe840"
  }
}
```

**Response:**

```json
{
  "jsonrpc": "2.0",
  "id": 4,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Current weather in New York:\nTemperature: 72F\nConditions: Partly cloudy"
      }
    ],
    "isError": false,
    "_meta": {
      "io.modelcontextprotocol/related-task": {
        "taskId": "786512e2-9e0d-44bd-8f29-789f320fe840"
      }
    }
  }
}
```

### Task Status Notification

When a task status changes, receivers **MAY** send a `notifications/tasks/status` notification. Requestors **MUST NOT** rely on receiving this notification.

### Listing Tasks

To retrieve a list of tasks, requestors send a `tasks/list` request. This operation supports pagination.

### Cancelling Tasks

To cancel a task, requestors send a `tasks/cancel` request.

## Behavior Requirements

### Task ID Requirements

1. Task IDs **MUST** be a string value.
2. Task IDs **MUST** be generated by the receiver.
3. Task IDs **MUST** be unique among all tasks controlled by the receiver.

### Task Status Lifecycle

1. Tasks **MUST** begin in the `working` status when created.
2. Valid transitions:
   * From `working`: may move to `input_required`, `completed`, `failed`, or `cancelled`
   * From `input_required`: may move to `working`, `completed`, `failed`, or `cancelled`
   * `completed`, `failed`, or `cancelled` are terminal states and **MUST NOT** transition further

### Input Required Status

1. When the task receiver has messages for the requestor necessary to complete the task, the receiver **SHOULD** move the task to `input_required` status.
2. The receiver **MUST** include `io.modelcontextprotocol/related-task` metadata in the request.
3. When the requestor encounters `input_required`, it **SHOULD** preemptively call `tasks/result`.
4. When the receiver receives all required input, the task **SHOULD** transition back to `working`.

### TTL and Resource Management

1. Receivers **MUST** include `createdAt` and `lastUpdatedAt` ISO 8601 timestamps in all task responses.
2. Receivers **MAY** override the requested `ttl` duration.
3. Receivers **MUST** include the actual `ttl` duration (or `null` for unlimited) in responses.
4. After a task's `ttl` has elapsed, receivers **MAY** delete the task and its results.
5. Receivers **MAY** include a `pollInterval` value (in milliseconds) to suggest polling intervals.

### Result Retrieval

1. Receivers that accept a task-augmented request **MUST** return a `CreateTaskResult` as the response.
2. For tasks in terminal status, `tasks/result` **MUST** return exactly what the underlying request would have returned.
3. For tasks in non-terminal status, `tasks/result` **MUST** block until the task reaches a terminal status.

### Associating Task-Related Messages

1. All requests, notifications, and responses related to a task **MUST** include `io.modelcontextprotocol/related-task` in `_meta` with the associated task ID.
2. For `tasks/get`, `tasks/result`, and `tasks/cancel`, the `taskId` parameter is the source of truth.

### Task Cancellation

1. Receivers **MUST** reject cancellation for tasks already in a terminal status with error code `-32602`.
2. Once cancelled, a task **MUST** remain in `cancelled` status.

## Data Types

### Task

* `taskId`: Unique identifier
* `status`: Current state (`working`, `input_required`, `completed`, `failed`, `cancelled`)
* `statusMessage`: Optional human-readable message
* `createdAt`: ISO 8601 timestamp
* `ttl`: Time in milliseconds from creation before task may be deleted
* `pollInterval`: Suggested time in milliseconds between status checks
* `lastUpdatedAt`: ISO 8601 timestamp of last status update

### Task Parameters

```json
{
  "task": {
    "ttl": 60000
  }
}
```

### Related Task Metadata

```json
{
  "io.modelcontextprotocol/related-task": {
    "taskId": "786512e2-9e0d-44bd-8f29-789f320fe840"
  }
}
```

## Error Handling

### Protocol Errors

* Invalid or nonexistent `taskId`: `-32602` (Invalid params)
* Invalid or nonexistent cursor in `tasks/list`: `-32602` (Invalid params)
* Attempt to cancel a terminal task: `-32602` (Invalid params)
* Internal errors: `-32603` (Internal error)
* Non-task-augmented request when required: `-32600` (Invalid request)

### Task Execution Errors

When the underlying request fails, the task moves to `failed` status. The `tasks/get` response **SHOULD** include a `statusMessage` with diagnostic information.

For `tasks/result`, the endpoint returns exactly what the underlying request would have returned -- either a JSON-RPC error or a successful result.

## Security Considerations

### Task Isolation and Access Control

When an authorization context is provided, receivers **MUST** bind tasks to said context.

If context-binding is unavailable:
* Receivers **MUST** generate cryptographically secure task IDs
* Receivers **SHOULD** consider shorter TTL durations
* Receivers **SHOULD NOT** declare the `tasks.list` capability

If context-binding is available:
* Receivers **MUST** reject requests for tasks that do not belong to the requestor's authorization context
* `tasks/list` **MUST** only return tasks for the requestor's context

### Resource Management

Receivers **SHOULD**: enforce limits on concurrent tasks per requestor, enforce maximum `ttl` durations, clean up expired tasks promptly, and implement monitoring.
