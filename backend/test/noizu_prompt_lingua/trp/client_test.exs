defmodule NoizuPromptLingua.TRP.ClientTest do
  @moduledoc """
  Client-level contract: spec §1.5 error envelopes, bearer transport, retry
  policy (5xx + 429 retry_after), not-configured gating, query encoding.
  """
  use ExUnit.Case, async: false

  alias NoizuPromptLingua.TRP.{Client, Error, TestStub}

  setup do
    TestStub.reset()
    TestStub.last_auth()
    :ok
  end

  test "sends the raw shared key as a Bearer credential" do
    TestStub.seed_org("11111111-1111-1111-1111-111111111111", "acme")
    {:ok, _} = Client.request(:get, "/api/v1/organizations")
    assert TestStub.last_auth() == "Bearer trp_sk_test"
  end

  test "401 envelope -> typed error" do
    # Poison the shared key so the stub rejects the request.
    prev = Application.get_env(:noizu_prompt_lingua, :trp)

    Application.put_env(:noizu_prompt_lingua, :trp,
      base_url: "http://trp.test",
      shared_key: "trp_sk_wrong"
    )

    assert {:error, %Error{status: 401, message: "unauthorized"}} =
             Client.request(:get, "/api/v1/organizations")

    Application.put_env(:noizu_prompt_lingua, :trp, prev)
  end

  test "403 reason code maps to a known atom" do
    TestStub.queue_response(
      {403, %{"error" => "forbidden", "reason" => "org_not_in_key_scope"}}
    )

    assert {:error, %Error{status: 403, reason: :org_not_in_key_scope}} =
             Client.request(:get, "/api/v1/organizations")
  end

  test "404 and 422 envelopes" do
    TestStub.queue_response({404, %{"error" => "Item not found"}})
    assert {:error, %Error{status: 404}} = Client.request(:get, "/api/v1/organizations/o/items/x")

    TestStub.queue_response({422, %{"errors" => %{"name" => ["can't be blank"]}}})

    # Bodies are atomized uniformly (success + error envelopes).
    assert {:error, %Error{status: 422, errors: %{name: ["can't be blank"]}}} =
             Client.request(:post, "/api/v1/organizations/o/items", json: %{})
  end

  test "429 honors retry_after once, then the queued success wins" do
    TestStub.queue_response({429, %{"error" => "rate_limited", "retry_after" => 0}})
    # retry_after of 0 → no sleep (guard: is_integer and > 0), then attempt routes.
    TestStub.seed_org("11111111-1111-1111-1111-111111111111", "acme")

    assert {:ok, %{organizations: [%{slug: "acme"}]}} =
             Client.request(:get, "/api/v1/organizations")
  end

  test "5xx retries then succeeds" do
    TestStub.queue_response({502, %{"error" => "bad gateway"}})
    TestStub.seed_org("11111111-1111-1111-1111-111111111111", "acme")

    assert {:ok, %{organizations: _}} = Client.request(:get, "/api/v1/organizations")
  end

  test "5xx exhausts retries and surfaces the error" do
    TestStub.queue_response({500, %{"error" => "boom"}})
    TestStub.queue_response({500, %{"error" => "boom"}})
    TestStub.queue_response({500, %{"error" => "boom"}})

    assert {:error, %Error{status: 500}} = Client.request(:get, "/api/v1/organizations")
  end

  test "transport failure is tagged {:transport, reason}" do
    TestStub.queue_response({:transport, :econnrefused})
    assert {:error, {:transport, :econnrefused}} = Client.request(:get, "/api/v1/organizations")
  end

  test "missing config fails at call time with :trp_not_configured" do
    prev = Application.get_env(:noizu_prompt_lingua, :trp)
    Application.put_env(:noizu_prompt_lingua, :trp, base_url: nil, shared_key: nil)

    assert {:error, :trp_not_configured} = Client.request(:get, "/api/v1/organizations")

    Application.put_env(:noizu_prompt_lingua, :trp, prev)
  end

  test "nil query values are dropped from the URL" do
    # The stub 404s unknown routes with the path in the envelope — assert the
    # known-slug org is still found when project_id=nil is filtered out.
    TestStub.seed_org("11111111-1111-1111-1111-111111111111", "acme")

    assert {:ok, %{organizations: [_]}} =
             Client.request(:get, "/api/v1/organizations", query: [project_id: nil])
  end
end
