defmodule NoizuPromptLinguaWeb.McpOverviewController do
  @moduledoc """
  Admin review flow for `mcp_overview` (design spec §5): list generated overviews,
  approve / reject, or edit the Markdown (an edit implies approval). Minimal REST;
  a review UI is a follow-up.
  """
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Domains.MCPOverview.Store

  def index(conn, params) do
    overviews =
      Store.list_overviews(
        status: params["status"],
        scope_slug: params["scope_slug"],
        limit: parse_limit(params["limit"])
      )
      |> Enum.map(&overview_json/1)

    conn |> put_status(:ok) |> json(%{overviews: overviews})
  end

  def approve(conn, %{"id" => id}), do: respond(conn, Store.set_status(id, "approved"))

  def reject(conn, %{"id" => id}), do: respond(conn, Store.set_status(id, "rejected"))

  # Edit the overview body; per the review-flow spec an edit approves the result.
  def update(conn, %{"id" => id, "overview" => %{"overview_md" => md}}) when is_binary(md) do
    respond(conn, Store.edit_overview(id, md))
  end

  def update(conn, _params) do
    conn |> put_status(:bad_request) |> json(%{error: "overview.overview_md (string) required"})
  end

  defp respond(conn, {:ok, row}) do
    conn |> put_status(:ok) |> json(%{overview: overview_json(row)})
  end

  defp respond(conn, {:error, :not_found}) do
    conn |> put_status(:not_found) |> json(%{error: "Overview not found"})
  end

  defp respond(conn, {:error, %Ecto.Changeset{} = cs}) do
    conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
  end

  defp overview_json(o) do
    %{
      id: o.id,
      scope_slug: o.scope_slug,
      task_text: o.task_text,
      overview_md: o.overview_md,
      runner: o.runner,
      model: o.model,
      verbosity: o.verbosity,
      status: o.status,
      inserted_at: o.inserted_at,
      updated_at: o.updated_at
    }
  end

  defp parse_limit(nil), do: 100
  defp parse_limit(v) when is_integer(v), do: v

  defp parse_limit(v) when is_binary(v) do
    case Integer.parse(v) do
      {n, _} -> n
      :error -> 100
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
