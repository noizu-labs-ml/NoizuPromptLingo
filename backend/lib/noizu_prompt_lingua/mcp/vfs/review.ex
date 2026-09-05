defmodule NoizuPromptLingua.MCP.VFS.Review do
  @moduledoc """
  `Domains.Review` natural overlays + entity shell
  (MCP-VFS-GROUP-MOUNTS.md §2.17), backed by the local review domain
  (`Domains.Reviews`, `Services.Comment`, `Services.Attach`).

  Owns the `/tobor/{org}/review` subtree (Root dispatches mapped groups
  wholly):

      /tobor/{org}/review                        readdir = review ids
      /tobor/{org}/review/overview.md            group overview
      /tobor/{org}/review/{review-id}            review dir (server-assigned UUID)
      …/{review-id}/record.json                  read = Review.Get · write = Review update
                                                 create = Review.Create
      …/{review-id}/overlay.md                   natural file over the overlay set (§2.17)
      …/{review-id}/comments/                    readdir = comments · create = Review.Comment
      …/{review-id}/attached.json                read = attachment list · write = Review.Attach
      …/{review-id}/actions/complete             control write = Review.Complete (§3.5)
      …/{review-id}/actions/compile              control write = Review.Compile
      …/{review-id}/compiled.md                  compiled feedback (read-only render)

  Natural-file semantics:

    * `overlay.md` READ renders the overlay set as markdown; WRITE appends one
      annotation (the body is the annotation text, persona = the review's
      reviewer). Overlays are rows — the write is additive so no review
      annotation can ever be lost through a file overwrite.
    * `comments/{ts}-{id}.json` entries are immutable (`:eacces` on write);
      CREATE appends a comment from a JSON body `{content, author, location?,
      reply_to_id?}`. Reads resolve by the entry's id suffix, so the
      canonical `{ts}-{id}.json` names from readdir always re-read.
    * `attached.json` READ is the attachment array; WRITE adds attachment(s)
      (single object or `{"attachments": [...]}`).

  Control writes (§3.5 — state transitions are never content edits):
  `actions/complete` finalizes the review (body `{summary?, verdict?}`),
  after which `record.json` writes are refused `:eacces` (the domain freezes
  completed reviews); `actions/compile` validates the request; the compiled
  feedback renders on `compiled.md` reads (cheap synchronous compile — no
  job-dir needed at these sizes).
  """

  use Noizu.MCP.VFS

  alias Noizu.MCP.VFS
  alias NoizuPromptLingua.Domains.Reviews
  alias NoizuPromptLingua.MCP.VFS.Principal
  alias NoizuPromptLingua.Organizations
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Artifact
  alias NoizuPromptLingua.Services.{Attach, Comment}

  @orgs_root "tobor"
  @group_id "review"
  @group_dir "review"
  @record "record.json"
  @overlay "overlay.md"
  @comments "comments"
  @attached "attached.json"
  @actions "actions"
  @complete "complete"
  @compile_op "compile"
  @compiled "compiled.md"

  # ── stat/2 ────────────────────────────────────────────────────────────────

  @impl true
  def stat(path, ctx) do
    with {:ok, segments} <- split_segments(path) do
      case segments do
        [@orgs_root, org, @group_dir] ->
          require_org(ctx, org, fn -> {:ok, dir_node()} end)

        [@orgs_root, org, @group_dir, "overview.md"] ->
          require_org(ctx, org, fn -> {:ok, file_node(byte_size(overview_md()))} end)

        [@orgs_root, org, @group_dir, id] ->
          with_review(ctx, org, id, fn review -> {:ok, with_xattrs(dir_node(), review)} end)

        [@orgs_root, org, @group_dir, id, @record] ->
          with_review(ctx, org, id, fn review -> {:ok, file_node(doc_size(review))} end)

        [@orgs_root, org, @group_dir, id, @overlay] ->
          with_full(ctx, org, id, fn {review, comments, overlays} ->
            {:ok, file_node(byte_size(render_overlay_md(review, comments, overlays)))}
          end)

        [@orgs_root, org, @group_dir, id, @comments] ->
          with_review(ctx, org, id, fn _review -> {:ok, dir_node()} end)

        [@orgs_root, org, @group_dir, id, @comments, _entry] ->
          with_review(ctx, org, id, fn _review -> {:ok, file_node(0)} end)

        [@orgs_root, org, @group_dir, id, @attached] ->
          with_review(ctx, org, id, fn review ->
            {:ok, file_node(byte_size(Jason.encode!(attachments_doc(review.id))))}
          end)

        [@orgs_root, org, @group_dir, id, @actions, action]
        when action in [@complete, @compile_op] ->
          with_review(ctx, org, id, fn _review -> {:ok, control_node()} end)

        [@orgs_root, org, @group_dir, id, @compiled] ->
          with_full(ctx, org, id, fn {review, comments, overlays} ->
            {:ok, file_node(byte_size(render_compiled_md(review, comments, overlays)))}
          end)

        _ ->
          {:error, :enoent}
      end
    end
  end

  # ── list/3 ────────────────────────────────────────────────────────────────

  @impl true
  def list(path, cursor, ctx) do
    with {:ok, segments} <- split_segments(path),
         {:ok, entries} <- list_segments(segments, ctx) do
      case cursor do
        c when c in [nil, ""] -> {:ok, entries, nil}
        _ -> {:error, Noizu.MCP.Error.invalid_params("invalid cursor")}
      end
    end
  end

  defp list_segments([@orgs_root, org, @group_dir], ctx) do
    require_org(ctx, org, fn ->
      with {:ok, org_id} <- resolve_org_id(org) do
        ids =
          Reviews.list(organization_id: org_id, limit: 10_000)
          |> Enum.map(& &1.id)
          |> Enum.sort()

        {:ok, Enum.map(ids, &dir_entry/1)}
      end
    end)
  end

  defp list_segments([@orgs_root, org, @group_dir, "overview.md"], ctx) do
    require_org(ctx, org, fn -> {:ok, [file_entry("overview.md")]} end)
  end

  defp list_segments([@orgs_root, org, @group_dir, id], ctx) do
    with_review(ctx, org, id, fn _review ->
      {:ok,
       [
         file_entry(@record),
         file_entry(@overlay),
         dir_entry(@comments),
         file_entry(@attached),
         dir_entry(@actions),
         file_entry(@compiled)
       ]}
    end)
  end

  defp list_segments([@orgs_root, org, @group_dir, id, @comments], ctx) do
    with_review(ctx, org, id, fn review ->
      entries =
        "review"
        |> Comment.list(review.id)
        |> Enum.map(fn c -> file_entry("#{entry_ts(c.inserted_at)}-#{c.id}.json") end)
        |> Enum.sort_by(& &1.name)

      {:ok, entries}
    end)
  end

  defp list_segments([@orgs_root, org, @group_dir, id, @actions], ctx) do
    with_review(ctx, org, id, fn _review ->
      {:ok, [file_entry(@complete), file_entry(@compile_op)]}
    end)
  end

  defp list_segments(_, _), do: {:error, :enoent}

  # ── read/2 ────────────────────────────────────────────────────────────────

  @impl true
  def read(path, ctx) do
    with {:ok, segments} <- split_segments(path) do
      case segments do
        [@orgs_root, org, @group_dir, "overview.md"] ->
          require_org(ctx, org, fn -> {:ok, overview_md(), version()} end)

        [@orgs_root, org, @group_dir, id, @record] ->
          with_review(ctx, org, id, fn review ->
            {:ok, Jason.encode!(review_doc(review)), version()}
          end)

        [@orgs_root, org, @group_dir, id, @overlay] ->
          with_full(ctx, org, id, fn {review, comments, overlays} ->
            {:ok, render_overlay_md(review, comments, overlays), version()}
          end)

        [@orgs_root, org, @group_dir, id, @comments, entry] ->
          with_review(ctx, org, id, fn review ->
            with {:ok, comment} <- find_comment(review.id, entry) do
              {:ok, Jason.encode!(comment_doc(comment)), version()}
            end
          end)

        [@orgs_root, org, @group_dir, id, @attached] ->
          with_review(ctx, org, id, fn review ->
            {:ok, Jason.encode!(attachments_doc(review.id)), version()}
          end)

        [@orgs_root, org, @group_dir, id, @actions, @complete] ->
          with_review(ctx, org, id, fn review ->
            {:ok,
             Jason.encode!(%{
               "action" => "complete",
               "review" => review.id,
               "status" => review.status
             }), version()}
          end)

        [@orgs_root, org, @group_dir, id, @actions, @compile_op] ->
          with_review(ctx, org, id, fn _review ->
            {:ok,
             Jason.encode!(%{
               "action" => "compile",
               "review" => id,
               "output" => "../compiled.md"
             }), version()}
          end)

        [@orgs_root, org, @group_dir, id, @compiled] ->
          with_full(ctx, org, id, fn {review, comments, overlays} ->
            {:ok, render_compiled_md(review, comments, overlays), version()}
          end)

        [@orgs_root, _org, @group_dir] ->
          {:error, :eisdir}

        _ ->
          {:error, :enoent}
      end
    end
  end

  # ── write/3 ───────────────────────────────────────────────────────────────

  @impl true
  def write(path, content, ctx) do
    with {:ok, segments} <- split_segments(path) do
      case segments do
        [@orgs_root, org, @group_dir, id, @record] ->
          write_record(ctx, org, id, content)

        [@orgs_root, org, @group_dir, id, @overlay] ->
          write_overlay(ctx, org, id, content)

        [@orgs_root, org, @group_dir, id, @attached] ->
          write_attached(ctx, org, id, content)

        [@orgs_root, org, @group_dir, id, @actions, @complete] ->
          write_complete(ctx, org, id, content)

        [@orgs_root, org, @group_dir, id, @actions, @compile_op] ->
          write_compile(ctx, org, id)

        # Comment entries are append-only (immutable once created).
        [@orgs_root, _org, @group_dir, _id, @comments, _entry] ->
          {:error, :eacces}

        _ ->
          {:error, :enoent}
      end
    end
  end

  # Review update — the domain sanitizes to mutable fields and freezes
  # completed reviews (its errors map below).
  defp write_record(ctx, org, id, content) do
    with {:ok, review} <- gated_review(ctx, org, id),
         {:ok, doc} <- decode(content) do
      attrs = stringify_keys(doc)

      case Reviews.update(review.id, attrs) do
        {:ok, updated} -> {:ok, file_node(doc_size(updated))}
        {:error, :not_found} -> {:error, :enoent}
        # Frozen review / status completed via update — both are §3.5
        # transitions, refused at the content plane.
        {:error, :completed} -> {:error, :eacces}
        {:error, :use_complete} -> {:error, :eacces}
        {:error, _changeset} -> {:error, :eio}
      end
    else
      {:error, _} = err -> err
      _ -> {:error, :enoent}
    end
  end

  # ReviewOverlay as a natural file (§2.17): the body is ONE annotation,
  # appended — rows are canonical, so an overwrite can never destroy one.
  defp write_overlay(ctx, org, id, content) do
    with {:ok, review} <- gated_review(ctx, org, id),
         body when is_binary(body) and body != "" <- content do
      case Reviews.add_overlay(%{
             review_id: review.id,
             x: 0,
             y: 0,
             comment: body,
             persona: review.reviewer_persona
           }) do
        {:ok, _overlay} -> {:ok, file_node(byte_size(body))}
        {:error, _changeset} -> {:error, :eio}
      end
    else
      {:error, _} = err -> err
      _ -> {:error, :eio}
    end
  end

  # ReviewAttach: single attachment object, or {"attachments": [...]}.
  defp write_attached(ctx, org, id, content) do
    with {:ok, review} <- gated_review(ctx, org, id),
         {:ok, doc} <- decode(content),
         attachments when is_list(attachments) and attachments != [] <-
           Map.get(doc, "attachments", [doc]) do
      results =
        Enum.map(attachments, fn att ->
          Attach.add("review", review.id, attachment_attrs(att))
        end)

      if Enum.all?(results, &match?({:ok, _}, &1)),
        do: {:ok, file_node(byte_size(Jason.encode!(attachments_doc(review.id))))},
        else: {:error, :eio}
    else
      {:error, _} = err -> err
      _ -> {:error, :eio}
    end
  end

  defp attachment_attrs(att) when is_map(att) do
    %{
      artifact_type: att["artifact_type"] || "artifact",
      url: att["url"],
      description: att["description"]
    }
  end

  defp attachment_attrs(_), do: %{artifact_type: "artifact"}

  # ReviewComplete — the control write (§2.17/§3.5).
  defp write_complete(ctx, org, id, content) do
    with {:ok, review} <- gated_review(ctx, org, id),
         {:ok, doc} <- decode(content) do
      attrs = Map.take(stringify_keys(doc), ["summary", "verdict"])

      case Reviews.complete(review.id, attrs) do
        {:ok, _} -> {:ok, control_node()}
        {:error, :not_found} -> {:error, :enoent}
        {:error, _changeset} -> {:error, :eio}
      end
    else
      {:error, _} = err -> err
      _ -> {:error, :enoent}
    end
  end

  # ReviewCompile — synchronous stub today (mirrors the tool); the render
  # result is served on compiled.md reads.
  defp write_compile(ctx, org, id) do
    with {:ok, _review} <- gated_review(ctx, org, id) do
      {:ok, control_node()}
    else
      {:error, _} = err -> err
      _ -> {:error, :enoent}
    end
  end

  # ── create/3 — Review.Create + Review.Comment ─────────────────────────────

  @impl true
  def create(_path, :dir, _ctx), do: {:error, :enosys}

  def create(path, content, ctx) do
    with {:ok, segments} <- split_segments(path) do
      case segments do
        [@orgs_root, org, @group_dir, _token, @record] ->
          create_review(ctx, org, content)

        [@orgs_root, org, @group_dir, id, @comments, _entry] ->
          create_comment(ctx, org, id, content)

        _ ->
          {:error, :enoent}
      end
    end
  end

  defp create_review(ctx, org, content) do
    with :ok <- require_org(ctx, org, fn -> :ok end),
         {:ok, org_id} <- resolve_org_id(org),
         {:ok, doc} <- decode(content),
         {:ok, artifact_id} <- require_field(doc, "artifact_id"),
         {:ok, revision_id} <- require_field(doc, "revision_id"),
         {:ok, persona} <- require_field(doc, "reviewer_persona"),
         :ok <- verify_artifact(artifact_id, org_id) do
      attrs = %{
        organization_id: org_id,
        project_id: uuid_or_nil(doc["project_id"]),
        artifact_id: artifact_id,
        revision_id: revision_id,
        reviewer_persona: persona,
        title: doc["title"]
      }

      case Reviews.create(attrs) do
        {:ok, review} ->
          xattrs = %{
            "id" => review.id,
            "canonical_path" => "/#{@orgs_root}/#{org}/#{@group_dir}/#{review.id}/#{@record}"
          }

          {:ok, %VFS{file_node(doc_size(review)) | xattrs: xattrs}}

        {:error, _changeset} ->
          {:error, :eio}
      end
    else
      {:error, _} = err -> err
      _ -> {:error, :enoent}
    end
  end

  defp create_comment(ctx, org, id, content) do
    with {:ok, review} <- gated_review(ctx, org, id),
         {:ok, doc} <- decode(content),
         {:ok, body} <- require_field(doc, "content"),
         {:ok, author} <- require_field(doc, "author") do
      attrs = %{
        content: body,
        author: author,
        location: doc["location"],
        reply_to_id: doc["reply_to_id"]
      }

      case Comment.add("review", review.id, attrs) do
        {:ok, comment} ->
          canonical = "#{entry_ts(comment.inserted_at)}-#{comment.id}.json"

          xattrs = %{
            "id" => comment.id,
            "canonical_path" =>
              "/#{@orgs_root}/#{org}/#{@group_dir}/#{review.id}/#{@comments}/#{canonical}"
          }

          {:ok, %VFS{file_node(byte_size(Jason.encode!(comment_doc(comment)))) | xattrs: xattrs}}

        {:error, _changeset} ->
          {:error, :eio}
      end
    else
      {:error, _} = err -> err
      _ -> {:error, :enoent}
    end
  end

  # ── payload ───────────────────────────────────────────────────────────────

  defp review_doc(review) do
    %{
      "id" => review.id,
      "organization_id" => review.organization_id,
      "project_id" => review.project_id,
      "artifact_id" => review.artifact_id,
      "revision_id" => review.revision_id,
      "reviewer_persona" => review.reviewer_persona,
      "title" => review.title,
      "status" => review.status,
      "summary" => review.summary,
      "verdict" => review.verdict,
      "created_at" => iso(review.inserted_at),
      "updated_at" => iso(review.updated_at)
    }
  end

  defp doc_size(review), do: byte_size(Jason.encode!(review_doc(review)))

  defp comment_doc(c) do
    %{
      "id" => c.id,
      "review_id" => c.entity_id,
      "content" => c.content,
      "author" => c.author,
      "location" => c.location,
      "reply_to_id" => c.reply_to_id,
      "created_at" => iso(c.inserted_at)
    }
  end

  defp attachments_doc(review_id) do
    Enum.map(Attach.list("review", review_id), fn a ->
      %{
        "id" => a.id,
        "artifact_type" => a.artifact_type,
        "url" => a.url,
        "description" => a.description,
        "created_at" => iso(a.inserted_at)
      }
    end)
  end

  # overlay.md — the natural-file render of the overlay set.
  defp render_overlay_md(review, _comments, overlays) do
    header = """
    # Overlay — #{review.title || review.id}

    status: #{review.status} · reviewer: #{review.reviewer_persona}
    """

    sections =
      if overlays == [] do
        ["\n_No annotations yet — write this file to append one._\n"]
      else
        Enum.map(overlays, fn o ->
          """
          ## @ (#{o.x}, #{o.y})#{size_suffix(o)} — #{o.persona}

          #{o.comment}
          """
        end)
      end

    IO.iodata_to_binary([header, ?\n, sections])
  end

  defp size_suffix(%{width: w, height: h}) when is_integer(w) and is_integer(h), do: " #{w}x#{h}"
  defp size_suffix(_), do: ""

  # compiled.md — the compiled feedback document (ReviewCompile output).
  defp render_compiled_md(review, comments, overlays) do
    comment_lines =
      Enum.map(comments, fn c ->
        location = if c.location in [nil, ""], do: "", else: " (#{c.location})"
        "- **#{c.author}**#{location}: #{c.content}\n"
      end)

    overlay_lines =
      Enum.map(overlays, fn o ->
        "- @ (#{o.x}, #{o.y}) #{o.persona}: #{o.comment}\n"
      end)

    """
    # Review — #{review.title || review.id}

    - status: #{review.status}
    - verdict: #{review.verdict || "—"}
    - reviewer: #{review.reviewer_persona}
    - artifact: #{review.artifact_id} @ #{review.revision_id}
    #{summary_block(review)}
    ## Comments

    #{blank_if_empty(comment_lines)}

    ## Overlays

    #{blank_if_empty(overlay_lines)}
    """
  end

  defp summary_block(%{summary: s}) when is_binary(s) and s != "", do: "\n#{s}\n"
  defp summary_block(_), do: ""

  defp blank_if_empty([]), do: "_none_"
  defp blank_if_empty(lines), do: IO.iodata_to_binary(lines)

  # ── lookups ───────────────────────────────────────────────────────────────

  defp require_org(ctx, org, fun) do
    if Principal.org_visible?(ctx, org) and match?(:ok, Principal.group_gate(ctx, @group_id)) do
      fun.()
    else
      {:error, :enoent}
    end
  end

  defp resolve_org_id(org) do
    case Organizations.get_id_by_slug(org) do
      nil -> {:error, :enoent}
      id -> {:ok, id}
    end
  end

  defp with_review(ctx, org, id, fun) do
    case gated_review(ctx, org, id) do
      {:ok, review} -> fun.(review)
      {:error, _} = err -> err
    end
  end

  defp gated_review(ctx, org, id) do
    require_org(ctx, org, fn -> review_in_org(org, id) end)
  end

  defp with_full(ctx, org, id, fun) do
    with_review(ctx, org, id, fn review ->
      {review, comments, overlays} = Reviews.get(review.id)
      fun.({review, comments, overlays})
    end)
  end

  defp review_in_org(org, id) do
    with {:ok, org_id} <- resolve_org_id(org),
         {review, _comments, _overlays} when review.organization_id == org_id <-
           Reviews.get(id) do
      {:ok, review}
    else
      _ -> {:error, :enoent}
    end
  end

  defp find_comment(review_id, entry) do
    # {ts}-{id}.json → the id is everything after the FIRST dash; UUIDs carry
    # dashes, so parts: 2 (the ts half has none).
    id =
      entry
      |> String.trim_trailing(".json")
      |> String.split("-", parts: 2)
      |> List.last()

    case Repo.get(NoizuPromptLingua.Schema.Comment, id) do
      %{entity_type: "review", entity_id: ^review_id} = comment -> {:ok, comment}
      _ -> {:error, :enoent}
    end
  end

  defp verify_artifact(artifact_id, org_id) do
    case Repo.get(Artifact, artifact_id) do
      nil -> {:error, :enoent}
      %{organization_id: ^org_id} -> :ok
      _ -> {:error, :enoent}
    end
  end

  # ── shared shape helpers ──────────────────────────────────────────────────

  defp decode(content) when is_binary(content) do
    case Jason.decode(content) do
      {:ok, doc} when is_map(doc) -> {:ok, doc}
      _ -> {:error, :eio}
    end
  end

  defp decode(_), do: {:error, :eio}

  defp require_field(doc, key) do
    case doc[key] do
      v when is_binary(v) and v != "" -> {:ok, v}
      _ -> {:error, :eio}
    end
  end

  defp uuid_or_nil(v) do
    case NoizuPromptLingua.UUID.cast(v) do
      {:ok, uuid} -> uuid
      :error -> nil
    end
  end

  defp stringify_keys(map) when is_map(map),
    do: Map.new(map, fn {k, v} -> {if(is_binary(k), do: k, else: to_string(k)), v} end)

  defp entry_ts(dt) do
    dt
    |> DateTime.truncate(:second)
    |> Calendar.strftime("%Y%m%dT%H%M%S")
  end

  defp iso(nil), do: nil
  defp iso(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp iso(other), do: to_string(other)

  defp overview_md do
    """
    # Review (review)

    Review natural-overlay tree (`MCP-VFS-GROUP-MOUNTS.md` §2.17). One dir per
    review: `record.json` is the canonical document, `overlay.md` and
    `comments/` are the natural annotation surfaces, `attached.json` carries
    artifact links, and lifecycle transitions (`complete`, `compile`) are
    `actions/` control writes with the compiled feedback on `compiled.md`.
    """
  end

  # ── node builders (Root.ex conventions) ───────────────────────────────────

  defp dir_node, do: %VFS{type: :dir, mtime: now_ms(), version: version()}
  defp file_node(size), do: %VFS{type: :file, size: size, mtime: now_ms(), version: version()}
  defp control_node, do: %VFS{type: :control, size: 0, mtime: now_ms(), version: version()}

  defp with_xattrs(node, review), do: %{node | xattrs: %{"id" => review.id}}

  defp dir_entry(name),
    do: %{name: name, type: :dir, size: 0, mtime: now_ms(), version: version()}

  defp file_entry(name),
    do: %{name: name, type: :file, size: 0, mtime: now_ms(), version: version()}

  defp version, do: 1
  defp now_ms, do: System.os_time(:millisecond)

  defp split_segments(path) do
    segments =
      path
      |> String.trim_trailing("/")
      |> String.split("/", trim: true)

    if Enum.any?(segments, &(&1 in [".", ".."])),
      do: {:error, :enoent},
      else: {:ok, segments}
  end
end
