defmodule NoizuPromptLingua.Domains.Memory.Guardian do
  @moduledoc """
  Gates ingest with cheap inline checks: content present, length bound, and a
  prompt-injection/poisoning heuristic. Returns `:ok` or `{:quarantine, reason}`.
  """

  @injection_patterns [
    ~r/ignore\s+(all\s+)?(previous|prior|above)\s+instructions/i,
    ~r/disregard\s+(the\s+)?(system|previous)\s+prompt/i,
    ~r/you\s+are\s+now\s+(a\s+)?(dan|developer mode|unrestricted)/i,
    ~r/<\s*\/?\s*(system|assistant)\s*>/i
  ]

  @max_len 50_000

  def gate(attrs) do
    content = attrs[:content] || attrs["content"] || ""

    cond do
      not is_binary(content) or String.trim(content) == "" ->
        {:quarantine, "empty content"}

      String.length(content) > @max_len ->
        {:quarantine, "content exceeds #{@max_len} chars"}

      injection?(content) ->
        {:quarantine, "possible prompt-injection pattern in content"}

      true ->
        :ok
    end
  end

  defp injection?(text), do: Enum.any?(@injection_patterns, &Regex.match?(&1, text))
end
