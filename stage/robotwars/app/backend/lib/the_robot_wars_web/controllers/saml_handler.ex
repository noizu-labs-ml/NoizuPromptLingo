defmodule TheRobotWarsWeb.SAMLHandler do
  @behaviour Samly.PipelineHandler

  alias TheRobotWars.Auth.SSO
  alias TheRobotWars.Auth.SSOCode

  @impl true
  def handle_signin_request(conn, _opts), do: conn

  @impl true
  def handle_signout_request(conn, _opts), do: conn

  @impl true
  def handle_signout_response(conn, _opts), do: conn

  @impl true
  def handle_signin_response(conn, _opts) do
    assertion = conn.private[:samly_assertion]
    frontend_url = Application.get_env(:the_robot_wars, :frontend_url, "http://localhost:3000")

    attrs = %{
      email: get_attribute(assertion, "email") || get_attribute(assertion, "urn:oid:0.9.2342.19200300.100.1.3"),
      name: get_attribute(assertion, "displayName") || get_attribute(assertion, "urn:oid:2.16.840.1.113730.3.1.241"),
      first_name: get_attribute(assertion, "firstName") || get_attribute(assertion, "urn:oid:2.5.4.42"),
      last_name: get_attribute(assertion, "lastName") || get_attribute(assertion, "urn:oid:2.5.4.4"),
      name_id: assertion.name_id,
      sub: assertion.name_id
    }

    case SSO.authenticate_sso(:saml, attrs) do
      {:ok, session} ->
        {:ok, code} = SSOCode.create(session.id)
        redirect_url = "#{frontend_url}/auth/sso-callback?code=#{code}&provider=saml"
        Phoenix.Controller.redirect(conn, external: redirect_url)

      {:error, :user_not_provisioned} ->
        redirect_url = "#{frontend_url}/auth/sso-callback?error=not_provisioned"
        Phoenix.Controller.redirect(conn, external: redirect_url)

      {:error, _reason} ->
        redirect_url = "#{frontend_url}/auth/sso-callback?error=auth_failed"
        Phoenix.Controller.redirect(conn, external: redirect_url)
    end
  end

  defp get_attribute(%{attributes: attributes}, name) do
    case Map.get(attributes, name) do
      nil -> nil
      value when is_binary(value) -> value
      [value | _] -> value
      _ -> nil
    end
  end
end
