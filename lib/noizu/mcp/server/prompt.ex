defmodule Noizu.MCP.Server.Prompt do
  @moduledoc """
  Define an MCP prompt as a module.

      defmodule MyApp.MCP.CodeReview do
        use Noizu.MCP.Server.Prompt,
          name: "code_review",
          description: "Review code for quality issues"

        arguments do
          arg :code, required: true, description: "The code to review"
          arg :style, description: "Review style", complete: ["strict", "friendly"]
        end

        @impl true
        def get(%{"code" => code} = args, _ctx) do
          style = args["style"] || "strict"

          {:ok,
           [
             Noizu.MCP.Types.PromptMessage.user("Review this code (style: \#{style}):"),
             Noizu.MCP.Types.PromptMessage.user(code)
           ]}
        end
      end

  Prompt arguments are protocol-level string key/values (no JSON Schema), so
  `c:get/2` receives them **string-keyed**. Declared `required:` arguments are
  checked by the runtime before `c:get/2` runs. The `complete:` option provides
  static, prefix-filtered completion for an argument; override `c:complete/3`
  for dynamic completion.

  ## Return values from `c:get/2`

    * `{:ok, [PromptMessage.t()]}`
    * `{:ok, [PromptMessage.t()], description: "..."}`
    * `{:error, Noizu.MCP.Error.t()}`
  """

  alias Noizu.MCP.Types

  @callback get(args :: map(), ctx :: Noizu.MCP.Ctx.t()) ::
              {:ok, [Types.PromptMessage.t()]}
              | {:ok, [Types.PromptMessage.t()], keyword()}
              | {:error, term()}

  @callback complete(argument :: atom(), value :: String.t(), ctx :: Noizu.MCP.Ctx.t()) ::
              {:ok, [String.t()]} | {:ok, [String.t()], keyword()} | {:error, term()}

  @doc "The wire definition advertised by `prompts/list`."
  @callback definition() :: Types.Prompt.t()

  @doc false
  @callback __mcp_prompt__(:static_completions) :: map()

  @optional_callbacks complete: 3

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Noizu.MCP.Server.Prompt
      import Noizu.MCP.Server.Prompt, only: [arguments: 1]

      @__mcp_prompt_opts__ opts
      @__mcp_prompt_args__ []

      @before_compile Noizu.MCP.Server.Prompt
    end
  end

  @doc "Declare prompt arguments with `arg/1,2`."
  defmacro arguments(do: block) do
    args = extract_args(block, __CALLER__)

    quote do
      @__mcp_prompt_args__ unquote(Macro.escape(args))
    end
  end

  defp extract_args(block, caller) do
    statements =
      case block do
        {:__block__, _, statements} -> statements
        nil -> []
        single -> [single]
      end

    Enum.map(statements, fn
      {:arg, _, [name | rest]} when is_atom(name) ->
        opts =
          case rest do
            [] ->
              []

            [opts] ->
              {evaluated, _} = Code.eval_quoted(opts, [], caller)
              evaluated
          end

        {name, opts}

      other ->
        raise CompileError,
          file: caller.file,
          description:
            "only `arg name, opts` declarations are allowed inside arguments, got: " <>
              Macro.to_string(other)
    end)
  end

  defmacro __before_compile__(env) do
    opts = Module.get_attribute(env.module, :__mcp_prompt_opts__)
    args = Module.get_attribute(env.module, :__mcp_prompt_args__)

    default_name =
      env.module
      |> Module.split()
      |> List.last()
      |> Macro.underscore()

    name = Keyword.get(opts, :name, default_name)

    arguments =
      Enum.map(args, fn {arg_name, arg_opts} ->
        %Types.Prompt.Argument{
          name: to_string(arg_name),
          title: arg_opts[:title],
          description: arg_opts[:description],
          required: arg_opts[:required] == true
        }
      end)

    static_completions =
      for {arg_name, arg_opts} <- args,
          values = arg_opts[:complete],
          is_list(values),
          into: %{} do
        {to_string(arg_name), Enum.map(values, &to_string/1)}
      end

    quote do
      @impl Noizu.MCP.Server.Prompt
      def definition do
        %Noizu.MCP.Types.Prompt{
          name: unquote(name),
          title: unquote(opts[:title]),
          description: unquote(opts[:description]),
          arguments: unquote(Macro.escape(arguments)),
          icons: unquote(opts[:icons]),
          meta: unquote(opts[:meta])
        }
      end

      @impl Noizu.MCP.Server.Prompt
      def __mcp_prompt__(:static_completions), do: unquote(Macro.escape(static_completions))
    end
  end
end
