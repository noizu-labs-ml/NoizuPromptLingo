defmodule DocPointers.MCP.Writes do
  @moduledoc false

  @message "Write tools are disabled. Restart with --write (or DOC_POINTERS_MCP_WRITES=1), or pass confirm=true."

  def enabled? do
    Application.get_env(:doc_pointers, :mcp_writes, false) == true
  end

  def authorize(args, ctx) when is_map(args) do
    cond do
      enabled?() -> :ok
      truthy?(Map.get(args, :confirm)) -> :ok
      match?(%Noizu.MCP.Ctx{}, ctx) -> elicit(ctx)
      true -> {:error, @message}
    end
  end

  defp elicit(ctx) do
    schema = %{
      "type" => "object",
      "properties" => %{"confirm" => %{"type" => "boolean"}},
      "required" => ["confirm"]
    }

    case Noizu.MCP.Ctx.elicit(ctx, "Allow this doc-pointer write (generate/update)?", schema) do
      {:ok, {:accept, content}} when is_map(content) ->
        if truthy?(content["confirm"] || content[:confirm]) do
          :ok
        else
          {:error, @message}
        end

      _ ->
        {:error, @message}
    end
  end

  defp truthy?(true), do: true
  defp truthy?("true"), do: true
  defp truthy?("1"), do: true
  defp truthy?(_), do: false
end
