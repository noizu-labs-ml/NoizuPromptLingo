defmodule NoizuPromptLingua.TRP.TRPResidualTest do
  @moduledoc """
  W4-D residual branch coverage for the TRP plane: client retry-exhaustion and
  decode fallbacks, facade 404-fold + envelope tolerance, cache stale-serve,
  config fallbacks, error-envelope folds, shapes data_map key styles, and the
  ServiceAuth rotate/fallback ladder over a scripted JWT stub.
  """

  use ExUnit.Case, async: false

  alias NoizuPromptLingua.TRP
  alias NoizuPromptLingua.TRP.{Cache, Client, Config, Error, ServiceAuth, Shapes, TestStub}
  alias NoizuPromptLingua.TRP.JwtStub

  setup do
    prev_trp = Application.get_env(:noizu_prompt_lingua, :trp)
    prev_service = Application.get_env(:noizu_prompt_lingua, :trp_service)
    prev_transport = Application.get_env(:noizu_prompt_lingua, :trp_service_transport)

    Application.put_env(:noizu_prompt_lingua, :trp,
      base_url: "http://trp.test",
      shared_key: "trp_sk_test"
    )

    Application.put_env(:noizu_prompt_lingua, :trp_service,
      email: "svc@noizu.com",
      password: "secret"
    )

    Application.put_env(:noizu_prompt_lingua, :trp_service_transport, JwtStub)
    JwtStub.reset()
    ServiceAuth.reset()
    Cache.clear()
    TestStub.reset()

    on_exit(fn ->
      if prev_trp, do: Application.put_env(:noizu_prompt_lingua, :trp, prev_trp)
      if prev_service, do: Application.put_env(:noizu_prompt_lingua, :trp_service, prev_service)

      if prev_transport do
        Application.put_env(:noizu_prompt_lingua, :trp_service_transport, prev_transport)
      end
    end)

    :ok
  end

  # ── Client: retry ladder + decode fallbacks ──────────────────────

  test "429 chain exhausts retries and surfaces the last raw error" do
    # retry_after 0 → no sleep; the 429 branch has no attempts guard, so four
    # queued 429s drive attempts_left to 0 and the raw passthrough clause runs.
    for _ <- 1..4,
        do: TestStub.queue_response({429, %{"error" => "rate_limited", "retry_after" => 0}})

    assert {:error, %Error{status: 429}} = Client.request(:get, "/api/v1/organizations")
  end

  test "429 with an out-of-range retry_after returns without retrying" do
    TestStub.queue_response({429, %{"error" => "rate_limited", "retry_after" => 99}})

    assert {:error, %Error{status: 429}} = Client.request(:get, "/api/v1/organizations")
  end

  test "empty and non-JSON bodies decode to nil" do
    TestStub.queue_response({204, ""})
    assert {:ok, nil} = Client.request(:delete, "/api/v1/organizations/o/items/x")

    TestStub.queue_response({200, "<html>not json</html>"})
    assert {:ok, nil} = Client.request(:get, "/api/v1/organizations")
  end

  # ── Facade: remove_type_field 404-fold + envelope tolerance ──────

  test "remove_type_field busts the cache on success" do
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "rem-org")
    type_id = Ecto.UUID.generate()

    TestStub.queue_response({200, %{"ok" => true}})
    assert {:ok, nil} = TRP.remove_type_field(org_id, type_id, Ecto.UUID.generate())
  end

  test "remove_type_field folds 404 to :not_found and passes other errors" do
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "rem-org-2")
    type_id = Ecto.UUID.generate()

    TestStub.queue_response({404, %{"error" => "nope"}})
    assert {:error, :not_found} = TRP.remove_type_field(org_id, type_id, Ecto.UUID.generate())

    for _ <- 1..3, do: TestStub.queue_response({500, %{"error" => "boom"}})

    assert {:error, %Error{status: 500}} =
             TRP.remove_type_field(org_id, type_id, Ecto.UUID.generate())
  end

  test "list envelopes without the meta key still find the list payload" do
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "unwrap-org")

    TestStub.queue_response({200, %{"data" => [%{"id" => "i1", "title" => "t"}]}})

    assert [%{id: "i1"}] = TRP.list_items(org_id)
  end

  test "list envelopes with no list payload degrade to an empty list" do
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "unwrap-org-2")

    TestStub.queue_response({200, %{"nope" => "nothing here"}})
    assert [] = TRP.list_items(org_id)

    TestStub.queue_response({200, "ok"})
    assert [] = TRP.list_items(org_id)
  end

  test "get_item envelopes without the entity key fall back to a map value" do
    org_id = TestStub.seed_org(Ecto.UUID.generate(), "unwrap-org-3")

    TestStub.queue_response({200, %{"payload" => %{"id" => "i2", "title" => "t"}}})
    assert %{id: "i2"} = TRP.get_item(org_id, "i2")

    TestStub.queue_response({200, %{"payload" => "scalar"}})
    assert %{} = TRP.get_item(org_id, "i3")
  end

  # ── Cache: stale-serve on transport failure ──────────────────────

  test "cached_get serves a stale entry when the fetch transport-fails" do
    key = [:residual, "stale"]
    # expire the entry without dropping it → :miss on read, stale on fallback
    Cache.put(key, :warm, 1)
    Process.sleep(5)

    assert :warm =
             Cache.cached_get(key, 60_000, fn -> {:error, {:transport, :econnrefused}} end)
  end

  test "cached_get passes through non-transport errors and nil" do
    key = [:residual, "errs"]

    assert {:error, :validation} = Cache.cached_get(key, 60_000, fn -> {:error, :validation} end)
    assert nil == Cache.cached_get(key, 60_000, fn -> nil end)
    assert :fresh = Cache.cached_get(key, 60_000, fn -> :fresh end)
    assert :fresh = Cache.cached_get(key, 60_000, fn -> :other end)
  end

  # ── Config fallbacks ─────────────────────────────────────────────

  test "base_url strips a trailing slash on the env-var path" do
    Application.put_env(:noizu_prompt_lingua, :trp, base_url: nil, shared_key: "k")
    System.put_env("TRP_API_BASE_URL", "http://trp.test/")
    on_exit(fn -> System.delete_env("TRP_API_BASE_URL") end)

    assert Config.base_url() == "http://trp.test"
  end

  test "base_url tolerates a missing config entirely" do
    Application.put_env(:noizu_prompt_lingua, :trp, %{})
    System.delete_env("TRP_API_BASE_URL")
    assert Config.base_url() == nil
    refute Config.configured?()
  end

  test "env lookup tolerates a non-keyword :trp app env" do
    Application.put_env(:noizu_prompt_lingua, :trp, "junk")
    assert Config.base_url() == nil
    assert Config.shared_key() == nil
  end

  # ── Error envelope folds ─────────────────────────────────────────

  test "from_response folds unknown statuses and tolerates odd bodies" do
    err = Error.from_response(418, %{"error" => "teapot"})
    assert err.status == 418
    assert err.message == "teapot"

    # non-map body → fetch/2 nil → default message
    err2 = Error.from_response(503, "down")
    assert err2.status == 503

    # non-binary reason is ignored
    err3 = Error.from_response(500, %{"error" => "boom", "reason" => 42})
    assert err3.reason == nil
  end

  # ── Shapes: data_map key-style tolerance ─────────────────────────

  test "data payload maps keep user-defined keys string-keyed" do
    # atom-keyed inner keys (client-decode style) normalize to strings
    assert Shapes.item(%{custom_fields: %{severity: "high"}}).custom_fields ==
             %{"severity" => "high"}

    # already-string-keyed inner maps pass through untouched
    assert Shapes.item(%{custom_fields: %{"severity" => "low"}}).custom_fields ==
             %{"severity" => "low"}

    # non-map payloads pass through untouched
    assert Shapes.item(%{custom_fields: "junk"}).custom_fields == "junk"
    assert Shapes.item(%{custom_fields: nil}).custom_fields == %{}
    assert Shapes.field_definition(%{options: %{a: 1}}).options == %{"a" => 1}
    assert Shapes.type_definition(%{status_workflow: %{b: 2}}).status_workflow == %{"b" => 2}
  end

  # ── ServiceAuth: rotate + fallback ladder over the JWT stub ──────

  test "stale token rotates via refresh and stores the new access" do
    stale_at = System.system_time(:millisecond) - 51 * 60 * 1000

    :ets.insert(
      :noizu_trp_service_auth,
      {:auth, %{access: "jwt_stale", refresh: "r1", fetched_at: stale_at}}
    )

    assert {:ok, "jwt_access_refreshed"} = ServiceAuth.token()
  end

  test "refresh with an invalid body falls back to login" do
    JwtStub.set_refresh({200, %{"unexpected" => "shape"}})
    stale_at = System.system_time(:millisecond) - 51 * 60 * 1000

    :ets.insert(
      :noizu_trp_service_auth,
      {:auth, %{access: "jwt_stale", refresh: "r1", fetched_at: stale_at}}
    )

    assert {:ok, access} = ServiceAuth.token()
    assert access =~ "jwt_access_"
  end

  test "refresh rejection falls back to login" do
    JwtStub.set_refresh({401, %{"error" => "revoked"}})
    stale_at = System.system_time(:millisecond) - 51 * 60 * 1000

    :ets.insert(
      :noizu_trp_service_auth,
      {:auth, %{access: "jwt_stale", refresh: "r1", fetched_at: stale_at}}
    )

    assert {:ok, access} = ServiceAuth.token()
    assert access =~ "jwt_access_"
  end

  test "login with a token-less 200 is an invalid response" do
    JwtStub.set_login({200, %{"nope" => true}})

    assert {:error, :trp_service_login_invalid_response} = ServiceAuth.token()
  end

  test "401 mid-flight re-authenticates once and retries the request" do
    assert {:ok, _first} = ServiceAuth.token()

    # the authed request gets a 401 once → reset → fresh login → retry succeeds
    JwtStub.set_authed({401, %{"error" => "stale token"}})

    assert {:ok, %{ok: true}} = ServiceAuth.authed_request(:get, "/api/v1/me")
  end

  test "login failure on the JWT plane surfaces the transport error" do
    JwtStub.set_login({:transport, {:timeout, "boom"}})

    assert {:error, {:transport, {:timeout, "boom"}}} = ServiceAuth.token()
  end

  test "decode tolerates empty bodies on the JWT plane" do
    JwtStub.set_login({200, ""})

    assert {:error, :trp_service_login_invalid_response} = ServiceAuth.token()
  end
end

defmodule NoizuPromptLingua.TRP.JwtStub do
  @moduledoc "Scriptable JWT-plane transport for TRPResidualTest."
  @behaviour NoizuPromptLingua.TRP.Transport

  def reset do
    Process.put(:w4d_jwt_stub, %{login: nil, refresh: nil, authed: []})
    :ok
  end

  def set_login(resp), do: update(&%{&1 | login: resp})
  def set_refresh(resp), do: update(&%{&1 | refresh: resp})
  def set_authed(resp), do: update(&%{&1 | authed: &1.authed ++ [resp]})

  @impl true
  def request(:post, _base, "/api/v1/auth/login", _h, _body, _o) do
    scripted(& &1.login, fn ->
      {:ok, 200,
       %{
         "access_token" => "jwt_access_#{System.unique_integer([:positive])}",
         "refresh_token" => "jwt_refresh"
       }}
    end)
  end

  def request(:post, _base, "/api/v1/auth/refresh", _h, _body, _o) do
    scripted(& &1.refresh, fn ->
      {:ok, 200, %{"access_token" => "jwt_access_refreshed", "refresh_token" => "jwt_refresh2"}}
    end)
  end

  def request(_method, _base, _path, headers, _body, _opts) do
    auth = List.keyfind(headers, "authorization", 0) |> elem(1)

    if is_binary(auth) and String.starts_with?(auth, "Bearer jwt_access_") do
      case pop_authed() do
        nil -> {:ok, 200, %{"ok" => true}}
        {status, body} -> {:ok, status, body}
      end
    else
      {:ok, 401, %{"error" => "unauthorized"}}
    end
  end

  defp pop_authed do
    st = state()

    case st.authed do
      [next | rest] ->
        Process.put(:w4d_jwt_stub, %{st | authed: rest})
        next

      [] ->
        nil
    end
  end

  defp scripted(getter, default) do
    case getter.(state()) do
      nil -> default.()
      {status, body} when is_integer(status) -> {:ok, status, body}
      {:transport, reason} -> {:error, reason}
    end
  end

  defp update(fun) do
    Process.put(:w4d_jwt_stub, fun.(state()))
    :ok
  end

  # Fallback carries the FULL state shape: entities_residual_test triggers the
  # transport from its own process (no reset/0 ran there), and a stale two-key
  # fallback crashed pop_authed/0 on a missing :authed key. (merge round 2)
  defp state, do: Process.get(:w4d_jwt_stub) || %{login: nil, refresh: nil, authed: []}
end
