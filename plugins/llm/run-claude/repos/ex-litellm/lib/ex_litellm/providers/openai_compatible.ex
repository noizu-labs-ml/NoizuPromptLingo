defmodule ExLiteLLM.Providers.OpenAICompatible do
  @moduledoc """
  Base for OpenAI-compatible providers — litellm's `OpenAILikeChatConfig`.

  `use ExLiteLLM.Providers.OpenAICompatible, base_url: ..., api_key_env: ...`
  gives a provider the full OpenAI request/response/stream transforms for free.
  A thin adapter (Groq, Cerebras, DeepSeek, …) only needs to declare its default
  base URL and API-key env var; everything else is inherited and overridable.

  Options:

    * `:base_url`     — default `api_base` when the deployment omits one
    * `:api_key_env`  — env var holding the key (e.g. `"GROQ_API_KEY"`)
    * `:chat_path`    — path appended to the base (default `/chat/completions`)
    * `:embed_path`   — embeddings path (default `/embeddings`)

  All generated callbacks are `defoverridable`, so a provider can specialize any
  single step (e.g. `map_openai_params/4` to drop an unsupported field).
  """

  @doc false
  defmacro __using__(opts) do
    base_url = Keyword.fetch!(opts, :base_url)
    api_key_env = Keyword.get(opts, :api_key_env)
    chat_path = Keyword.get(opts, :chat_path, "/chat/completions")
    embed_path = Keyword.get(opts, :embed_path, "/embeddings")

    quote location: :keep do
      @behaviour ExLiteLLM.Providers.Adapter

      alias ExLiteLLM.Providers.Adapter.Request
      alias ExLiteLLM.Providers.OpenAICompatible.Shared

      @default_base_url unquote(base_url)
      @api_key_env unquote(api_key_env)
      @chat_path unquote(chat_path)
      @embed_path unquote(embed_path)

      @impl true
      def get_supported_openai_params(_model), do: Shared.default_supported_params()

      @impl true
      def map_openai_params(non_default, optional, model, drop?),
        do: Shared.map_openai_params(non_default, optional, model, drop?, __MODULE__)

      @impl true
      def validate_environment(%Request{} = req, headers),
        do: Shared.validate_environment(req, headers, @api_key_env)

      @impl true
      def get_complete_url(%Request{} = req),
        do: Shared.complete_url(req, @default_base_url, @chat_path, @embed_path)

      @impl true
      def transform_request(%Request{} = req), do: Shared.transform_request(req)

      @impl true
      def transform_response(raw, %Request{} = req), do: Shared.transform_response(raw, req)

      @impl true
      def get_error_class(status, body, headers),
        do: Shared.get_error_class(status, body, headers)

      @impl true
      def chunk_parser(event), do: Shared.chunk_parser(event)

      defoverridable get_supported_openai_params: 1,
                     map_openai_params: 4,
                     validate_environment: 2,
                     get_complete_url: 1,
                     transform_request: 1,
                     transform_response: 2,
                     get_error_class: 3,
                     chunk_parser: 1
    end
  end
end
