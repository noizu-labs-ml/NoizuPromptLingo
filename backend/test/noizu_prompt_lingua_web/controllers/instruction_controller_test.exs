defmodule NoizuPromptLinguaWeb.InstructionControllerTest do
  @moduledoc """
  Org-scoped versioned instructions: index filters, create/show/update/delete,
  versions listing, active-version switching, and param rendering (including
  the missing-params and unknown-version error paths). Auth matrix mirrors the
  other org-scoped controllers.
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Domains.Instructions
  alias NoizuPromptLingua.Authz.ScopedMemberships

  setup %{conn: conn} do
    %{access_token: token, user: user} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    slug = "instr-org-#{System.unique_integer([:positive])}"

    org_id =
      auth
      |> post("/api/v1/organizations", %{organization: %{slug: slug, name: "Instr Org"}})
      |> json_response(201)
      |> get_in(["organization", "id"])

    %{access_token: viewer_token, user: viewer} = setup_user_and_token()
    {:ok, _} = ScopedMemberships.add_member("organization", org_id, viewer.id, "viewer")

    %{access_token: outsider_token} = setup_user_and_token()

    {:ok,
     auth: auth,
     user: user,
     org_id: org_id,
     viewer_token: viewer_token,
     outsider_token: outsider_token}
  end

  defp base(org_id), do: "/api/v1/organizations/#{org_id}/instructions"
  defp base(org_id, suffix), do: "/api/v1/organizations/#{org_id}/instructions#{suffix}"

  defp create_instruction(auth, org_id, attrs \\ %{}, opts \\ []) do
    params =
      Map.merge(
        %{slug: "instr-#{System.unique_integer([:positive])}", title: "Research Agent"},
        attrs
      )
      # A body is required for the initial version record.
      |> Map.put("body", opts[:body] || "seed body")

    auth
    |> post(base(org_id), %{instruction: params})
    |> json_response(201)
    |> get_in(["instruction", "id"])
  end

  # ── Auth matrix ───────────────────────────────────────────────────────────

  describe "auth matrix" do
    test "unauthenticated request is rejected by the pipeline", %{conn: conn, org_id: org_id} do
      assert %{"error" => "unauthenticated"} = conn |> get(base(org_id)) |> json_response(401)
    end

    test "non-member gets 403 not_a_member", %{conn: conn, org_id: org_id, outsider_token: t} do
      assert %{"error" => "Not a member of this organization"} =
               conn |> authenticated_conn(t) |> get(base(org_id)) |> json_response(403)
    end

    test "viewer is denied member-only create", %{conn: conn, org_id: org_id, viewer_token: t} do
      assert %{"error" => "Insufficient permissions"} =
               conn
               |> authenticated_conn(t)
               |> post(base(org_id), %{instruction: %{title: "Nope"}})
               |> json_response(403)
    end

    test "unknown org slug returns 404", %{auth: auth} do
      assert %{"error" => "Organization not found"} =
               auth |> get(base("no-such-instr-org")) |> json_response(404)
    end
  end

  # ── Index / Create ────────────────────────────────────────────────────────

  describe "GET /instructions" do
    test "lists org instructions and honors filters", %{auth: auth, org_id: org_id} do
      create_instruction(auth, org_id, %{slug: "qa-listing-a", title: "Alpha", tags: ["research"]})

      create_instruction(auth, org_id, %{slug: "qa-listing-b", title: "Beta", status: "archived"})

      %{"instructions" => all} = auth |> get(base(org_id)) |> json_response(200)
      assert length(all) == 2

      assert [%{"slug" => "qa-listing-b"}] =
               auth
               |> get(base(org_id), status: "archived")
               |> json_response(200)
               |> Map.fetch!("instructions")

      assert [%{"slug" => "qa-listing-a"}] =
               auth
               |> get(base(org_id), tag: "research")
               |> json_response(200)
               |> Map.fetch!("instructions")

      assert [%{"slug" => "qa-listing-a"}] =
               auth
               |> get(base(org_id), query: "alpha")
               |> json_response(200)
               |> Map.fetch!("instructions")

      # Empty-string filters are ignored.
      assert length(
               auth
               |> get(base(org_id), status: "", tag: "", query: "")
               |> json_response(200)
               |> Map.fetch!("instructions")
             ) == 2
    end
  end

  describe "POST /instructions" do
    test "creates v1 with body and defaults", %{auth: auth, org_id: org_id} do
      body =
        auth
        |> post(base(org_id), %{
          instruction: %{
            slug: "qa-create",
            title: "Coder",
            description: "does things",
            body: "Write {{language}} code"
          }
        })
        |> json_response(201)
        |> Map.fetch!("instruction")

      assert body["slug"] == "qa-create"
      assert body["active_version"] == 1
      assert body["organization_id"] == org_id
      assert body["status"] == "active"

      assert %{body: "Write {{language}} code"} = Instructions.get_version(body["id"])
    end

    test "missing title is 422", %{auth: auth, org_id: org_id} do
      assert %{"errors" => errors} =
               auth
               |> post(base(org_id), %{instruction: %{slug: "qa-no-title"}})
               |> json_response(422)

      assert errors["title"]
    end

    test "duplicate slug is 422", %{auth: auth, org_id: org_id} do
      create_instruction(auth, org_id, %{slug: "qa-dup"})

      assert %{"errors" => errors} =
               auth
               |> post(base(org_id), %{instruction: %{slug: "qa-dup", title: "Again"}})
               |> json_response(422)

      # The (org, slug) unique index reports on organization_id.
      assert errors["organization_id"]
    end

    test "project from another org is 422", %{auth: auth, org_id: org_id} do
      assert %{"error" => "Project does not belong to this organization"} =
               auth
               |> post(base(org_id), %{
                 instruction: %{slug: "qa-proj", title: "T", project_id: Ecto.UUID.generate()}
               })
               |> json_response(422)
    end
  end

  # ── Show ──────────────────────────────────────────────────────────────────

  describe "GET /instructions/:id" do
    test "returns instruction with versions and active body", %{auth: auth, org_id: org_id} do
      id = create_instruction(auth, org_id, %{slug: "qa-show"}, body: "v1 body")

      resp = auth |> get(base(org_id, "/#{id}")) |> json_response(200)
      assert resp["instruction"]["id"] == id
      assert resp["version"] == 1
      assert resp["body"] == "v1 body"

      assert [%{version: 1, active: true}] =
               Enum.map(resp["versions"], &%{version: &1["version"], active: &1["active"]})
    end

    test "explicit ?version= selects that body; empty version falls back to active", %{
      auth: auth,
      org_id: org_id
    } do
      id = create_instruction(auth, org_id, %{slug: "qa-vers"}, body: "v1 body")

      auth
      |> put(base(org_id, "/#{id}"), %{instruction: %{body: "v2 body", change_note: "edit"}})
      |> json_response(200)

      assert %{"body" => "v1 body", "version" => 1} =
               auth |> get(base(org_id, "/#{id}"), version: "1") |> json_response(200)

      assert %{"body" => "v2 body", "version" => 2} =
               auth |> get(base(org_id, "/#{id}"), version: "") |> json_response(200)
    end

    test "unknown id is 404", %{auth: auth, org_id: org_id} do
      assert %{"error" => "Instruction not found"} =
               auth |> get(base(org_id, "/#{Ecto.UUID.generate()}")) |> json_response(404)
    end

    test "cross-org instruction is 404 (IDOR guard)", %{auth: auth, org_id: org_id} do
      {:ok, other_org} =
        NoizuPromptLingua.Repo.insert(%NoizuPromptLingua.Schema.Organizations.Organization{
          slug: "foreign-#{System.unique_integer([:positive])}",
          name: "Foreign Org"
        })

      {:ok, foreign} =
        Instructions.create(%{organization_id: other_org.id, slug: "fx", title: "F"}, body: "b")

      assert %{"error" => "Instruction not found"} =
               auth |> get(base(org_id, "/#{foreign.id |> to_string()}")) |> json_response(404)
    end
  end

  # ── Update / Delete ───────────────────────────────────────────────────────

  describe "PUT /instructions/:id" do
    test "edits metadata and appends a version when body present", %{auth: auth, org_id: org_id} do
      id = create_instruction(auth, org_id, %{slug: "qa-upd"}, body: "first")

      body =
        auth
        |> put(base(org_id, "/#{id}"), %{
          instruction: %{title: "Renamed", body: "second", change_note: "tune"}
        })
        |> json_response(200)
        |> Map.fetch!("instruction")

      assert body["title"] == "Renamed"
      assert body["active_version"] == 2

      assert [%{version: 2}, %{version: 1}] =
               Instructions.list_versions(id)
               |> Enum.map(&%{version: &1.version})

      assert %{body: "second"} = Instructions.get_version(id)
    end

    test "invalid status is 422 (changeset arm)", %{auth: auth, org_id: org_id} do
      id = create_instruction(auth, org_id, %{slug: "qa-upd-bad"})

      assert %{"errors" => errors} =
               auth
               |> put(base(org_id, "/#{id}"), %{instruction: %{status: "bogus"}})
               |> json_response(422)

      assert errors["status"]
    end

    test "unknown id is 404", %{auth: auth, org_id: org_id} do
      assert %{"error" => "Instruction not found"} =
               auth
               |> put(base(org_id, "/#{Ecto.UUID.generate()}"), %{instruction: %{title: "X"}})
               |> json_response(404)
    end
  end

  describe "DELETE /instructions/:id" do
    test "deletes and then the resource is gone", %{auth: auth, org_id: org_id} do
      id = create_instruction(auth, org_id, %{slug: "qa-del"})

      assert %{"message" => "Instruction deleted"} =
               auth |> delete(base(org_id, "/#{id}")) |> json_response(200)

      assert %{"error" => "Instruction not found"} =
               auth |> get(base(org_id, "/#{id}")) |> json_response(404)
    end

    test "unknown id is 404", %{auth: auth, org_id: org_id} do
      assert %{"error" => "Instruction not found"} =
               auth |> delete(base(org_id, "/#{Ecto.UUID.generate()}")) |> json_response(404)
    end
  end

  # ── Versions / active-version ─────────────────────────────────────────────

  describe "versions + active-version" do
    test "GET versions lists all with active flag", %{auth: auth, org_id: org_id} do
      id = create_instruction(auth, org_id, %{slug: "qa-vers-ls"}, body: "v1")

      auth
      |> put(base(org_id, "/#{id}"), %{instruction: %{body: "v2", change_note: "rev2"}})
      |> json_response(200)

      %{"versions" => versions} =
        auth |> get(base(org_id, "/#{id}/versions")) |> json_response(200)

      assert [
               %{"version" => 2, "active" => true, "change_note" => "rev2"},
               %{"version" => 1, "active" => false}
             ] = versions
    end

    test "POST active-version switches the active version", %{auth: auth, org_id: org_id} do
      id = create_instruction(auth, org_id, %{slug: "qa-av"}, body: "v1")

      auth
      |> put(base(org_id, "/#{id}"), %{instruction: %{body: "v2"}})
      |> json_response(200)

      body =
        auth
        |> post(base(org_id, "/#{id}/active-version"), %{version: "1"})
        |> json_response(200)
        |> Map.fetch!("instruction")

      assert body["active_version"] == 1
    end

    test "POST active-version with unknown version is 404", %{auth: auth, org_id: org_id} do
      id = create_instruction(auth, org_id, %{slug: "qa-av-bad"})

      assert %{"error" => "Version not found"} =
               auth
               |> post(base(org_id, "/#{id}/active-version"), %{version: "99"})
               |> json_response(404)
    end
  end

  # ── Render ────────────────────────────────────────────────────────────────

  describe "POST render" do
    defp renderable(auth, org_id, slug) do
      create_instruction(
        auth,
        org_id,
        %{
          slug: slug,
          parameters: [
            %{"name" => "language", "required" => true},
            %{"name" => "tone", "required" => false, "default" => "concise"}
          ]
        },
        body: "Write {{language}} code in a {{tone}} style."
      )
    end

    test "substitutes params and applies declared defaults", %{auth: auth, org_id: org_id} do
      id = renderable(auth, org_id, "qa-render")

      %{"rendered" => rendered} =
        auth
        |> post(base(org_id, "/#{id}/render"), %{
          params: %{"language" => "Elixir"},
          version: "1"
        })
        |> json_response(200)

      assert rendered["body"] == "Write Elixir code in a concise style."
      assert rendered["version"] == 1
      assert rendered["params"]["tone"] == "concise"
    end

    test "missing required param is 422 with the missing list", %{auth: auth, org_id: org_id} do
      id = renderable(auth, org_id, "qa-render-miss")

      assert %{"error" => "Missing required params", "missing" => ["language"]} =
               auth
               |> post(base(org_id, "/#{id}/render"), %{params: %{}})
               |> json_response(422)
    end

    test "unknown version is 404", %{auth: auth, org_id: org_id} do
      id = renderable(auth, org_id, "qa-render-badver")

      assert %{"error" => "Version not found"} =
               auth
               |> post(base(org_id, "/#{id}/render"), %{params: %{}, version: "42"})
               |> json_response(404)
    end

    test "empty params map defaults to %{}", %{auth: auth, org_id: org_id} do
      id =
        create_instruction(auth, org_id, %{slug: "qa-render-noparams"}, body: "static body")

      %{"rendered" => rendered} =
        auth |> post(base(org_id, "/#{id}/render"), %{}) |> json_response(200)

      assert rendered["body"] == "static body"
    end
  end
end
