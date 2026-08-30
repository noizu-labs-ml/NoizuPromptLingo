defmodule NoizuPromptLingua.Domains.Instructions.Tools.InstructionRender do
  use Noizu.MCP.Server.Tool,
    name: "Instruction.Render",
    description:
      "Render an instruction's body with task params — the prompt to hand a sub-agent. Reference by slug handle so the full text never has to be re-sent.",
    hidden: false,
    category: "Instructions",
    annotations: [read_only_hint: true]

  input_schema(%{
    "type" => "object",
    "properties" => %{
      "instruction" => %{"type" => "string", "description" => "Slug handle or UUID (required)"},
      "organization" => %{
        "type" => "string",
        "description" => "Org slug/UUID (to resolve a slug)"
      },
      "params" => %{
        "type" => "object",
        "description" => "Param name → value, substituted into {{name}} placeholders"
      },
      "version" => %{
        "type" => "integer",
        "description" => "Specific version (defaults to active)"
      }
    },
    "required" => ["instruction"]
  })

  alias NoizuPromptLingua.Domains.Instructions
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    key = Args.get(args, :instruction)
    org_id = Resolve.organization_id(Args.get(args, :organization))
    instruction = (org_id && Instructions.resolve(org_id, key)) || Instructions.get(key)

    params = args["params"] || %{}
    opts = if v = args["version"], do: [version: v], else: []

    case Instructions.render(instruction, params, opts) do
      {:ok, rendered} ->
        {:ok, rendered}

      {:error, :not_found} ->
        {:error, "Instruction '#{key}' not found"}

      {:error, :version_not_found} ->
        {:error, "Version not found"}

      {:error, {:missing_params, missing}} ->
        {:error, "Missing required params: #{Enum.join(missing, ", ")}"}
    end
  end
end
