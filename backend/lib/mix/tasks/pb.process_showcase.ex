defmodule Mix.Tasks.Pb.ProcessShowcase do
  @moduledoc """
  Process pending logged prompts through the OP-vs-NPL showcase pipeline
  (system budget, never user quota).

      mix pb.process_showcase --limit 5
  """
  use Mix.Task

  @shortdoc "Run the NPL showcase batch over pending prompt logs"

  @impl Mix.Task
  def run(args) do
    {opts, _} = OptionParser.parse!(args, strict: [limit: :integer])
    limit = Keyword.get(opts, :limit, 5)

    Mix.Task.run("app.start")

    case NoizuPromptLingua.PromptBuilder.Showcase.process_batch(limit) do
      {:ok, %{processed: p, failed: f, skipped: s}} ->
        Mix.shell().info("showcase batch: processed=#{p} failed=#{f} skipped=#{s} pending=#{NoizuPromptLingua.PromptBuilder.Showcase.pending_count()}")

      {:error, reason} ->
        Mix.shell().error("showcase batch failed: #{inspect(reason)}")
    end
  end
end
