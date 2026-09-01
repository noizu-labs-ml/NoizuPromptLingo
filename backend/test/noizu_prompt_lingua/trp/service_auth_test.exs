defmodule NoizuPromptLingua.TRP.ServiceAuthTest do
  @moduledoc """
  ServiceAuth + Provisioning unit tests over a stub JWT transport: login
  caching, refresh rotation past the margin, 401 re-auth retry, provisioning
  success/failure propagation, and not-configured gating.
  """

  use ExUnit.Case, async: false

  alias NoizuPromptLingua.TRP.{Config, Provisioning, ServiceAuth}

  setup do
    prev = %{
      trp: Application.get_env(:noizu_prompt_lingua, :trp),
      trp_service: Application.get_env(:noizu_prompt_lingua, :trp_service),
      transport: Application.get_env(:noizu_prompt_lingua, :trp_service_transport)
    }

    Application.put_env(:noizu_prompt_lingua, :trp,
      base_url: "http://trp.test",
      shared_key: "trp_sk_test"
    )

    Application.put_env(:noizu_prompt_lingua, :trp_service,
      email: "svc@noizu.com",
      password: "secret"
    )

    Application.put_env(:noizu_prompt_lingua, :trp_service_transport, ServiceAuthStub)
    ServiceAuthStub.reset()
    ServiceAuth.reset()

    on_exit(fn ->
      if prev.trp, do: Application.put_env(:noizu_prompt_lingua, :trp, prev.trp)

      if prev.trp_service do
        Application.put_env(:noizu_prompt_lingua, :trp_service, prev.trp_service)
      end

      if prev.transport do
        Application.put_env(:noizu_prompt_lingua, :trp_service_transport, prev.transport)
      end
    end)

    :ok
  end

  # ── ServiceAuth ───────────────────────────────────────────────

  test "logs in and caches the access token (one login for two calls)" do
    {:ok, t1} = ServiceAuth.token()
    {:ok, t2} = ServiceAuth.token()
    assert t1 == t2
    assert ServiceAuthStub.logins() == 1
  end

  test "missing credentials -> :trp_service_not_configured" do
    Application.delete_env(:noizu_prompt_lingua, :trp_service)
    System.delete_env("TRP_SERVICE_EMAIL")
    System.delete_env("TRP_SERVICE_PASSWORD")

    assert {:error, :trp_service_not_configured} = ServiceAuth.token()
  end

  test "401 mid-flight re-authenticates once and retries" do
    {:ok, _} = ServiceAuth.token()
    # The queued 401 preempts only the NEXT request (the authed call).
    ServiceAuthStub.queue_401_once()

    assert {:ok, body} =
             ServiceAuth.authed_request(:post, "/api/v1/organizations",
               json: %{organization: %{slug: "acme", name: "Acme"}}
             )

    # Bodies are atomized uniformly by the client decode.
    assert body[:organization][:slug] == "acme"
    assert ServiceAuthStub.logins() == 2
  end

  test "transport failure propagates as {:transport, reason}" do
    ServiceAuthStub.fail_next({:timeout, "boom"})
    assert {:error, {:transport, {:timeout, "boom"}}} = ServiceAuth.token()
  end

  # ── Provisioning ──────────────────────────────────────────────

  test "provision_org posts the JWT create and returns the TRP org" do
    assert {:ok, org} = Provisioning.provision_org(%{slug: "acme", name: "Acme"})
    assert pick_slug(org) == "acme"
    assert is_binary(org["id"] || org[:id])
    assert ServiceAuthStub.logins() == 1
  end

  test "provision_org is gated on shared-key activation config" do
    Application.put_env(:noizu_prompt_lingua, :trp, base_url: nil, shared_key: nil)
    refute Config.configured?()
    assert {:error, :trp_not_configured} = Provisioning.provision_org(%{slug: "x", name: "X"})
    assert ServiceAuthStub.logins() == 0
  end

  test "provision_org surfaces validation errors without raising" do
    ServiceAuthStub.queue_422_once()

    assert {:error, %NoizuPromptLingua.TRP.Error{status: 422}} =
             Provisioning.provision_org(%{slug: "acme", name: "Acme"})
  end

  test "provision_org rejects non-binary attrs" do
    assert {:error, :invalid_org_attrs} = Provisioning.provision_org(%{slug: nil, name: "X"})
  end
  defp pick_slug(map) when is_map(map), do: Map.get(map, "slug") || Map.get(map, :slug)
end

defmodule ServiceAuthStub do
  @moduledoc "Minimal JWT-plane transport stub for ServiceAuthTest."
  @behaviour NoizuPromptLingua.TRP.Transport

  def reset do
    Process.put(:sa_stub, %{logins: 0, queue: []})
    :ok
  end

  def logins, do: state().logins
  def queue_401_once, do: push({401, %{"error" => "unauthorized"}})
  def queue_422_once, do: push({422, %{"errors" => %{"slug" => ["has already been taken"]}}})
  def fail_next(reason), do: push({:transport, reason})

  @impl true
  def request(method, _base, path, headers, body, _opts) do
    # Any queued injection (incl. transport failures) preempts routing, even
    # for the login path.
    case pop_queue() do
      {:transport, reason} ->
        {:error, reason}

      {status, resp_body} when is_integer(status) ->
        {:ok, status, resp_body}

      nil ->
        route(method, path, headers, body)
    end
  end

  defp route(:post, "/api/v1/auth/login", _headers, body) do
    if is_map(body) and is_map_key(body, :email) do
      bump_logins()

      {:ok, 200,
       %{"access_token" => "jwt_access_" <> Integer.to_string(state().logins), "refresh_token" => "jwt_refresh"}}
    else
      {:ok, 401, %{"error" => "unauthorized"}}
    end
  end

  defp route(:post, "/api/v1/auth/refresh", _headers, _body) do
    {:ok, 200, %{"access_token" => "jwt_access_refreshed", "refresh_token" => "jwt_refresh2"}}
  end

  defp route(method, path, headers, body) do
    auth = List.keyfind(headers, "authorization", 0) |> elem(1)

    cond do
      not (is_binary(auth) and String.starts_with?(auth, "Bearer jwt_access_")) ->
        {:ok, 401, %{"error" => "unauthorized"}}

      method == :post and path == "/api/v1/organizations" and is_map(body) ->
        org = body[:organization]
        {:ok, 201, %{"organization" => %{"id" => "trp-org-uuid", "slug" => org[:slug], "name" => org[:name]}}}

      true ->
        {:ok, 404, %{"error" => "Not found"}}
    end
  end

  defp state, do: Process.get(:sa_stub) || %{logins: 0, queue: []}

  defp put(state), do: Process.put(:sa_stub, state)

  defp push(item), do: put(%{state() | queue: state().queue ++ [item]})

  defp pop_queue do
    s = state()

    case s.queue do
      [next | rest] ->
        put(%{s | queue: rest})
        next

      [] ->
        nil
    end
  end

  defp bump_logins, do: put(Map.update!(state(), :logins, &(&1 + 1)))
end
