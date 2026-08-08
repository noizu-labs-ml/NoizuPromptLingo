defmodule NoizuPromptLingua.Auth.RegistrationToken do
  @moduledoc """
  Stateless, short-lived token carrying a *verified* SSO identity
  (provider/sub/email) from the OIDC callback to the register form.
  Signed with the endpoint's secret_key_base (Phoenix.Token) — no Redis.
  """
  @salt "sso_registration"
  @max_age_seconds 600

  defp endpoint, do: NoizuPromptLinguaWeb.Endpoint

  def sign(identity) when is_map(identity) do
    Phoenix.Token.sign(endpoint(), @salt, identity)
  end

  def verify(token) when is_binary(token) do
    Phoenix.Token.verify(endpoint(), @salt, token, max_age: @max_age_seconds)
  end

  def verify(_), do: {:error, :invalid}
end
