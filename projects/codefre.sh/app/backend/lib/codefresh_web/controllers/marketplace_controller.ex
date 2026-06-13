defmodule CodefreshWeb.MarketplaceController do
  @moduledoc """
  Cross-org marketplace browse + import (US-119). Browse is not org-gated;
  import requires editor in the target org.
  """

  use CodefreshWeb, :controller

  alias Codefresh.{Organizations}
  alias Codefresh.Rubrics.Marketplace
  alias Codefresh.Guardian

  def rubrics_index(conn, params) do
    _user = Guardian.Plug.current_resource(conn)

    opts =
      []
      |> maybe_put(:domain, params["domain"])
      |> maybe_put(:status, params["status"])

    entries = Marketplace.list_entries(opts)
    json(conn, %{entries: Enum.map(entries, &render_entry/1)})
  end

  def import_rubric(conn, %{"organization_id" => org_id, "id" => entry_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor") do
      case Marketplace.import(org_id, entry_id, imported_by_user_id: user.id) do
        {:ok, %{rubric: r, version: v}} ->
          conn
          |> put_status(:created)
          |> json(%{
            rubric: %{id: r.id, slug: r.slug, name: r.name, description: r.description},
            version: %{id: v.id, version_number: v.version_number}
          })

        {:error, :entry_not_found} ->
          send_resp(conn, 404, "")

        {:error, :judge_prompt_requires_local_copy} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{
            error:
              "Source rubric's judge prompt lives in another org. Copy the judge prompt into your org first, then re-import."
          })

        {:error, reason} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  defp render_entry(%{entry: e, rubric_version: rv}) do
    %{
      id: e.id,
      title: e.title,
      description: e.description,
      domain: e.domain,
      curation_status: e.curation_status,
      download_count: e.download_count,
      average_rating: e.average_rating,
      published_at: e.published_at,
      rubric_version: %{
        id: rv.id,
        judge_model: rv.judge_model,
        scale: rv.scale,
        criteria: rv.criteria,
        n_samples: rv.n_samples
      }
    }
  end

  defp maybe_put(opts, _k, nil), do: opts
  defp maybe_put(opts, _k, ""), do: opts
  defp maybe_put(opts, k, v), do: Keyword.put(opts, k, v)
end
