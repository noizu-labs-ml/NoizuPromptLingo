defmodule NoizuPromptLingua.Auth.SSO do
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema
  alias NoizuPromptLingua.Schema.Users.Credentials.UserCredential, as: CredentialSchema
  alias NoizuPromptLingua.Schema.Users.Sessions.UserSession, as: SessionSchema
  alias NoizuPromptLingua.Schema.Auth.Providers.Provider, as: ProviderSchema
  alias NoizuPromptLingua.Schema.Versioned.Names.Name
  import Ecto.Query, only: [from: 2]

  # Authentik is the only supported identity provider — no alternatives.
  @provider_map %{
    authentik: &NoizuPromptLingua.Auth.Providers.authentik/0
  }

  def authenticate_sso(:authentik = provider_type, attrs) do
    email = normalize_email(attrs[:email])
    provider_ref = unwrap_ref(@provider_map[provider_type].())
    provider_id = ensure_authentik_provider(provider_ref_id(provider_ref))
    fingerprint = sso_fingerprint(provider_type, attrs)

    # Identity is resolved by the linked credential (provider + external subject)
    # first; email is only a fallback for legacy/email-linked accounts.
    located =
      case find_user_by_credential(provider_id, fingerprint) do
        {:ok, user} -> {:ok, user}
        :not_found -> if email, do: find_user_by_email(email), else: :not_found
      end

    case located do
      {:ok, user} ->
        ensure_sso_credential(user, provider_id, provider_type, attrs)
        create_sso_session(user, provider_type)

      :not_found ->
        # No account yet. The SPA collects name/role/bio on a register form and
        # calls register_user/2 with this verified identity.
        {:registration_required,
         %{provider: to_string(provider_type), sub: sso_subject(attrs), email: email}}
    end
  end

  # No alternatives to Authentik.
  def authenticate_sso(_provider_type, _attrs), do: {:error, :unsupported_provider}

  # Auth.Providers.*/0 return Entity.ref/1 results, which may be wrapped as
  # {:ok, {:ref, module, uuid}}. Normalize to the bare {:ref, module, uuid}.
  defp unwrap_ref({:ok, ref}), do: ref
  defp unwrap_ref(ref), do: ref

  # provider_ref is a Noizu entity ref ({:ref, module, uuid}); extract the UUID.
  # Provider.id/1 returns :unsupported for a bare ref, so unwrap it directly.
  defp provider_ref_id({:ref, _module, id}), do: id
  defp provider_ref_id(id) when is_binary(id), do: id

  defp normalize_email(nil), do: nil

  defp normalize_email(email) when is_binary(email) do
    case email |> String.trim() |> String.downcase() do
      "" -> nil
      e -> e
    end
  end

  defp find_user_by_credential(provider_id, fingerprint) do
    q =
      from c in CredentialSchema,
        join: u in UserSchema,
        on: u.id == c.user_id,
        where: c.auth_provider_id == ^provider_id,
        where: c.fingerprint == ^fingerprint,
        where: c.status == :active,
        where: u.status == :active,
        select: u,
        limit: 1

    case NoizuPromptLingua.Repo.one(q) do
      nil -> :not_found
      user -> {:ok, user}
    end
  end

  defp find_user_by_email(email) do
    q =
      from u in UserSchema,
        where: u.email == ^email,
        where: u.status != :deleted,
        limit: 1

    case NoizuPromptLingua.Repo.one(q) do
      nil -> :not_found
      user -> {:ok, user}
    end
  end

  # Seeds are skipped in some deploys; the credential FK still needs the row.
  defp ensure_authentik_provider(provider_id) when is_binary(provider_id) do
    unless NoizuPromptLingua.Repo.get(ProviderSchema, provider_id) do
      NoizuPromptLingua.Repo.insert!(
        %ProviderSchema{
          id: provider_id,
          title: "Authentik",
          description: "Authentik OIDC SSO"
        },
        on_conflict: :nothing,
        conflict_target: :id
      )
    end

    provider_id
  end

  # Raw-insert the SSO credential if the user doesn't already have an active one
  # for this provider. (The entity layer's create/3 expects attrs, not a struct.)
  defp ensure_sso_credential(user, provider_id, provider_type, attrs) do
    fingerprint = sso_fingerprint(provider_type, attrs)

    exists =
      from(c in CredentialSchema,
        where: c.user_id == ^user.id,
        where: c.auth_provider_id == ^provider_id,
        where: c.status == :active,
        limit: 1
      )
      |> NoizuPromptLingua.Repo.one()

    if is_nil(exists) do
      NoizuPromptLingua.Repo.insert!(%CredentialSchema{
        user_id: user.id,
        auth_provider_id: provider_id,
        status: :active,
        settings: sso_settings(provider_type, attrs),
        state: %{},
        fingerprint: fingerprint
      })
    end

    :ok
  end

  # Returns {:ok, session}. The session carries a one-time claim_code that the
  # controller puts in the redirect; the SPA exchanges it via claim_session/1.
  defp create_sso_session(user, provider_type) do
    claim_code = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    expires = DateTime.utc_now() |> DateTime.add(60, :second)

    NoizuPromptLingua.Repo.insert(%SessionSchema{
      user_id: user.id,
      status: :active,
      details: %{auth_method: to_string(provider_type)},
      claim_code: claim_code,
      claim_code_expires_at: expires
    })
  end

  @doc """
  Atomically claim a session by its one-time code (single-use). The UPDATE
  matches on claim_code and clears it in the same statement, so concurrent
  (e.g. StrictMode-doubled) calls can't both succeed.
  """
  def claim_session(claim_code) when is_binary(claim_code) do
    now = DateTime.utc_now()

    {count, rows} =
      from(s in SessionSchema,
        where: s.claim_code == ^claim_code,
        where: s.status == :active,
        where: s.claim_code_expires_at > ^now,
        select: s
      )
      |> NoizuPromptLingua.Repo.update_all(set: [claim_code: nil])

    case {count, rows} do
      {1, [session]} -> {:ok, session}
      _ -> {:error, :invalid_code}
    end
  end

  def claim_session(_), do: {:error, :invalid_code}

  @doc """
  Create an account from a verified SSO identity plus the register form's
  name/role/bio, link the SSO credential, and start a session.
  `identity` is the (string-keyed) map produced by authenticate_sso/registration token.
  """
  def register_user(%{provider: provider, sub: sub} = identity, attrs)
      when provider in ["authentik"] do
    provider_type = String.to_existing_atom(provider)
    provider_ref = unwrap_ref(@provider_map[provider_type].())
    provider_id = ensure_authentik_provider(provider_ref_id(provider_ref))
    email = normalize_email(identity[:email])
    handle = derive_handle(email, %{sub: sub})
    sso_attrs = %{sub: sub, email: email}

    name =
      NoizuPromptLingua.Repo.insert!(%Name{
        first: attrs[:first] || "",
        last: attrs[:last] || "",
        middle: attrs[:middle] || []
      })

    {:ok, inserted} =
      NoizuPromptLingua.Repo.insert(
        %UserSchema{
          user_name: handle,
          handle: handle,
          name_id: name.id,
          email: email,
          role: normalize_role(attrs[:role]),
          bio: attrs[:bio],
          status: :active,
          verified: true,
          flagged: false
        },
        on_conflict: :nothing,
        conflict_target: :email
      )

    user =
      cond do
        is_binary(inserted.id) -> inserted
        is_binary(email) -> NoizuPromptLingua.Repo.get_by!(UserSchema, email: email)
        true -> inserted
      end

    ensure_sso_credential(user, provider_id, provider_type, sso_attrs)
    create_sso_session(user, provider_type)
  end

  def register_user(_identity, _attrs), do: {:error, :unsupported_provider}

  @roles ~w(user moderator admin owner service other)
  defp normalize_role(role) when is_atom(role), do: normalize_role(Atom.to_string(role))
  defp normalize_role(role) when role in @roles, do: String.to_existing_atom(role)
  defp normalize_role(_), do: :user

  defp sso_settings(:saml, attrs), do: %{email: attrs[:email], name_id: attrs[:name_id]}

  defp sso_settings(_provider_type, attrs),
    do: %{email: attrs[:email], sub: attrs[:sub] || attrs[:uid]}

  defp sso_fingerprint(:saml, attrs), do: "saml:#{attrs[:name_id]}"
  defp sso_fingerprint(provider_type, attrs), do: "#{provider_type}:#{attrs[:sub] || attrs[:uid]}"

  defp sso_subject(attrs), do: attrs[:sub] || attrs[:uid] || attrs[:name_id]

  defp derive_handle(email, _attrs) when is_binary(email) do
    email |> String.split("@") |> hd() |> String.downcase() |> String.replace(~r/[^a-z0-9_]/, "_")
  end

  defp derive_handle(_email, attrs) do
    sub = sso_subject(attrs) || UUID.uuid4()

    "user_" <>
      (sub
       |> to_string()
       |> String.downcase()
       |> String.replace(~r/[^a-z0-9_]/, "_")
       |> String.slice(0, 24))
  end
end
