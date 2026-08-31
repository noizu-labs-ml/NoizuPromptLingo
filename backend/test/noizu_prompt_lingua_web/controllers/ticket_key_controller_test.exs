defmodule NoizuPromptLinguaWeb.TicketKeyControllerTest do
  @moduledoc """
  Ticket human key over REST (f8bc7fab / 055): create echoes the immutable key + number,
  and a ticket is fetchable by its human key (org-scoped) as well as by UUID.
  """
  use NoizuPromptLinguaWeb.ConnCase

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    auth = authenticated_conn(conn, token)

    slug = "tkey-org-#{System.unique_integer([:positive])}"

    created =
      post(auth, "/api/v1/organizations", %{organization: %{slug: slug, name: "TKey Org"}})

    org_id = json_response(created, 201)["organization"]["id"]

    # W4 cutover: TRP stub backs ticket data; register the org for id-only reads.
    NoizuPromptLingua.TRP.Cache.clear()
    NoizuPromptLingua.TRP.TestStub.reset()
    NoizuPromptLingua.TRP.TestStub.seed_org(org_id, slug)

    {:ok, conn: auth, org_id: org_id, base: "/api/v1/organizations/#{org_id}/tickets"}
  end

  test "create echoes a human key + number; GET resolves by the key and by UUID", %{
    conn: conn,
    base: base
  } do
    t =
      json_response(post(conn, base, %{ticket: %{title: "Bug", ticket_type: "task"}}), 201)[
        "ticket"
      ]

    # Key/number GENERATION is TRP-owned post-cutover; NPL echoes it verbatim.
    assert is_integer(t["number"])
    assert t["key"] =~ ~r/^[A-Z0-9]{2,16}-\d{3,}$/

    by_key = json_response(get(conn, "#{base}/#{t["key"]}"), 200)["ticket"]
    assert by_key["id"] == t["id"]
    assert by_key["key"] == t["key"]

    by_uuid = json_response(get(conn, "#{base}/#{t["id"]}"), 200)["ticket"]
    assert by_uuid["key"] == t["key"]
  end

  test "a second ticket increments the number", %{conn: conn, base: base} do
    a =
      json_response(post(conn, base, %{ticket: %{title: "A", ticket_type: "task"}}), 201)[
        "ticket"
      ]

    b =
      json_response(post(conn, base, %{ticket: %{title: "B", ticket_type: "task"}}), 201)[
        "ticket"
      ]

    assert is_integer(b["number"]) and b["number"] != a["number"]
  end
end
