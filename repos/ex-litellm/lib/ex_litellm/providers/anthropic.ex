defmodule ExLiteLLM.Providers.Anthropic do
  @moduledoc """
  Anthropic provider — the one fully-distinct adapter (litellm's `AnthropicConfig`).

  Anthropic's Messages API differs from OpenAI in several ways this module
  translates:

    * **System prompt** is a top-level `system` field, not a message with
      `role: "system"`.
    * **max_tokens is required** (Anthropic rejects requests without it).
    * **Content blocks** — responses carry a `content` array of typed blocks
      (`text`, `tool_use`, `thinking`); we flatten `text` blocks into the OpenAI
      `message.content` string and map `tool_use` blocks to OpenAI `tool_calls`.
    * **Auth** uses `x-api-key` + `anthropic-version`, not `Authorization`.
    * **Streaming** emits typed events (`content_block_delta`, `message_delta`,
      `message_stop`) rather than OpenAI `chat.completion.chunk` frames.

  Request/response translation here targets the chat-completions contract so a
  client calling ex-litellm with `model: anthropic/claude-…` gets OpenAI-shaped
  output regardless.
  """
  @behaviour ExLiteLLM.Providers.Adapter

  alias ExLiteLLM.Config.Secret
  alias ExLiteLLM.Core.ModelResponse
  alias ExLiteLLM.Error
  alias ExLiteLLM.Providers.Adapter.Request

  @api_version "2023-06-01"
  @default_base "https://api.anthropic.com/v1"
  @default_max_tokens 4096

  @supported ~w(
    model messages temperature top_p top_k stream stop max_tokens
    max_completion_tokens tools tool_choice user metadata reasoning_effort
  )

  @impl true
  def get_supported_openai_params(_model), do: @supported

  @impl true
  def map_openai_params(non_default, optional, _model, drop?) do
    Enum.reduce(non_default, optional, fn {k, v}, acc ->
      cond do
        k in @supported -> Map.put(acc, k, v)
        drop? -> acc
        true -> Map.put(acc, k, v)
      end
    end)
  end

  @impl true
  def validate_environment(%Request{litellm_params: lp}, headers) do
    case resolve_key(lp) do
      nil ->
        {:error,
         Error.new(401, "no Anthropic API key (checked litellm_params.api_key and ANTHROPIC_API_KEY)",
           type: "authentication_error",
           provider: :anthropic
         )}

      key ->
        {:ok,
         headers
         |> Map.put("x-api-key", key)
         |> Map.put("anthropic-version", @api_version)
         |> Map.put("content-type", "application/json")
         |> merge_extra_headers(lp["extra_headers"])}
    end
  end

  # Deployment-level extra_headers (e.g. zai's `anthropic-product: claude_code`).
  defp merge_extra_headers(headers, %{} = extra) do
    Enum.reduce(extra, headers, fn {k, v}, acc -> Map.put(acc, to_string(k), to_string(v)) end)
  end

  defp merge_extra_headers(headers, _), do: headers

  @impl true
  def get_complete_url(%Request{litellm_params: lp}) do
    base = (lp["api_base"] || @default_base) |> String.trim_trailing("/")

    cond do
      # Full endpoint already given.
      String.ends_with?(base, "/messages") -> base
      # Versioned base (our default "https://api.anthropic.com/v1").
      String.ends_with?(base, "/v1") -> base <> "/messages"
      # Unversioned Anthropic-compatible base (e.g. https://api.z.ai/api/anthropic)
      # — the Anthropic SDK convention appends the full /v1/messages.
      true -> base <> "/v1/messages"
    end
  end

  @impl true
  def transform_request(%Request{model: model, messages: messages, params: params}) do
    {system, chat_messages} = split_system(messages)

    %{
      "model" => model,
      "messages" => Enum.map(chat_messages, &translate_message/1),
      "max_tokens" => params["max_tokens"] || params["max_completion_tokens"] || @default_max_tokens
    }
    |> put_if("system", system)
    |> copy_param(params, "temperature")
    |> copy_param(params, "top_p")
    |> copy_param(params, "top_k")
    |> copy_param(params, "stop", "stop_sequences")
    |> put_tools(params)
    |> put_stream(params)
  end

  @impl true
  def transform_response(raw, %Request{model: model}) when is_map(raw) do
    {text, tool_calls} = flatten_content(raw["content"] || [])

    message =
      %{"role" => "assistant", "content" => text}
      |> put_if("tool_calls", nilify_empty(tool_calls))

    ModelResponse.new(%{
      id: raw["id"],
      object: "chat.completion",
      model: raw["model"] || model,
      choices: [
        %{
          index: 0,
          message: message,
          finish_reason: map_stop_reason(raw["stop_reason"])
        }
      ],
      usage: map_usage(raw["usage"])
    })
  end

  @impl true
  def get_error_class(status, body, _headers) do
    msg =
      case body do
        %{"error" => %{"message" => m}} -> m
        %{"error" => %{"type" => t}} -> t
        _ -> "anthropic provider error"
      end

    Error.new(status, msg, provider: :anthropic)
  end

  @impl true
  def chunk_parser(:done), do: :done

  # Anthropic streaming events are typed; normalize the ones that carry deltas.
  def chunk_parser(%{"type" => type} = event) do
    case type do
      "content_block_delta" ->
        delta = event["delta"] || %{}

        %{
          text: delta["text"] || "",
          is_finished: false,
          finish_reason: nil,
          usage: nil,
          tool_use: tool_use_delta(delta),
          index: event["index"] || 0,
          raw: event
        }

      "message_delta" ->
        %{
          text: "",
          is_finished: true,
          finish_reason: map_stop_reason(get_in(event, ["delta", "stop_reason"])),
          usage: map_usage(event["usage"]),
          tool_use: nil,
          index: 0,
          raw: event
        }

      "message_stop" ->
        :done

      _ ->
        # message_start, content_block_start/stop, ping — no client-visible delta
        %{text: "", is_finished: false, finish_reason: nil, usage: nil, tool_use: nil, index: 0, raw: event}
    end
  end

  def chunk_parser(other),
    do: %{text: "", is_finished: false, finish_reason: nil, usage: nil, tool_use: nil, index: 0, raw: other}

  # --- request translation ---

  defp split_system(messages) do
    {systems, rest} =
      Enum.split_with(messages, fn m -> (m["role"] || m[:role]) == "system" end)

    system =
      systems
      |> Enum.map(&content_to_string(&1["content"] || &1[:content]))
      |> Enum.reject(&(&1 in [nil, ""]))
      |> Enum.join("\n\n")

    {blank_to_nil(system), rest}
  end

  defp translate_message(m) do
    role = m["role"] || m[:role]
    content = m["content"] || m[:content]

    %{
      "role" => role,
      "content" => translate_content(content)
    }
  end

  # OpenAI content can be a plain string or an array of parts; Anthropic accepts
  # a string or typed blocks. Strings pass straight through.
  defp translate_content(content) when is_binary(content), do: content

  defp translate_content(parts) when is_list(parts) do
    Enum.map(parts, fn
      %{"type" => "text", "text" => t} -> %{"type" => "text", "text" => t}
      %{"type" => "image_url", "image_url" => %{"url" => url}} -> image_block(url)
      other -> other
    end)
  end

  defp translate_content(other), do: other

  defp image_block("data:" <> _ = data_url) do
    case String.split(data_url, ",", parts: 2) do
      [meta, b64] ->
        media_type = meta |> String.replace_prefix("data:", "") |> String.split(";") |> List.first()
        %{"type" => "image", "source" => %{"type" => "base64", "media_type" => media_type, "data" => b64}}

      _ ->
        %{"type" => "text", "text" => data_url}
    end
  end

  defp image_block(url), do: %{"type" => "image", "source" => %{"type" => "url", "url" => url}}

  defp put_tools(body, %{"tools" => tools}) when is_list(tools) do
    Map.put(body, "tools", Enum.map(tools, &translate_tool/1))
  end

  defp put_tools(body, _), do: body

  # OpenAI tool → Anthropic tool shape.
  defp translate_tool(%{"function" => fun}) do
    %{
      "name" => fun["name"],
      "description" => fun["description"],
      "input_schema" => fun["parameters"] || %{"type" => "object", "properties" => %{}}
    }
  end

  defp translate_tool(tool), do: tool

  defp put_stream(body, %{"stream" => true}), do: Map.put(body, "stream", true)
  defp put_stream(body, _), do: body

  # --- response translation ---

  defp flatten_content(blocks) do
    Enum.reduce(blocks, {"", []}, fn block, {text, tools} ->
      case block do
        %{"type" => "text", "text" => t} ->
          {text <> t, tools}

        %{"type" => "tool_use", "id" => id, "name" => name, "input" => input} ->
          call = %{
            "id" => id,
            "type" => "function",
            "function" => %{"name" => name, "arguments" => Jason.encode!(input)}
          }

          {text, tools ++ [call]}

        %{"type" => "thinking"} ->
          # Thinking blocks aren't part of the OpenAI message body; skip.
          {text, tools}

        _ ->
          {text, tools}
      end
    end)
  end

  defp tool_use_delta(%{"type" => "input_json_delta", "partial_json" => pj}), do: pj
  defp tool_use_delta(_), do: nil

  defp map_stop_reason("end_turn"), do: "stop"
  defp map_stop_reason("max_tokens"), do: "length"
  defp map_stop_reason("stop_sequence"), do: "stop"
  defp map_stop_reason("tool_use"), do: "tool_calls"
  defp map_stop_reason(nil), do: nil
  defp map_stop_reason(other), do: other

  defp map_usage(nil), do: nil

  defp map_usage(usage) do
    input = usage["input_tokens"] || 0
    output = usage["output_tokens"] || 0

    %{
      prompt_tokens: input,
      completion_tokens: output,
      total_tokens: input + output
    }
  end

  # --- helpers ---

  defp resolve_key(lp) do
    cond do
      is_binary(lp["api_key"]) and lp["api_key"] != "" -> Secret.resolve(lp["api_key"])
      true -> System.get_env("ANTHROPIC_API_KEY") || System.get_env("ANTHROPIC_AUTH_TOKEN")
    end
  end

  defp content_to_string(c) when is_binary(c), do: c

  defp content_to_string(parts) when is_list(parts) do
    parts
    |> Enum.map(fn
      %{"text" => t} -> t
      %{text: t} -> t
      _ -> ""
    end)
    |> Enum.join("")
  end

  defp content_to_string(_), do: ""

  defp copy_param(body, params, key, as \\ nil) do
    case Map.get(params, key) do
      nil -> body
      v -> Map.put(body, as || key, v)
    end
  end

  defp put_if(map, _key, nil), do: map
  defp put_if(map, key, value), do: Map.put(map, key, value)

  defp nilify_empty([]), do: nil
  defp nilify_empty(list), do: list

  defp blank_to_nil(""), do: nil
  defp blank_to_nil(v), do: v
end
