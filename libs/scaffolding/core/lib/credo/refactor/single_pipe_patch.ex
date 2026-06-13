defmodule Credo.Check.Readability.SinglePipePatch do
  use Credo.Check,
    id: "EX3023",
    base_priority: :high,
    tags: [:controversial],
    param_defaults: [allow_0_arity_functions: false, excluded_functions: []],
    explanations: [
      check: """
      Pipes (`|>`) should only be used when piping data through multiple calls.

      So while this is fine:

          list
          |> Enum.take(5)
          |> Enum.shuffle
          |> evaluate()

      The code in this example ...

          list
          |> evaluate()

      ... should be refactored to look like this:

          evaluate(list)

      Using a single |> to invoke functions makes the code harder to read. Instead,
      write a function call when a pipeline is only one function long.

      Like all `Readability` issues, this one is not a technical concern.
      But you can improve the odds of others reading and liking your code by making
      it easier to follow.
      """,
      params: [
        allow_0_arity_functions: "Allow 0-arity functions",
        excluded_functions: "Allow single pipes starting with Module.function in list."
      ]
    ]

  @doc false
  @impl true
  def run(%SourceFile{} = source_file, params) do
    issue_meta = IssueMeta.for(source_file, params)
    allow_0_arity_functions = Params.get(params, :allow_0_arity_functions, __MODULE__)
    excluded_functions = Params.get(params, :excluded_functions, __MODULE__)

    {_continue, issues} =
      Credo.Code.prewalk(
        source_file,
        &traverse(&1, &2, issue_meta, allow_0_arity_functions, excluded_functions),
        {true, []}
      )

    issues
  end

  defp traverse({:|>, _, [{:|>, _, _} | _]} = ast, {_, issues}, _, _, _) do
    # multiple pipes - valid
    {ast, {false, issues}}
  end

  defp traverse({:|>, _, [{{:., _, _}, _, []}, _]} = ast, {true, issues}, _, true, _) do
    # single arity function allowed - valid
    {ast, {false, issues}}
  end

  defp traverse({:|>, _, [{fun, _, []}, _]} = ast, {true, issues}, _, true, _)
       when is_atom(fun) do
    # single arity function allowed - valid
    {ast, {false, issues}}
  end

  defp traverse({:|>, meta, [h | _]} = ast, {true, issues}, issue_meta, _, excluded_functions) do
    valid? =
      case h do
        {fun, _, _} when is_atom(fun) and not is_nil(fun) ->
          String.ends_with?(to_function_call_name(h), excluded_functions)

        {{:., _, [_, fun]}, _, _} when is_atom(fun) and not is_nil(fun) ->
          String.ends_with?(to_function_call_name(h), excluded_functions)

        _ ->
          false
      end

    if valid? do
      # in exclusion list, valid
      {ast, {false, issues}}
    else
      {
        ast,
        {false, issues ++ [issue_for(issue_meta, meta[:line], "|>")]}
      }
    end
  end

  defp traverse(ast, {_, issues}, _issue_meta, _allow_zero_arity, _allow_functions) do
    {ast, {true, issues}}
  end

  defp to_function_call_name({_, _, _} = ast) do
    {ast, [], []}
    |> Macro.to_string()
    |> String.replace(~r/\.?\(.*\)$/s, "")
  end

  defp issue_for(issue_meta, line_no, trigger) do
    format_issue(
      issue_meta,
      message: "Use a function call when a pipeline is only one function long.",
      trigger: trigger,
      line_no: line_no
    )
  end
end
