defmodule Codefresh.Fixtures do
  @moduledoc "Test helpers for building users, orgs, memberships, tokens."

  alias Codefresh.{Accounts, Organizations, ApiTokens, Guardian}

  def user_fixture(attrs \\ %{}) do
    defaults = %{
      "email" => "user-#{System.unique_integer([:positive])}@test.local",
      "password" => "testpassword123"
    }

    {:ok, user} =
      defaults
      |> Map.merge(stringify(attrs))
      |> Accounts.register_user()

    user
  end

  def org_fixture(attrs \\ %{}) do
    n = System.unique_integer([:positive])

    defaults = %{
      "slug" => "org-#{n}",
      "name" => "Org #{n}"
    }

    {:ok, org} =
      defaults
      |> Map.merge(stringify(attrs))
      |> Organizations.create_organization()

    org
  end

  def membership_fixture(user, org, role \\ "owner") do
    {:ok, m} =
      Accounts.create_membership(%{
        organization_id: org.id,
        user_id: user.id,
        role: role
      })

    m
  end

  def org_with_owner(attrs \\ %{}) do
    n = System.unique_integer([:positive])

    defaults = %{
      "slug" => "org-#{n}",
      "name" => "Org #{n}"
    }

    user = user_fixture()
    merged = Map.merge(defaults, stringify(attrs))

    {:ok, %{organization: org}} =
      Organizations.create_organization_with_owner(merged, user)

    %{user: user, organization: org}
  end

  def auth_conn(conn, user) do
    {:ok, token, _} = Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {1, :hour})
    Plug.Conn.put_req_header(conn, "authorization", "Bearer " <> token)
  end

  def api_token_fixture(org, user, attrs \\ %{}) do
    defaults = %{
      name: "token-#{System.unique_integer([:positive])}",
      role: "editor",
      organization_id: org.id,
      created_by_user_id: user.id
    }

    {:ok, token, raw} = ApiTokens.create_token(Map.merge(defaults, attrs))
    {token, raw}
  end

  defp stringify(m) do
    for {k, v} <- m, into: %{}, do: {to_string(k), v}
  end
end
