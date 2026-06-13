defmodule Noizu.MCP.Server.Tool.Spec do
  @moduledoc """
  Normalized runtime descriptor for one registered tool.

  Every tool module — classic `use Noizu.MCP.Server.Tool` modules and
  `use Noizu.MCP.Server.Toolkit` multi-tool modules alike — exports
  `__mcp_tools__/0` returning a list of these. The server runtime
  (`Noizu.MCP.Server.Features.Tools.expand/1`) works exclusively on specs:
  the `definition` is what `tools/list` advertises, `module`/`fun`/`arity`
  are how `tools/call` invokes the handler, and `cast_plan`/`output_schema`
  drive argument casting and structured-output checking.
  """

  defstruct [:module, :fun, :arity, :definition, :cast_plan, :output_schema, hidden: false]

  @type t :: %__MODULE__{
          module: module(),
          fun: atom(),
          arity: 0..2,
          definition: Noizu.MCP.Types.Tool.t(),
          cast_plan: list() | nil,
          output_schema: map() | nil,
          hidden: boolean()
        }
end
