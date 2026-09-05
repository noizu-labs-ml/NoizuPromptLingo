defmodule Noizu.MCP.Fixtures.Echo do
  @moduledoc false
  use Noizu.MCP.Server.Tool,
    description: "Echo a message back",
    annotations: [read_only_hint: true]

  input do
    field :message, :string, required: true, description: "Message to echo"
    field :repeat, :integer, min: 1, max: 10, default: 1
    field :mode, :enum, values: [:plain, :loud], default: :plain
  end

  @impl true
  # ⟦𓉬𓊌𓏌𓀳⟧ call :: auto-generated pointer for public function call
  def call(%{message: message, repeat: repeat, mode: mode}, _ctx) do
    text = String.duplicate(message, repeat)
    {:ok, if(mode == :loud, do: String.upcase(text), else: text)}
  end
end

defmodule Noizu.MCP.Fixtures.Weather do
  @moduledoc false
  use Noizu.MCP.Server.Tool,
    name: "get_weather",
    description: "Get current weather"

  input do
    field :location, :string, required: true
  end

  output do
    field :temperature, :number, required: true
    field :conditions, :string, required: true
  end

  @impl true
  def call(%{location: _location}, ctx) do
    Noizu.MCP.Ctx.report_progress(ctx, 0.5, message: "querying provider")
    Noizu.MCP.Ctx.info(ctx, "cache miss")
    {:ok, %{temperature: 21.5, conditions: "clear"}}
  end
end

defmodule Noizu.MCP.Fixtures.Slow do
  @moduledoc false
  use Noizu.MCP.Server.Tool, description: "Sleeps until cancelled"

  input do
    field :ms, :integer, default: 5_000
  end

  @impl true
  def call(%{ms: ms}, _ctx) do
    Process.sleep(ms)
    {:ok, "done"}
  end
end

defmodule Noizu.MCP.Fixtures.Crash do
  @moduledoc false
  use Noizu.MCP.Server.Tool, description: "Always raises"

  @impl true
  def call(_args, _ctx), do: raise("boom")
end

defmodule Noizu.MCP.Fixtures.Fail do
  @moduledoc false
  use Noizu.MCP.Server.Tool, description: "Always returns an execution error"

  @impl true
  def call(_args, _ctx), do: {:error, "it failed, try again with flag=true"}
end

defmodule Noizu.MCP.Fixtures.RawSchema do
  @moduledoc false
  use Noizu.MCP.Server.Tool,
    name: "raw_schema",
    description: "Uses a raw JSON Schema"

  input_schema %{
    "type" => "object",
    "properties" => %{"query" => %{"type" => "string", "minLength" => 2}},
    "required" => ["query"]
  }

  @impl true
  def call(%{"query" => query}, _ctx), do: {:ok, "raw:#{query}"}
end

defmodule Noizu.MCP.Fixtures.Consult do
  @moduledoc false
  # Exercises server→client sampling from inside a tool call.
  use Noizu.MCP.Server.Tool, description: "Asks the client's LLM a question"

  input do
    field :question, :string, required: true
  end

  @impl true
  def call(%{question: question}, ctx) do
    params = %{
      "messages" => [
        %{"role" => "user", "content" => %{"type" => "text", "text" => question}}
      ],
      "maxTokens" => 100
    }

    case Noizu.MCP.Ctx.sample(ctx, params, timeout: 2_000) do
      {:ok, result} -> {:ok, "sampled: #{result["content"]["text"]}"}
      {:error, reason} -> {:error, "sampling failed: #{inspect(reason)}"}
    end
  end
end

defmodule Noizu.MCP.Fixtures.AskApproval do
  @moduledoc false
  # Exercises server→client elicitation from inside a tool call.
  use Noizu.MCP.Server.Tool, description: "Asks the user for confirmation"

  @impl true
  def call(_args, ctx) do
    schema = %{
      "type" => "object",
      "properties" => %{"confirm" => %{"type" => "boolean"}},
      "required" => ["confirm"]
    }

    case Noizu.MCP.Ctx.elicit(ctx, "Proceed?", schema, timeout: 2_000) do
      {:ok, {:accept, %{"confirm" => true}}} -> {:ok, "approved"}
      {:ok, {:accept, _}} -> {:ok, "rejected"}
      {:ok, :decline} -> {:ok, "declined"}
      {:ok, :cancel} -> {:ok, "cancelled"}
      {:error, reason} -> {:error, "elicitation failed: #{inspect(reason)}"}
    end
  end
end

defmodule Noizu.MCP.Fixtures.WhereAmI do
  @moduledoc false
  # Exercises server→client roots/list from inside a tool call.
  use Noizu.MCP.Server.Tool, name: "where_am_i", description: "Lists the client's roots"

  @impl true
  def call(_args, ctx) do
    case Noizu.MCP.Ctx.list_roots(ctx, timeout: 2_000) do
      {:ok, roots} -> {:ok, Enum.map_join(roots, ",", & &1.uri)}
      {:error, reason} -> {:error, "roots failed: #{inspect(reason)}"}
    end
  end
end

defmodule Noizu.MCP.Fixtures.ClientHandler do
  @moduledoc false
  @behaviour Noizu.MCP.Client.Handler

  @impl true
  # ⟦𓀶𓀀𓎆𓎩⟧ handle_sampling :: auto-generated pointer for public function handle_sampling
  def handle_sampling(params, test_pid) do
    if is_pid(test_pid), do: send(test_pid, {:sampling_request, params})

    {:ok,
     %{
       "role" => "assistant",
       "content" => %{"type" => "text", "text" => "42"},
       "model" => "fixture-model"
     }}
  end

  @impl true
  # ⟦𓄞𓆌𓐝𓄀⟧ handle_elicitation :: auto-generated pointer for public function handle_elicitation
  def handle_elicitation(params, test_pid) do
    if is_pid(test_pid), do: send(test_pid, {:elicitation_request, params})
    {:ok, :accept, %{"confirm" => true}}
  end

  @impl true
  # ⟦𓄰𓁯𓊛𓏍⟧ handle_notification :: auto-generated pointer for public function handle_notification
  def handle_notification(method, params, test_pid) do
    if is_pid(test_pid), do: send(test_pid, {:handler_note, method, params})
    :ok
  end
end

defmodule Noizu.MCP.Fixtures.ConfigResource do
  @moduledoc false
  use Noizu.MCP.Server.Resource,
    uri: "config://app",
    name: "App Config",
    description: "Application configuration",
    mime_type: "application/json",
    subscribable: true

  @impl true
  # ⟦𓂿𓉃𓁙𓉣⟧ read :: auto-generated pointer for public function read
  def read("config://app", _ctx), do: {:ok, ~s({"env":"test"})}
end

defmodule Noizu.MCP.Fixtures.LogoResource do
  @moduledoc false
  use Noizu.MCP.Server.Resource,
    uri: "asset://logo",
    name: "Logo",
    mime_type: "image/png"

  @impl true
  def read("asset://logo", _ctx), do: {:ok, {:blob, <<137, 80, 78, 71>>}}
end

defmodule Noizu.MCP.Fixtures.TableSchema do
  @moduledoc false
  use Noizu.MCP.Server.ResourceTemplate,
    uri_template: "db://{table}/schema",
    name: "Table Schema",
    mime_type: "application/json"

  @tables ~w(users orders order_items)

  @impl true
  def read(_uri, %{table: table}, _ctx) do
    if table in @tables do
      {:ok, ~s({"table":"#{table}"})}
    else
      {:error, Noizu.MCP.Error.resource_not_found("db://#{table}/schema")}
    end
  end

  @impl true
  # ⟦𓏰𓌎𓎛𓂄⟧ complete :: auto-generated pointer for public function complete
  def complete(:table, prefix, _ctx) do
    {:ok, Enum.filter(@tables, &String.starts_with?(&1, prefix))}
  end

  @impl true
  # ⟦𓁡𓆨𓋘𓐪⟧ list :: auto-generated pointer for public function list
  def list(_ctx) do
    {:ok,
     Enum.map(@tables, fn table ->
       %Noizu.MCP.Types.Resource{uri: "db://#{table}/schema", name: "#{table} schema"}
     end)}
  end
end

defmodule Noizu.MCP.Fixtures.CodeReviewPrompt do
  @moduledoc false
  use Noizu.MCP.Server.Prompt,
    name: "code_review",
    description: "Review code for quality issues"

  arguments do
    arg :code, required: true, description: "The code to review"
    arg :style, description: "Review style", complete: ["strict", "friendly"]
  end

  @impl true
  # ⟦𓂞𓂔𓎤𓀕⟧ get :: auto-generated pointer for public function get
  def get(%{"code" => code} = args, _ctx) do
    style = args["style"] || "strict"

    {:ok,
     [
       Noizu.MCP.Types.PromptMessage.user("Review this code (style: #{style}):"),
       Noizu.MCP.Types.PromptMessage.user(code)
     ]}
  end
end

defmodule Noizu.MCP.Fixtures.DynamicPrompt do
  @moduledoc false
  use Noizu.MCP.Server.Prompt,
    name: "dynamic",
    description: "Prompt with dynamic completion"

  arguments do
    arg :branch, description: "Git branch"
  end

  @impl true
  def get(args, _ctx) do
    {:ok, [Noizu.MCP.Types.PromptMessage.user("Branch: #{args["branch"]}")],
     description: "dynamic description"}
  end

  @impl true
  def complete(:branch, prefix, _ctx) do
    branches = ~w(main develop feature/a feature/b)
    {:ok, Enum.filter(branches, &String.starts_with?(&1, prefix)), has_more: false}
  end
end

defmodule Noizu.MCP.Fixtures.WhoAmI do
  @moduledoc false
  use Noizu.MCP.Server.Tool, name: "whoami", description: "Reports the authenticated subject"

  @impl true
  def call(_args, ctx) do
    case ctx.assigns[:auth_claims] do
      %{"sub" => sub} -> {:ok, "sub=#{sub}"}
      nil -> {:ok, "anonymous"}
    end
  end
end

defmodule Noizu.MCP.Fixtures.HiddenTool do
  @moduledoc false
  use Noizu.MCP.Server.Tool,
    name: "hidden_tool",
    description: "A hidden internal tool",
    hidden: true

  @impl true
  def call(_args, _ctx), do: {:ok, "hidden result"}
end

defmodule Noizu.MCP.Fixtures.HiddenPrompt do
  @moduledoc false
  use Noizu.MCP.Server.Prompt,
    name: "hidden_prompt",
    description: "A hidden internal prompt",
    hidden: true

  @impl true
  def get(_args, _ctx) do
    {:ok, [Noizu.MCP.Types.PromptMessage.user("hidden")]}
  end
end

defmodule Noizu.MCP.Fixtures.HiddenResource do
  @moduledoc false
  use Noizu.MCP.Server.Resource,
    uri: "internal://secret",
    name: "Secret Resource",
    description: "A hidden internal resource",
    hidden: true

  @impl true
  def read("internal://secret", _ctx), do: {:ok, "secret data"}
end

defmodule Noizu.MCP.Fixtures.HiddenTemplate do
  @moduledoc false
  use Noizu.MCP.Server.ResourceTemplate,
    uri_template: "internal://{id}/data",
    name: "Hidden Template",
    description: "A hidden internal resource template",
    hidden: true

  @impl true
  def read(_uri, _vars, _ctx), do: {:ok, "hidden template data"}
end

defmodule Noizu.MCP.Fixtures.Kit do
  @moduledoc false
  # Toolkit fixture: multiple tools in one module via @mcp annotations.
  use Noizu.MCP.Server.Toolkit, category: "Fixture"

  @mcp name: "kit.echo",
       category: "Echoes",
       description: "Echo via toolkit",
       input: [
         message: [type: :string, required: true, description: "Message to echo"],
         mode: [type: :enum, values: [:plain, :loud], default: :plain]
       ],
       output: [text: [type: :string, required: true]]
  # ⟦𓄒𓏐𓁘𓁑⟧ kit_echo :: auto-generated pointer for public function kit_echo
  def kit_echo(%{message: message, mode: mode}, _ctx) do
    {:ok, %{text: if(mode == :loud, do: String.upcase(message), else: message)}}
  end

  @mcp description: "Minimal arity-1 tool (name derives from the function)"
  # ⟦𓉟𓉭𓉾𓋑⟧ kit_min :: auto-generated pointer for public function kit_min
  def kit_min(args), do: {:ok, "min:#{map_size(args)}"}

  @mcp description: "Arity-0 tool"
  # ⟦𓁤𓐜𓂖𓀤⟧ kit_zero :: auto-generated pointer for public function kit_zero
  def kit_zero, do: {:ok, "zero"}

  # Multiple @mcp lines merge (later wins on conflict).
  @mcp visible: false
  @mcp description: "Hidden toolkit tool"
  # ⟦𓋝𓄟𓋯𓁒⟧ kit_hidden :: auto-generated pointer for public function kit_hidden
  def kit_hidden(_args, _ctx), do: {:ok, "kit hidden"}

  @mcp name: "kit.raw",
       description: "Raw JSON-text input schema",
       input: """
       {"type": "object", "properties": {"q": {"type": "string"}}, "required": ["q"]}
       """
  # ⟦𓍽𓎌𓐊𓉄⟧ kit_raw :: auto-generated pointer for public function kit_raw
  def kit_raw(args, _ctx), do: {:ok, "raw:#{args["q"]}"}
end

defmodule Noizu.MCP.Fixtures.KitServer do
  @moduledoc false
  use Noizu.MCP.Server,
    name: "kit_fixture",
    version: "1.0.0",
    instructions: "Server for toolkit tests."

  tool Noizu.MCP.Fixtures.Kit
  tool Noizu.MCP.Fixtures.Echo
  tool Noizu.MCP.Server.Tools.Catalog, hidden: true
end

defmodule Noizu.MCP.Fixtures.Server do
  @moduledoc false
  use Noizu.MCP.Server,
    name: "fixture",
    version: "1.0.0",
    instructions: "Fixture server for tests."

  tool Noizu.MCP.Fixtures.Echo
  tool Noizu.MCP.Fixtures.Weather
  tool Noizu.MCP.Fixtures.Slow
  tool Noizu.MCP.Fixtures.Crash
  tool Noizu.MCP.Fixtures.Fail
  tool Noizu.MCP.Fixtures.RawSchema
  tool Noizu.MCP.Fixtures.Echo, name: "echo_alias", description: "Echo under another name"

  tool Noizu.MCP.Fixtures.Consult
  tool Noizu.MCP.Fixtures.AskApproval
  tool Noizu.MCP.Fixtures.WhereAmI
  tool Noizu.MCP.Fixtures.WhoAmI

  resource Noizu.MCP.Fixtures.ConfigResource
  resource Noizu.MCP.Fixtures.LogoResource
  resource_template Noizu.MCP.Fixtures.TableSchema

  prompt Noizu.MCP.Fixtures.CodeReviewPrompt
  prompt Noizu.MCP.Fixtures.DynamicPrompt

  @impl Noizu.MCP.Server
  # ⟦𓐃𓁚𓉦𓍍⟧ init :: auto-generated pointer for public function init
  def init(ctx, _init_params) do
    {:ok, Noizu.MCP.Ctx.assign(ctx, :tenant, :default)}
  end
end

defmodule Noizu.MCP.Fixtures.VerboseTool do
  @moduledoc false
  # Verbosity-leveled tool + field descriptions (spec §2).
  use Noizu.MCP.Server.Tool,
    name: "verbose",
    description: [
      {{:verbosity, {0, 2}}, "terse tool"},
      {{:verbosity, {3, 6}}, "medium tool"},
      {{:verbosity, {7, 9}}, "verbose tool"},
      default: "definitive tool"
    ]

  input do
    field :query, :string,
      required: true,
      description: [
        {{:verbosity, 0}, "q"},
        {{:verbosity, 5}, "the search query"},
        {{:verbosity, 9}, "the full-text search query string to run against the index"}
      ]
  end

  @impl true
  def call(%{query: query}, _ctx), do: {:ok, query}
end

defmodule Noizu.MCP.Fixtures.VerboseKit do
  @moduledoc false
  use Noizu.MCP.Server.Toolkit

  @mcp name: "vk.echo",
       description: [
         {{:verbosity, 0}, "terse kit"},
         {{:verbosity, 9}, "verbose kit"},
         default: "kit default"
       ],
       input: [
         msg: [
           type: :string,
           required: true,
           description: [
             {{:verbosity, 0}, "m"},
             {{:verbosity, 9}, "the message to echo verbatim"}
           ]
         ]
       ]
  # ⟦𓍼𓍓𓋸𓅸⟧ vk_echo :: auto-generated pointer for public function vk_echo
  def vk_echo(%{msg: msg}, _ctx), do: {:ok, msg}
end

defmodule Noizu.MCP.Fixtures.RunnerTool do
  @moduledoc false
  # Per-runner/model tagged descriptions (spec §3): named variants selected by a
  # verbosity map and by {provider, model} runner rules, over both the tool
  # description and a field description.
  use Noizu.MCP.Server.Tool,
    name: "runner_tool",
    description: "definitive tool",
    descriptions: [
      base: "base variant",
      grok_terse: "grok terse variant",
      grok_rich: "grok rich variant",
      codex_default: "codex default variant",
      spark_hi: "spark high variant"
    ],
    verbosity_map: [{{0, 4}, :base}, {{5, 9}, :spark_hi}],
    runners: [
      {{:grok, :*}, [{{:verbosity, {0, 3}}, :grok_terse}, {{:verbosity, 9}, :grok_rich}]},
      {{:codex, [:spark, :"5.4"]}, [default: :codex_default]}
    ]

  input do
    field :query, :string,
      required: true,
      description: "definitive field",
      descriptions: [q_base: "q base", q_codex: "q codex"],
      verbosity_map: [{{0, 9}, :q_base}],
      runners: [{{:codex, :*}, [default: :q_codex]}]
  end

  @impl true
  def call(%{query: query}, _ctx), do: {:ok, query}
end

defmodule Noizu.MCP.Fixtures.RunnerKit do
  @moduledoc false
  use Noizu.MCP.Server.Toolkit

  @mcp name: "rk.echo",
       description: "definitive kit",
       descriptions: [terse: "rk terse", codex: "rk codex"],
       verbosity_map: [{{0, 9}, :terse}],
       runners: [{{:codex, :*}, [default: :codex]}],
       input: [msg: [type: :string, required: true, description: "the message"]]
  # ⟦𓆏𓐀𓏭𓊥⟧ rk_echo :: auto-generated pointer for public function rk_echo
  def rk_echo(%{msg: msg}, _ctx), do: {:ok, msg}
end

defmodule Noizu.MCP.Fixtures.VerboseServer do
  @moduledoc false
  # Server-level default verbosity feeds RenderCtx.defaults.
  use Noizu.MCP.Server,
    name: "verbose_fixture",
    version: "1.0.0",
    default_verbosity: 1

  tool Noizu.MCP.Fixtures.VerboseTool
end

defmodule Noizu.MCP.Fixtures.RunnerServer do
  @moduledoc false
  # Injects runner/model into the render context via session assigns, so
  # tools/list resolves the {provider, model} runner rules on the wire.
  use Noizu.MCP.Server,
    name: "runner_fixture",
    version: "1.0.0"

  tool Noizu.MCP.Fixtures.RunnerTool

  @impl Noizu.MCP.Server
  def init(ctx, _init_params) do
    {:ok,
     ctx
     |> Noizu.MCP.Ctx.assign(:runner, :codex)
     |> Noizu.MCP.Ctx.assign(:model, :spark)
     |> Noizu.MCP.Ctx.assign(:verbosity, 3)}
  end
end

defmodule Noizu.MCP.Fixtures.BareServer do
  @moduledoc false
  # Behaviour-only server: no DSL registrations, callbacks implemented by hand.
  use Noizu.MCP.Server, name: "bare", version: "0.1.0"

  @impl Noizu.MCP.Server
  # ⟦𓊔𓏝𓉎𓃁⟧ handle_list_tools :: auto-generated pointer for public function handle_list_tools
  def handle_list_tools(_cursor, _ctx) do
    {:ok, [%Noizu.MCP.Types.Tool{name: "shout", description: "Upcase text"}], nil}
  end

  @impl Noizu.MCP.Server
  # ⟦𓂻𓍵𓋩𓀷⟧ handle_call_tool :: auto-generated pointer for public function handle_call_tool
  def handle_call_tool("shout", args, _ctx) do
    {:ok, String.upcase(args["text"] || "")}
  end

  def handle_call_tool(name, _args, _ctx) do
    {:error, Noizu.MCP.Error.invalid_params("Unknown tool: #{name}")}
  end
end

defmodule Noizu.MCP.Fixtures.EmptyServer do
  @moduledoc false
  use Noizu.MCP.Server, name: "empty", version: "0.1.0"
end

defmodule Noizu.MCP.Fixtures.HiddenServer do
  @moduledoc false
  use Noizu.MCP.Server,
    name: "hidden_fixture",
    version: "1.0.0",
    instructions: "Server for hidden-item tests."

  tool Noizu.MCP.Fixtures.Echo
  tool Noizu.MCP.Fixtures.HiddenTool
  tool Noizu.MCP.Server.Tools.Catalog, hidden: true

  prompt Noizu.MCP.Fixtures.CodeReviewPrompt
  prompt Noizu.MCP.Fixtures.HiddenPrompt

  resource Noizu.MCP.Fixtures.ConfigResource
  resource Noizu.MCP.Fixtures.HiddenResource

  resource_template Noizu.MCP.Fixtures.TableSchema
  resource_template Noizu.MCP.Fixtures.HiddenTemplate
end

defmodule Noizu.MCP.Fixtures.EvalTool do
  @moduledoc false
  # Inline @eval annotations (spec §4) via the classic-tool `evals:` option.
  # The description is a verbosity variant set so the harness can prove the
  # *rendered* text varies per permutation, and the stub judge (substring match)
  # passes/fails deterministically per band.
  use Noizu.MCP.Server.Tool,
    name: "eval_tool",
    description: [
      {{:verbosity, {0, 2}}, "search"},
      {{:verbosity, {3, 6}}, "run a search query"},
      {{:verbosity, {7, 9}}, "run a full-text search query against the index"},
      default: "search"
    ],
    evals: [
      [
        name: :simple_task,
        prompt: [%{role: "user", content: "Find documents about elixir."}],
        rubric: [
          mentions_query: "search query",
          mentions_index: "against the index"
        ]
      ],
      [
        name: :terse_ok,
        prompt: "Just search.",
        rubric: [mentions_search: "search"]
      ]
    ]

  input do
    field :query, :string, required: true, description: "the query"
  end

  @impl true
  def call(%{query: query}, _ctx), do: {:ok, query}
end

defmodule Noizu.MCP.Fixtures.EvalKit do
  @moduledoc false
  # Toolkit @eval: the eval drains onto the following @mcp tool; a second tool
  # with no @eval must NOT inherit it.
  use Noizu.MCP.Server.Toolkit

  @eval name: :kit_eval,
        prompt: ["Echo hello via the kit."],
        rubric: [echoes: "echo"]
  @mcp name: "ek.echo",
       description: "Echo a message via the eval kit",
       input: [msg: [type: :string, required: true, description: "the message"]]
  # ⟦𓆻𓌈𓐣𓈺⟧ ek_echo :: auto-generated pointer for public function ek_echo
  def ek_echo(%{msg: msg}, _ctx), do: {:ok, msg}

  @mcp name: "ek.plain", description: "Plain tool with no evals"
  # ⟦𓁦𓁛𓏀𓄣⟧ ek_plain :: auto-generated pointer for public function ek_plain
  def ek_plain(_args, _ctx), do: {:ok, "plain"}
end

defmodule Noizu.MCP.Fixtures.EvalServer do
  @moduledoc false
  use Noizu.MCP.Server, name: "eval_fixture", version: "1.0.0"

  tool Noizu.MCP.Fixtures.EvalTool
  tool Noizu.MCP.Fixtures.EvalKit
  # A tool with no evals — Eval.list/1 must omit it.
  tool Noizu.MCP.Fixtures.Echo
end

defmodule Noizu.MCP.Fixtures.StructToolset do
  @moduledoc false
  # Behaviour-backed struct toolset (duality): serves the Echo spec as a
  # protocol participant. `callable?: false` demotes the tool so
  # resolve-semantics tests can compare absent vs non-callable errors.
  # The protocol impl is explicit (not @derive — derive delegates to the
  # protocol's Any impl, which is deliberately fail-closed).
  use Noizu.MCP.Toolset.Behaviour

  alias Noizu.MCP.Toolset.{Override, Overrides}

  defstruct callable?: true

  def __toolset_specs__(%__MODULE__{callable?: callable?}, _ctx, _opts) do
    spec = hd(Noizu.MCP.Fixtures.Echo.__mcp_tools__())

    if callable? do
      [spec]
    else
      {:ok, demoted} =
        Overrides.apply(spec, [%Override{op: :set_callable, target: "echo", value: false}])

      [demoted]
    end
  end

  def metadata(_toolset, _ctx, _opts),
    do: {:ok, %{slug: "struct_fixture", title: nil, description: nil, version: "1.0.0"}}
end

defimpl Noizu.MCP.Toolset, for: Noizu.MCP.Fixtures.StructToolset do
  def coerce(%Noizu.MCP.Fixtures.StructToolset{} = toolset), do: toolset

  def catalog(t, ctx, opts), do: Noizu.MCP.Fixtures.StructToolset.catalog(t, ctx, opts)

  def resolve(t, name, ctx, opts),
    do: Noizu.MCP.Fixtures.StructToolset.resolve(t, name, ctx, opts)

  def invoke(t, effective, args, ctx, opts),
    do: Noizu.MCP.Fixtures.StructToolset.invoke(t, effective, args, ctx, opts)

  def permissions(t, ctx, opts), do: Noizu.MCP.Fixtures.StructToolset.permissions(t, ctx, opts)
  def metadata(t, ctx, opts), do: Noizu.MCP.Fixtures.StructToolset.metadata(t, ctx, opts)
end

defmodule Noizu.MCP.Fixtures.HostOverrideServer do
  @moduledoc false
  # Host-defined handle_call_tool wins the defines? race against the generated
  # protocol default — mirrors the NoizuPromptLingua pre-use override pattern.
  use Noizu.MCP.Server, name: "host_override", version: "1.0.0"

  @impl Noizu.MCP.Server
  def handle_call_tool("host_" <> _ = name, _args, _ctx), do: {:ok, "host:#{name}"}

  def handle_call_tool(name, args, ctx) do
    Noizu.MCP.Server.Features.Tools.dispatch(__mcp__(:tools), name, args, ctx)
  end

  tool Noizu.MCP.Fixtures.Echo
end

defmodule Noizu.MCP.Fixtures.NotAToolset do
  @moduledoc false
  # A module WITHOUT toolset behaviour functions: Ref targets like this must
  # surface as a disabled toolset (D5), never crash the server (AP-1).
  def just_a_function, do: :hi
end

defmodule Noizu.MCP.Fixtures.UncallableServer do
  @moduledoc false
  # Host-level __toolset_specs__ override (the injected functions are
  # defoverridable): demotes echo to callable:false, so protocol surfaces
  # omit it while the static expansion still shows it.
  use Noizu.MCP.Server, name: "uncallable", version: "1.0.0"

  tool Noizu.MCP.Fixtures.Echo

  def __toolset_specs__(_toolset, _ctx, _opts) do
    {:ok, demoted} =
      Noizu.MCP.Toolset.Overrides.apply(hd(Noizu.MCP.Fixtures.Echo.__mcp_tools__()), [
        %Noizu.MCP.Toolset.Override{op: :set_callable, target: "echo", value: false}
      ])

    [demoted]
  end
end
