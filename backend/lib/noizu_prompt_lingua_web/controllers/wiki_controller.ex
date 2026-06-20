defmodule NoizuPromptLinguaWeb.WikiController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.Authz

  # ── Spaces ────────────────────────────────────────────────────────────────

  # GET /api/v1/organizations/:org_id/wiki/spaces
  def index_spaces(conn, %{"org_id" => org_id} = params) do
    with_org(conn, org_id, "viewer", fn resolved_org_id ->
      opts =
        [organization_id: resolved_org_id]
        |> maybe_opt(:project_id, params["project_id"])
        |> maybe_opt(:search, params["search"])

      json(conn, %{spaces: Enum.map(Wiki.list_spaces(opts), &space_json/1)})
    end)
  end

  # POST /api/v1/organizations/:org_id/wiki/spaces
  def create_space(conn, %{"org_id" => org_id, "space" => attrs}) do
    with_org(conn, org_id, "member", fn resolved_org_id ->
      with {:ok, project_id} <- validate_project(attrs["project_id"], resolved_org_id) do
        params = %{
          organization_id: resolved_org_id,
          project_id: project_id,
          slug: attrs["slug"],
          name: attrs["name"],
          description: attrs["description"]
        }

        case Wiki.create_space(params) do
          {:ok, space} -> conn |> put_status(:created) |> json(%{space: space_json(space)})
          {:error, changeset} -> unprocessable(conn, changeset)
        end
      else
        {:error, :project_not_in_org} -> project_error(conn)
      end
    end)
  end

  # GET /api/v1/organizations/:org_id/wiki/spaces/:id
  def show_space(conn, %{"org_id" => org_id, "id" => id}) do
    with_org_space(conn, org_id, id, "viewer", fn space ->
      json(conn, %{space: space_json(space), pages: Enum.map(Wiki.list_pages(space.id), &page_summary_json/1)})
    end)
  end

  # PUT /api/v1/organizations/:org_id/wiki/spaces/:id
  def update_space(conn, %{"org_id" => org_id, "id" => id} = params) do
    attrs = params["space"] || %{}

    with_org_space(conn, org_id, id, "member", fn space ->
      with {:ok, project_id} <- validate_project(Map.get(attrs, "project_id"), space.organization_id) do
        patch =
          attrs
          |> Map.take(["slug", "name", "description"])
          |> maybe_put("project_id", Map.has_key?(attrs, "project_id"), project_id)

        case Wiki.update_space(id, patch) do
          {:ok, updated} -> json(conn, %{space: space_json(updated)})
          {:error, :not_found} -> not_found(conn, "Space not found")
          {:error, changeset} -> unprocessable(conn, changeset)
        end
      else
        {:error, :project_not_in_org} -> project_error(conn)
      end
    end)
  end

  # DELETE /api/v1/organizations/:org_id/wiki/spaces/:id
  def delete_space(conn, %{"org_id" => org_id, "id" => id}) do
    with_org_space(conn, org_id, id, "member", fn _space ->
      case Wiki.delete_space(id) do
        {:ok, _} -> json(conn, %{message: "Space deleted"})
        {:error, :not_found} -> not_found(conn, "Space not found")
      end
    end)
  end

  # ── Pages ─────────────────────────────────────────────────────────────────

  # GET /api/v1/organizations/:org_id/wiki/spaces/:space_id/pages
  def index_pages(conn, %{"org_id" => org_id, "space_id" => space_id} = params) do
    with_org_space(conn, org_id, space_id, "viewer", fn space ->
      opts = maybe_opt([], :search, params["search"])
      json(conn, %{pages: Enum.map(Wiki.list_pages(space.id, opts), &page_summary_json/1)})
    end)
  end

  # POST /api/v1/organizations/:org_id/wiki/spaces/:space_id/pages
  def create_page(conn, %{"org_id" => org_id, "space_id" => space_id, "page" => attrs}) do
    with_org_space(conn, org_id, space_id, "member", fn space ->
      params = %{
        space_id: space.id,
        parent_id: blank_to_nil(attrs["parent_id"]),
        slug: attrs["slug"],
        title: attrs["title"],
        content: attrs["content"],
        position: attrs["position"]
      }

      case Wiki.create_page(params) do
        {:ok, page} -> conn |> put_status(:created) |> json(%{page: page_json(page)})
        {:error, changeset} -> unprocessable(conn, changeset)
      end
    end)
  end

  # GET /api/v1/organizations/:org_id/wiki/pages/:id
  def show_page(conn, %{"org_id" => org_id, "id" => id}) do
    with_org_page(conn, org_id, id, "viewer", fn page ->
      body =
        page_json(page)
        |> Map.put(:comments, Enum.map(Wiki.list_comments(page.id), &comment_json/1))
        |> Map.put(:attachments, Enum.map(Wiki.list_attachments(page.id), &attachment_json/1))
        |> Map.put(:reactions, Enum.map(Wiki.list_reactions("page", page.id), &reaction_json/1))

      json(conn, %{page: body})
    end)
  end

  # PUT /api/v1/organizations/:org_id/wiki/pages/:id
  def update_page(conn, %{"org_id" => org_id, "id" => id} = params) do
    attrs = params["page"] || %{}

    with_org_page(conn, org_id, id, "member", fn _page ->
      patch =
        attrs
        |> Map.take(["slug", "title", "content", "position"])
        |> maybe_put("parent_id", Map.has_key?(attrs, "parent_id"), blank_to_nil(attrs["parent_id"]))

      case Wiki.update_page(id, patch) do
        {:ok, updated} -> json(conn, %{page: page_json(updated)})
        {:error, :not_found} -> not_found(conn, "Page not found")
        {:error, changeset} -> unprocessable(conn, changeset)
      end
    end)
  end

  # DELETE /api/v1/organizations/:org_id/wiki/pages/:id
  def delete_page(conn, %{"org_id" => org_id, "id" => id}) do
    with_org_page(conn, org_id, id, "member", fn _page ->
      case Wiki.delete_page(id) do
        {:ok, _} -> json(conn, %{message: "Page deleted"})
        {:error, :not_found} -> not_found(conn, "Page not found")
      end
    end)
  end

  # ── Comments ──────────────────────────────────────────────────────────────

  # GET /api/v1/organizations/:org_id/wiki/pages/:page_id/comments
  def index_comments(conn, %{"org_id" => org_id, "page_id" => page_id}) do
    with_org_page(conn, org_id, page_id, "viewer", fn page ->
      json(conn, %{comments: Enum.map(Wiki.list_comments(page.id), &comment_json/1)})
    end)
  end

  # POST /api/v1/organizations/:org_id/wiki/pages/:page_id/comments
  def create_comment(conn, %{"org_id" => org_id, "page_id" => page_id, "comment" => attrs}) do
    with_org_page(conn, org_id, page_id, "member", fn page ->
      params = %{
        page_id: page.id,
        parent_id: blank_to_nil(attrs["parent_id"]),
        author: attrs["author"] || actor(conn),
        body: attrs["body"]
      }

      case Wiki.create_comment(params) do
        {:ok, comment} -> conn |> put_status(:created) |> json(%{comment: comment_json(comment)})
        {:error, changeset} -> unprocessable(conn, changeset)
      end
    end)
  end

  # DELETE /api/v1/organizations/:org_id/wiki/comments/:id
  def delete_comment(conn, %{"org_id" => org_id, "id" => id}) do
    with {:comment, comment} when not is_nil(comment) <- {:comment, Wiki.get_comment(id)},
         {:page, page} when not is_nil(page) <- {:page, Wiki.get_page(comment.page_id)} do
      with_org_space(conn, org_id, page.space_id, "member", fn _space ->
        case Wiki.delete_comment(id) do
          {:ok, _} -> json(conn, %{message: "Comment deleted"})
          {:error, :not_found} -> not_found(conn, "Comment not found")
        end
      end)
    else
      _ -> not_found(conn, "Comment not found")
    end
  end

  # ── Attachments ───────────────────────────────────────────────────────────

  # GET /api/v1/organizations/:org_id/wiki/pages/:page_id/attachments
  def index_attachments(conn, %{"org_id" => org_id, "page_id" => page_id}) do
    with_org_page(conn, org_id, page_id, "viewer", fn page ->
      json(conn, %{attachments: Enum.map(Wiki.list_attachments(page.id), &attachment_json/1)})
    end)
  end

  # POST /api/v1/organizations/:org_id/wiki/pages/:page_id/attachments
  def create_attachment(conn, %{"org_id" => org_id, "page_id" => page_id, "attachment" => attrs}) do
    with_org_page(conn, org_id, page_id, "member", fn page ->
      params = %{
        page_id: page.id,
        filename: attrs["filename"],
        mime_type: attrs["mime_type"],
        url: attrs["url"],
        byte_size: attrs["byte_size"]
      }

      case Wiki.create_attachment(params) do
        {:ok, attachment} -> conn |> put_status(:created) |> json(%{attachment: attachment_json(attachment)})
        {:error, changeset} -> unprocessable(conn, changeset)
      end
    end)
  end

  # DELETE /api/v1/organizations/:org_id/wiki/attachments/:id
  def delete_attachment(conn, %{"org_id" => org_id, "id" => id}) do
    with {:att, att} when not is_nil(att) <- {:att, Wiki.get_attachment(id)},
         {:page, page} when not is_nil(page) <- {:page, Wiki.get_page(att.page_id)} do
      with_org_space(conn, org_id, page.space_id, "member", fn _space ->
        case Wiki.delete_attachment(id) do
          {:ok, _} -> json(conn, %{message: "Attachment deleted"})
          {:error, :not_found} -> not_found(conn, "Attachment not found")
        end
      end)
    else
      _ -> not_found(conn, "Attachment not found")
    end
  end

  # ── Reactions (pages + comments) ──────────────────────────────────────────

  # GET .../wiki/pages/:page_id/reactions
  def index_page_reactions(conn, %{"org_id" => org_id, "page_id" => page_id}) do
    with_org_page(conn, org_id, page_id, "viewer", fn page ->
      json(conn, %{reactions: Enum.map(Wiki.list_reactions("page", page.id), &reaction_json/1)})
    end)
  end

  # POST .../wiki/pages/:page_id/reactions  body: {emoji}
  def add_page_reaction(conn, %{"org_id" => org_id, "page_id" => page_id, "emoji" => emoji}) do
    with_org_page(conn, org_id, page_id, "member", fn page ->
      do_add_reaction(conn, "page", page.id, emoji)
    end)
  end

  # DELETE .../wiki/pages/:page_id/reactions  body/query: {emoji}
  def remove_page_reaction(conn, %{"org_id" => org_id, "page_id" => page_id, "emoji" => emoji}) do
    with_org_page(conn, org_id, page_id, "member", fn page ->
      do_remove_reaction(conn, "page", page.id, emoji)
    end)
  end

  # GET .../wiki/comments/:comment_id/reactions
  def index_comment_reactions(conn, %{"org_id" => org_id, "comment_id" => comment_id}) do
    with_org_comment(conn, org_id, comment_id, "viewer", fn comment ->
      json(conn, %{reactions: Enum.map(Wiki.list_reactions("comment", comment.id), &reaction_json/1)})
    end)
  end

  # POST .../wiki/comments/:comment_id/reactions  body: {emoji}
  def add_comment_reaction(conn, %{"org_id" => org_id, "comment_id" => comment_id, "emoji" => emoji}) do
    with_org_comment(conn, org_id, comment_id, "member", fn comment ->
      do_add_reaction(conn, "comment", comment.id, emoji)
    end)
  end

  # DELETE .../wiki/comments/:comment_id/reactions  body/query: {emoji}
  def remove_comment_reaction(conn, %{"org_id" => org_id, "comment_id" => comment_id, "emoji" => emoji}) do
    with_org_comment(conn, org_id, comment_id, "member", fn comment ->
      do_remove_reaction(conn, "comment", comment.id, emoji)
    end)
  end

  defp do_add_reaction(conn, target_type, target_id, emoji) do
    case Wiki.add_reaction(%{target_type: target_type, target_id: target_id, emoji: emoji, actor: actor(conn)}) do
      {:ok, reaction} -> conn |> put_status(:created) |> json(%{reaction: reaction_json(reaction)})
      {:error, changeset} -> unprocessable(conn, changeset)
    end
  end

  defp do_remove_reaction(conn, target_type, target_id, emoji) do
    case Wiki.remove_reaction(target_type, target_id, emoji, actor(conn)) do
      :ok -> json(conn, %{message: "Reaction removed"})
      {:error, :not_found} -> not_found(conn, "Reaction not found")
    end
  end

  # ── Shared resolution / authz helpers ─────────────────────────────────────

  # Resolve the org + authorize, handing the resolved org id to `fun`.
  defp with_org(conn, org_id, role, fun) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, role) do
      fun.(resolved_org_id)
    else
      err -> handle_error(conn, err)
    end
  end

  # Load a space and ensure it belongs to the resolved org before handing it off.
  defp with_org_space(conn, org_id, space_id, role, fun) do
    with_org(conn, org_id, role, fn resolved_org_id ->
      case Wiki.get_space(space_id) do
        %{organization_id: ^resolved_org_id} = space -> fun.(space)
        _ -> not_found(conn, "Space not found")
      end
    end)
  end

  # Load a page, resolve its space, and ensure the space belongs to the org.
  defp with_org_page(conn, org_id, page_id, role, fun) do
    with_org(conn, org_id, role, fn resolved_org_id ->
      with page when not is_nil(page) <- Wiki.get_page(page_id),
           %{organization_id: ^resolved_org_id} <- Wiki.get_space(page.space_id) do
        fun.(page)
      else
        _ -> not_found(conn, "Page not found")
      end
    end)
  end

  # Load a comment, resolve its page → space, and ensure it belongs to the org.
  defp with_org_comment(conn, org_id, comment_id, role, fun) do
    with_org(conn, org_id, role, fn resolved_org_id ->
      with comment when not is_nil(comment) <- Wiki.get_comment(comment_id),
           page when not is_nil(page) <- Wiki.get_page(comment.page_id),
           %{organization_id: ^resolved_org_id} <- Wiki.get_space(page.space_id) do
        fun.(comment)
      else
        _ -> not_found(conn, "Comment not found")
      end
    end)
  end

  defp validate_project(nil, _org_id), do: {:ok, nil}
  defp validate_project("", _org_id), do: {:ok, nil}
  defp validate_project(project_id, org_id) do
    case NoizuPromptLingua.Projects.get_project(project_id) do
      nil -> {:error, :project_not_in_org}
      %{organization_id: ^org_id} -> {:ok, project_id}
      _ -> {:error, :project_not_in_org}
    end
  end

  # ── JSON serializers ──────────────────────────────────────────────────────

  defp space_json(s) do
    %{
      id: s.id,
      organization_id: s.organization_id,
      project_id: s.project_id,
      slug: s.slug,
      name: s.name,
      description: s.description,
      inserted_at: s.inserted_at,
      updated_at: s.updated_at
    }
  end

  defp page_summary_json(p) do
    %{id: p.id, space_id: p.space_id, parent_id: p.parent_id, slug: p.slug, title: p.title, position: p.position, updated_at: p.updated_at}
  end

  defp page_json(p) do
    %{
      id: p.id,
      space_id: p.space_id,
      parent_id: p.parent_id,
      slug: p.slug,
      title: p.title,
      content: p.content,
      position: p.position,
      inserted_at: p.inserted_at,
      updated_at: p.updated_at
    }
  end

  defp comment_json(c) do
    %{id: c.id, page_id: c.page_id, parent_id: c.parent_id, author: c.author, body: c.body, inserted_at: c.inserted_at}
  end

  defp attachment_json(a) do
    %{id: a.id, page_id: a.page_id, filename: a.filename, mime_type: a.mime_type, url: a.url, byte_size: a.byte_size, inserted_at: a.inserted_at}
  end

  defp reaction_json(r) do
    %{id: r.id, target_type: r.target_type, target_id: r.target_id, emoji: r.emoji, actor: r.actor, inserted_at: r.inserted_at}
  end

  # ── Misc ──────────────────────────────────────────────────────────────────

  defp not_found(conn, msg), do: conn |> put_status(:not_found) |> json(%{error: msg})
  defp project_error(conn), do: conn |> put_status(:unprocessable_entity) |> json(%{error: "Project does not belong to this organization"})

  defp unprocessable(conn, changeset),
    do: conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})

  defp handle_error(conn, err) do
    case err do
      {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Organization not found"})
      {:error, :not_a_member} -> conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})
      _ -> conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  defp maybe_opt(opts, _key, nil), do: opts
  defp maybe_opt(opts, _key, ""), do: opts
  defp maybe_opt(opts, key, val), do: Keyword.put(opts, key, val)

  defp maybe_put(map, _key, false, _val), do: map
  defp maybe_put(map, key, true, val), do: Map.put(map, key, val)

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(v), do: v

  defp actor(conn), do: get_user_id(conn) || "anonymous"

  defp get_user_id(conn) do
    case NoizuPromptLingua.Guardian.Plug.current_resource(conn) do
      %NoizuPromptLingua.Users.Sessions.UserSession{user: {:ref, _, id}} -> id
      %NoizuPromptLingua.Users.Sessions.UserSession{user: %{id: id}} -> id
      _ -> nil
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
