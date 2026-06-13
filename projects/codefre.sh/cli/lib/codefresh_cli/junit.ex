defmodule CodefreshCli.JUnit do
  @moduledoc """
  Minimal JUnit XML renderer (US-083).

  Input shape is flexible — the renderer tolerates missing keys and
  produces a valid JUnit v4-style document even when the server payload
  evolves. A `run` may contain `steps` (each with `expectations`) or a
  flat `expectations` list.
  """

  @doc "Render a run map as a JUnit XML string."
  @spec render(map()) :: String.t()
  def render(run) when is_map(run) do
    cases = collect_cases(run)

    failures = Enum.count(cases, &match?(%{status: "fail"}, &1))
    skipped = Enum.count(cases, &match?(%{status: "warn"}, &1))
    total = length(cases)

    elapsed = Map.get(run, "elapsed_seconds") || Map.get(run, "duration") || 0

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <testsuites name="codefresh">
      <testsuite name=#{attr(run_name(run))} tests="#{total}" failures="#{failures}" skipped="#{skipped}" time="#{elapsed}">
    #{Enum.map_join(cases, "\n", &render_case/1)}
      </testsuite>
    </testsuites>
    """
  end

  defp collect_cases(run) do
    cond do
      is_list(run["expectations"]) ->
        Enum.map(run["expectations"], &normalise_case(&1, nil))

      is_list(run["steps"]) ->
        Enum.flat_map(run["steps"], fn step ->
          node = step["node"] || step["node_id"] || step["id"]

          (step["expectations"] || [])
          |> Enum.map(&normalise_case(&1, node))
        end)

      true ->
        []
    end
  end

  defp normalise_case(exp, classname) when is_map(exp) do
    %{
      classname: to_string(classname || "script"),
      name: to_string(exp["label"] || exp["name"] || exp["id"] || "expectation"),
      status: String.downcase(to_string(exp["status"] || exp["verdict"] || "pass")),
      time: exp["elapsed_seconds"] || 0,
      message: exp["rationale"] || exp["message"] || ""
    }
  end

  defp render_case(%{status: "pass"} = c) do
    ~s(    <testcase classname=#{attr(c.classname)} name=#{attr(c.name)} time="#{c.time}"/>)
  end

  defp render_case(%{status: "fail"} = c) do
    ~s(    <testcase classname=#{attr(c.classname)} name=#{attr(c.name)} time="#{c.time}">\n) <>
      ~s(      <failure message=#{attr(c.message)}>#{escape(c.message)}</failure>\n) <>
      ~s(    </testcase>)
  end

  defp render_case(%{status: "warn"} = c) do
    ~s(    <testcase classname=#{attr(c.classname)} name=#{attr(c.name)} time="#{c.time}">\n) <>
      ~s(      <skipped message=#{attr(c.message)}/>\n) <>
      ~s(    </testcase>)
  end

  defp render_case(c) do
    ~s(    <testcase classname=#{attr(c.classname)} name=#{attr(c.name)} time="#{c.time}"/>)
  end

  defp run_name(run) do
    to_string(run["script_slug"] || run["name"] || run["id"] || "run")
  end

  defp attr(v) do
    ~s("#{escape(to_string(v))}")
  end

  defp escape(str) do
    str
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace(~s("), "&quot;")
    |> String.replace("'", "&apos;")
  end
end
