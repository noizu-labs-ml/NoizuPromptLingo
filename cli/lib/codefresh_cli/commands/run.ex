defmodule CodefreshCli.Commands.Run do
  @moduledoc """
  `codefresh run <script-slug> --agent <agent-slug> [--persona <persona-slug>]
                 [--threshold <0-1>] [--fail-on-warn] [--format junit]
                 [--out <path>] [--org <slug>]`

  Triggers a run via `POST /api/v1/organizations/:org/runs`, polls
  `GET /api/v1/organizations/:org/runs/:id` until terminal, then prints
  (and optionally writes) the result.

  Exit-code mapping (per US-038):
    0  PASS
    1  FAIL
    2  WARN  (unless `--fail-on-warn`, which promotes to 1)
    10 run-execution errors
  """

  alias CodefreshCli.{Args, Client, Config}

  @pass_code 0
  @fail_code 1
  @warn_code 2
  @exec_error 10

  @poll_interval_ms 2_000
  @max_poll_ms 10 * 60 * 1_000

  @spec run(list(String.t())) :: :ok | integer() | {:error, atom, String.t()}
  def run(args) do
    switches = [
      agent: :string,
      persona: :string,
      threshold: :float,
      fail_on_warn: :boolean,
      format: :string,
      out: :string,
      org: :string,
      token: :string
    ]

    with {:ok, positional, flags} <- Args.parse(args, switches),
         {:ok, script_ref} <- first(positional, "missing <script-slug>"),
         {:ok, agent} <- require_flag(flags, :agent, "--agent <agent-slug> is required"),
         {:ok, cfg} <- Config.load(),
         cfg <- maybe_override_token(cfg, flags),
         {:ok, _} <- Config.require_token(cfg),
         {:ok, org} <- Config.require_org(cfg, Keyword.take(flags, [:org])),
         body <- build_body(script_ref, agent, flags),
         {:ok, started} <-
           Client.post(cfg, "/api/v1/organizations/#{org}/runs", body) do
      run_id = extract_id(started)

      if run_id do
        IO.puts(CodefreshCli.color(:cyan, "run started: ") <> run_id)
        result = poll(cfg, org, run_id, System.monotonic_time(:millisecond))
        emit_result(result, flags)
      else
        {:error, :api, "server did not return a run id"}
      end
    else
      {:error, :api, msg} ->
        IO.puts(:stderr, CodefreshCli.color(:red, "error: ") <> msg)
        @exec_error

      other ->
        other
    end
  end

  defp first([], msg), do: {:error, :user, msg}
  defp first([h | _], _), do: {:ok, h}

  defp require_flag(flags, key, msg) do
    case Keyword.get(flags, key) do
      nil -> {:error, :user, msg}
      "" -> {:error, :user, msg}
      v -> {:ok, v}
    end
  end

  defp maybe_override_token(cfg, flags) do
    case flags[:token] do
      nil -> cfg
      "" -> cfg
      t -> Map.put(cfg, :token, t)
    end
  end

  defp build_body(script_ref, agent, flags) do
    {slug, version} =
      case String.split(script_ref, "@", parts: 2) do
        [s, v] -> {s, v}
        [s] -> {s, nil}
      end

    base = %{
      "script_slug" => slug,
      "agent_slug" => agent
    }

    base
    |> maybe_put("script_version", version)
    |> maybe_put("persona_slug", flags[:persona])
    |> maybe_put("threshold", flags[:threshold])
  end

  defp maybe_put(map, _k, nil), do: map
  defp maybe_put(map, _k, ""), do: map
  defp maybe_put(map, k, v), do: Map.put(map, k, v)

  defp extract_id(%{"data" => %{"id" => id}}) when is_binary(id), do: id
  defp extract_id(%{"id" => id}) when is_binary(id), do: id
  defp extract_id(%{"data" => %{"run_id" => id}}) when is_binary(id), do: id
  defp extract_id(_), do: nil

  defp poll(cfg, org, run_id, started_at) do
    elapsed = System.monotonic_time(:millisecond) - started_at

    cond do
      elapsed > @max_poll_ms ->
        {:error, :api, "run did not complete within #{div(@max_poll_ms, 1_000)}s"}

      true ->
        case Client.get(cfg, "/api/v1/organizations/#{org}/runs/#{run_id}") do
          {:ok, body} ->
            run = unwrap(body)
            status = status_of(run)

            if terminal?(status) do
              {:ok, run}
            else
              IO.puts(CodefreshCli.color(:dim, "  status: #{status}"))
              Process.sleep(@poll_interval_ms)
              poll(cfg, org, run_id, started_at)
            end

          {:error, kind, msg} ->
            {:error, kind, msg}
        end
    end
  end

  defp unwrap(%{"data" => %{} = d}), do: d
  defp unwrap(other), do: other

  defp status_of(%{"status" => s}) when is_binary(s), do: s
  defp status_of(%{"verdict" => v}) when is_binary(v), do: v
  defp status_of(_), do: "running"

  defp terminal?(status) do
    status in ["pass", "fail", "warn", "cancelled", "error", "complete", "completed"]
  end

  defp emit_result({:error, :api, msg}, _flags) do
    IO.puts(:stderr, CodefreshCli.color(:red, "error: ") <> msg)
    @exec_error
  end

  defp emit_result({:ok, run}, flags) do
    verdict = verdict_of(run)
    label = verdict_label(verdict)

    IO.puts(CodefreshCli.color(:cyan, "verdict: ") <> label)

    if flags[:format] == "junit" do
      write_junit(run, flags[:out])
    else
      maybe_write_json(run, flags[:out])
    end

    verdict_to_exit(verdict, Keyword.get(flags, :fail_on_warn, false))
  end

  defp verdict_of(%{"verdict" => v}) when is_binary(v), do: String.downcase(v)
  defp verdict_of(%{"status" => s}) when is_binary(s), do: String.downcase(s)
  defp verdict_of(_), do: "unknown"

  defp verdict_label("pass"), do: CodefreshCli.color(:green, "PASS")
  defp verdict_label("fail"), do: CodefreshCli.color(:red, "FAIL")
  defp verdict_label("warn"), do: CodefreshCli.color(:yellow, "WARN")
  defp verdict_label(other), do: String.upcase(to_string(other))

  defp verdict_to_exit("pass", _), do: @pass_code
  defp verdict_to_exit("fail", _), do: @fail_code
  defp verdict_to_exit("warn", true), do: @fail_code
  defp verdict_to_exit("warn", _), do: @warn_code
  defp verdict_to_exit(_, _), do: @exec_error

  defp maybe_write_json(_run, nil), do: :ok

  defp maybe_write_json(run, path) do
    body = Jason.encode!(run, pretty: true)

    case File.write(path, body) do
      :ok -> IO.puts(CodefreshCli.color(:dim, "wrote #{path}"))
      {:error, reason} -> IO.puts(:stderr, "failed to write #{path}: #{inspect(reason)}")
    end
  end

  defp write_junit(run, out_path) do
    xml = CodefreshCli.JUnit.render(run)

    case out_path do
      nil ->
        IO.write(xml)

      path ->
        case File.write(path, xml) do
          :ok -> IO.puts(CodefreshCli.color(:dim, "wrote #{path}"))
          {:error, reason} -> IO.puts(:stderr, "failed to write #{path}: #{inspect(reason)}")
        end
    end
  end
end
