defmodule NoizuPromptLingua.OAuth.Pkce do
  @moduledoc "PKCE S256 helpers (RFC 7636)."

  @doc "Verify code_verifier against S256 code_challenge."
  def verify_s256(verifier, challenge)
      when is_binary(verifier) and is_binary(challenge) and verifier != "" do
    expected =
      :crypto.hash(:sha256, verifier)
      |> Base.url_encode64(padding: false)

    if Plug.Crypto.secure_compare(expected, challenge), do: :ok, else: {:error, :invalid_grant}
  end

  def verify_s256(_, _), do: {:error, :invalid_grant}

  @doc "Validate code_challenge shape for authorize requests."
  def valid_challenge?("S256", challenge) when is_binary(challenge) do
    # BASE64URL-encoded SHA256 is 43 chars without padding.
    byte_size(challenge) in 43..128
  end

  def valid_challenge?(_, _), do: false
end
