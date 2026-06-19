defmodule NoizuPromptLingua.Auth.SSO do
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema
  alias NoizuPromptLingua.Schema.Users.Credentials.UserCredential, as: CredentialSchema
  alias NoizuPromptLingua.Schema.Versioned.Names.Name
  import Ecto.Query, only: [from: 2]

  # Authentik is the only supported identity provider — no alternatives.
  @provider_map %{
    authentik: &NoizuPromptLingua.Auth.Providers.authentik/0
  }

  def authenticate_sso(:authentik = provider_type, attrs) do
    context = Noizu.Context.system()
    email = normalize_email(attrs[:email])
    provider_ref = @provider_map[provider_type].()
    {:ok, provider_id} = NoizuPromptLingua.Auth.Providers.Provider.id(provider_ref)
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
        ensure_sso_credential(user, provider_ref, provider_id, provider_type, attrs, context)
        create_sso_session(user, provider_type, context)

      :not_found ->
        if Application.get_env(:noizu_prompt_lingua, :sso_require_invite, false) do
          {:error, :user_not_provisioned}
        else
          auto_provision_user(email, attrs, provider_ref, provider_id, provider_type, context)
        end
    end
  end

  # No alternatives to Authentik.
  def authenticate_sso(_provider_type, _attrs), do: {:error, :unsupported_provider}

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
    q = from u in UserSchema, where: u.email == ^email, where: u.status == :active, limit: 1

    case NoizuPromptLingua.Repo.one(q) do
      nil -> :not_found
      user -> {:ok, user}
    end
  end

  defp ensure_sso_credential(user, provider_ref, provider_id, provider_type, attrs, context) do
    fingerprint = sso_fingerprint(provider_type, attrs)

    q =
      from c in CredentialSchema,
        where: c.user_id == ^user.id,
        where: c.auth_provider_id == ^provider_id,
        where: c.status == :active,
        limit: 1

    case NoizuPromptLingua.Repo.one(q) do
      nil ->
        %NoizuPromptLingua.Users.Credentials.UserCredential{
          user: NoizuPromptLingua.Users.User.ref(user.id),
          auth_provider: provider_ref,
          status: :active,
          settings: sso_settings(provider_type, attrs),
          state: %{},
          fingerprint: fingerprint,
          time_stamp: Noizu.Entity.TimeStamp.now()
        }
        |> NoizuPromptLingua.EntityRepo.create(context)

      _existing ->
        :ok
    end
  end

  defp create_sso_session(user, provider_type, context) do
    user_ref = NoizuPromptLingua.Users.User.ref(user.id)

    %NoizuPromptLingua.Users.Sessions.UserSession{
      user: user_ref,
      status: :active,
      details: %{auth_method: to_string(provider_type)},
      time_stamp: Noizu.Entity.TimeStamp.now()
    }
    |> NoizuPromptLingua.EntityRepo.create(context)
  end

  defp auto_provision_user(email, attrs, provider_ref, provider_id, provider_type, context) do
    name_attrs = attrs[:name] || %{}
    first = name_attrs[:first] || ""
    last = name_attrs[:last] || ""
    handle = derive_handle(email, attrs)

    {:ok, name} =
      NoizuPromptLingua.EntityRepo.create(
        %NoizuPromptLingua.Versioned.Names.Name{first: first, last: last, time_stamp: Noizu.Entity.TimeStamp.now()},
        context
      )

    {:ok, name_ref} = Noizu.EntityReference.Protocol.ref(name)

    user_schema = %UserSchema{
      id: UUID.uuid4(),
      user_name: handle,
      handle: handle,
      name_id: name.id,
      email: email,
      status: :active,
      verified: true,
      flagged: false
    }

    {:ok, user} = NoizuPromptLingua.Repo.insert(user_schema, on_conflict: :nothing, conflict_target: :email)

    %NoizuPromptLingua.Users.Credentials.UserCredential{
      user: NoizuPromptLingua.Users.User.ref(user.id),
      auth_provider: provider_ref,
      status: :active,
      settings: sso_settings(provider_type, attrs),
      state: %{},
      fingerprint: sso_fingerprint(provider_type, attrs),
      time_stamp: Noizu.Entity.TimeStamp.now()
    }
    |> NoizuPromptLingua.EntityRepo.create(context)

    create_sso_session(user, provider_type, context)
  end

  defp sso_settings(:saml, attrs), do: %{email: attrs[:email], name_id: attrs[:name_id]}
  defp sso_settings(_provider_type, attrs), do: %{email: attrs[:email], sub: attrs[:sub] || attrs[:uid]}

  defp sso_fingerprint(:saml, attrs), do: "saml:#{attrs[:name_id]}"
  defp sso_fingerprint(provider_type, attrs), do: "#{provider_type}:#{attrs[:sub] || attrs[:uid]}"

  defp sso_subject(attrs), do: attrs[:sub] || attrs[:uid] || attrs[:name_id]

  defp derive_handle(email, _attrs) when is_binary(email) do
    email |> String.split("@") |> hd() |> String.downcase() |> String.replace(~r/[^a-z0-9_]/, "_")
  end

  defp derive_handle(_email, attrs) do
    sub = sso_subject(attrs) || UUID.uuid4()
    "user_" <> (sub |> to_string() |> String.downcase() |> String.replace(~r/[^a-z0-9_]/, "_") |> String.slice(0, 24))
  end
end
