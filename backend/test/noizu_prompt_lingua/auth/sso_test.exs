defmodule NoizuPromptLingua.Auth.SSOTest do
  @moduledoc """
  `NoizuPromptLingua.Auth.SSO` — Authentik-only SSO plumbing:

  * `authenticate_sso/2` — credential-first identity resolution
    (provider + fingerprint), email fallback for legacy/linking accounts,
    deleted/inactive filtering, `registration_required` payload shape,
    unsupported-provider rejection.
  * `claim_session/1` — single-use atomic claim (reuse / expiry / garbage).
  * `register_user/2` — account creation from a verified identity, handle
    derivation (email local-part sanitised, sub fallback, uuid fallback),
    role normalisation, email-conflict reclaim via the existing row.

  Security posture (pinned, see coverage report):

    * F5 — email fallback trusts the IdP-asserted email to link into any
      non-deleted account (standard SSO email-trust surface; Authentik is
      the verification boundary here). Pinned as current behavior.
  """

  use NoizuPromptLingua.DataCase, async: false

  import Ecto.Query, only: [from: 2]

  alias NoizuPromptLingua.Auth.SSO
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.Credentials.UserCredential, as: CredentialSchema
  alias NoizuPromptLingua.Schema.Users.Sessions.UserSession, as: SessionSchema
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema

  setup do
    uniq = System.unique_integer([:positive])

    user =
      %UserSchema{
        id: Ecto.UUID.generate(),
        email: "sso-#{uniq}@example.com",
        user_name: "sso#{uniq}",
        handle: "sso#{uniq}",
        status: :active,
        verified: true,
        flagged: false
      }
      |> Repo.insert!()

    %{user: user, uniq: uniq}
  end

  defp credential_count(user_id) do
    from(c in CredentialSchema, where: c.user_id == ^user_id)
    |> Repo.aggregate(:count, :id)
  end

  defp active_credential(user_id) do
    from(c in CredentialSchema,
      where: c.user_id == ^user_id and c.status == :active
    )
    |> Repo.one()
  end

  # ── authenticate_sso: no account yet ──────────────────────────────────────

  test "unknown identity → registration_required with normalized payload" do
    assert {:registration_required, payload} =
             SSO.authenticate_sso(:authentik, %{email: "  New.User@Example.COM ", sub: "s-1"})

    assert payload == %{provider: "authentik", sub: "s-1", email: "new.user@example.com"}
  end

  test "blank email normalizes to nil" do
    assert {:registration_required, payload} =
             SSO.authenticate_sso(:authentik, %{email: "   ", sub: "s-1"})

    assert payload.email == nil
  end

  test "uid fallback feeds sub/email payload when sub absent" do
    assert {:registration_required, payload} =
             SSO.authenticate_sso(:authentik, %{uid: "u-9"})

    assert payload == %{provider: "authentik", sub: "u-9", email: nil}
  end

  test "unsupported provider types are rejected" do
    assert SSO.authenticate_sso(:saml, %{sub: "x"}) == {:error, :unsupported_provider}
    assert SSO.authenticate_sso("authentik", %{sub: "x"}) == {:error, :unsupported_provider}
    assert SSO.authenticate_sso(:google, %{sub: "x"}) == {:error, :unsupported_provider}
  end

  # ── authenticate_sso: email fallback creates the linked credential ────────

  test "email fallback signs in the legacy account and links the SSO credential", %{
    user: user
  } do
    assert {:ok, session} =
             SSO.authenticate_sso(:authentik, %{email: user.email, sub: "s-first"})

    assert session.user_id == user.id
    assert session.status == :active
    assert session.details == %{auth_method: "authentik"}

    cred = active_credential(user.id)
    assert cred.fingerprint == "authentik:s-first"
    assert cred.settings["email"] == user.email
    assert cred.settings["sub"] == "s-first"
  end

  test "credential-first lookup wins over an email mismatch, and never duplicates", %{
    uniq: uniq
  } do
    # Two accounts; the credential belongs to A. The IdP asserts B's email
    # together with A's subject — credential-first must resolve to A.
    user_a =
      %UserSchema{
        id: Ecto.UUID.generate(),
        email: "cred-a-#{uniq}@example.com",
        user_name: "credA#{uniq}",
        handle: "credA#{uniq}",
        status: :active,
        verified: true,
        flagged: false
      }
      |> Repo.insert!()

    user_b =
      %UserSchema{
        id: Ecto.UUID.generate(),
        email: "cred-b-#{uniq}@example.com",
        user_name: "credB#{uniq}",
        handle: "credB#{uniq}",
        status: :active,
        verified: true,
        flagged: false
      }
      |> Repo.insert!()

    # Link the credential to A via a consistent first login.
    assert {:ok, first} =
             SSO.authenticate_sso(:authentik, %{email: user_a.email, sub: "s-A"})

    assert first.user_id == user_a.id

    # Second login: same subject, but the assertion now carries B's email.
    # The credential (authentik:s-A) must win before email is consulted.
    assert {:ok, second} =
             SSO.authenticate_sso(:authentik, %{email: user_b.email, sub: "s-A"})

    assert second.user_id == user_a.id
    assert credential_count(user_a.id) == 1
    assert credential_count(user_b.id) == 0
  end

  # F6 (BUG, pinned): a disabled credential row for the same provider +
  # fingerprint makes login crash with an Ecto.ConstraintError — the active
  # credential lookup misses, the email fallback hits, then
  # ensure_sso_credential/4 inserts a duplicate fingerprint and violates
  # uq_user_credentials_provider_fingerprint → 500. Correct replacement
  # behavior (reject vs. ignore vs. re-activate) is a policy decision, so
  # this pins the current crash; update when fixed.
  test "F6 BUG PIN: disabled credential for the same fingerprint crashes login", %{
    user: user
  } do
    assert {:ok, _} = SSO.authenticate_sso(:authentik, %{email: user.email, sub: "s-x"})
    cred = active_credential(user.id)

    cred
    |> Ecto.Changeset.change(status: :disabled)
    |> Repo.update!()

    assert_raise Ecto.ConstraintError, ~r/user_credentials/, fn ->
      SSO.authenticate_sso(:authentik, %{email: user.email, sub: "s-x"})
    end
  end

  test "deleted accounts are invisible to both lookup paths", %{uniq: uniq} do
    email = "gone-#{uniq}@example.com"

    %UserSchema{
      id: Ecto.UUID.generate(),
      email: email,
      user_name: "gone#{uniq}",
      handle: "gone#{uniq}",
      status: :deleted,
      verified: true,
      flagged: false
    }
    |> Repo.insert!()

    assert {:registration_required, %{email: ^email}} =
             SSO.authenticate_sso(:authentik, %{email: email, sub: "s-gone"})
  end

  # F5 (pinned): an IdP-asserted email links into any matching non-deleted
  # account — Authentik is the email-verification boundary.
  test "F5 PIN: email fallback claims an account whose email matches the IdP assertion", %{
    user: user
  } do
    assert {:ok, session} =
             SSO.authenticate_sso(:authentik, %{email: user.email, sub: "s-attacker"})

    assert session.user_id == user.id
  end

  # ── register_user ─────────────────────────────────────────────────────────

  test "register creates the account, name, credential and session" do
    identity = %{provider: "authentik", sub: "s-reg", email: "alice@example.com"}

    assert {:ok, session} =
             SSO.register_user(identity, %{
               first: "Alice",
               last: "Smith",
               role: "admin",
               bio: "hi"
             })

    assert session.status == :active
    assert is_binary(session.claim_code)
    assert byte_size(session.claim_code) == 43

    user = Repo.get_by!(UserSchema, email: "alice@example.com")
    assert user.handle == "alice"
    assert user.user_name == "alice"
    assert user.role == :admin
    assert user.bio == "hi"
    assert user.verified == true
    assert user.name_id

    name = Repo.get!(NoizuPromptLingua.Schema.Versioned.Names.Name, user.name_id)
    assert name.first == "Alice"
    assert name.last == "Smith"

    cred = active_credential(user.id)
    assert cred.fingerprint == "authentik:s-reg"
  end

  test "claim_code expires in ~5 minutes and authenticates right after registering" do
    identity = %{provider: "authentik", sub: "s-reg2", email: "bob@example.com"}
    assert {:ok, session} = SSO.register_user(identity, %{})

    delta = DateTime.diff(session.claim_code_expires_at, DateTime.utc_now(), :second)
    assert delta in 240..300

    assert {:ok, session2} =
             SSO.authenticate_sso(:authentik, %{email: "bob@example.com", sub: "s-reg2"})

    assert session2.user_id == session.user_id
  end

  test "handle derives from the sanitized email local-part" do
    identity = %{provider: "authentik", sub: "s-h", email: "Alice.Smith+tag@Example.com"}

    assert {:ok, _} = SSO.register_user(identity, %{})

    user = Repo.get_by!(UserSchema, email: "alice.smith+tag@example.com")
    assert user.handle == "alice_smith_tag"
  end

  test "no email → handle falls back to the sanitized sub" do
    assert {:ok, _} = SSO.register_user(%{provider: "authentik", sub: "Sub.Weird-Value"}, %{})

    users =
      from(u in UserSchema, where: like(u.handle, "user_sub%"))
      |> Repo.all()

    assert [user] = users
    assert user.handle == "user_sub_weird_value"
    assert user.email == nil
  end

  test "no email and no sub → handle falls back to a generated suffix" do
    assert {:ok, _} = SSO.register_user(%{provider: "authentik", sub: nil}, %{})

    handles =
      from(u in UserSchema, where: like(u.handle, "user_%"), select: u.handle)
      |> Repo.all()

    assert [handle] = handles
    assert String.starts_with?(handle, "user_")
    assert byte_size(handle) <= 30
  end

  test "role normalization: atoms pass through, junk defaults to :user" do
    assert {:ok, s1} =
             SSO.register_user(%{provider: "authentik", sub: "s-r1", email: "r1@example.com"}, %{
               role: :moderator
             })

    assert Repo.get!(UserSchema, s1.user_id).role == :moderator

    assert {:ok, s2} =
             SSO.register_user(%{provider: "authentik", sub: "s-r2", email: "r2@example.com"}, %{
               role: "superuser"
             })

    assert Repo.get!(UserSchema, s2.user_id).role == :user

    assert {:ok, s3} =
             SSO.register_user(
               %{provider: "authentik", sub: "s-r3", email: "r3@example.com"},
               %{}
             )

    assert Repo.get!(UserSchema, s3.user_id).role == :user
  end

  test "re-registration with an already-claimed email reuses the existing row", %{
    uniq: uniq
  } do
    email = "taken-#{uniq}@example.com"

    # Pre-existing account whose handle differs from the would-be derived one
    # (the deterministic local-part would otherwise collide on the separate
    # handle unique index — see coverage report F4).
    existing =
      %UserSchema{
        id: Ecto.UUID.generate(),
        email: email,
        user_name: "taken#{uniq}",
        handle: "taken#{uniq}",
        status: :active,
        verified: false,
        flagged: false
      }
      |> Repo.insert!()

    assert {:ok, session} =
             SSO.register_user(%{provider: "authentik", sub: "s-2nd", email: email}, %{
               first: "Again"
             })

    assert session.user_id == existing.id

    assert Repo.one(from(u in UserSchema, where: u.email == ^email, select: count(u.id))) == 1
    cred = active_credential(existing.id)
    assert cred.fingerprint == "authentik:s-2nd"
  end

  test "unsupported registration identities are rejected" do
    assert SSO.register_user(%{provider: "google", sub: "x"}, %{}) ==
             {:error, :unsupported_provider}

    # missing sub key → no head-clause match
    assert SSO.register_user(%{provider: "authentik"}, %{}) ==
             {:error, :unsupported_provider}

    assert SSO.register_user(%{"provider" => "authentik"}, %{}) ==
             {:error, :unsupported_provider}
  end

  # ── claim_session ─────────────────────────────────────────────────────────

  defp seed_session(user_id, code, expires_at) do
    %SessionSchema{
      user_id: user_id,
      status: :active,
      details: %{},
      claim_code: code,
      claim_code_expires_at: expires_at
    }
    |> Repo.insert!()
  end

  test "claim_session is single-use: first claim wins, replay is rejected", %{user: user} do
    assert {:ok, seeded} = SSO.authenticate_sso(:authentik, %{email: user.email, sub: "s-claim"})
    code = seeded.claim_code

    assert {:ok, claimed} = SSO.claim_session(code)
    assert claimed.id == seeded.id
    assert claimed.claim_code == nil

    # Cleared in the store, not just the returned struct.
    assert Repo.get!(SessionSchema, seeded.id).claim_code == nil

    assert SSO.claim_session(code) == {:error, :invalid_code}
  end

  test "claim_session rejects unknown, expired and non-binary codes", %{user: user} do
    assert SSO.claim_session("no-such-code") == {:error, :invalid_code}

    seed_session(user.id, "expired-code", DateTime.add(DateTime.utc_now(), -60, :second))
    assert SSO.claim_session("expired-code") == {:error, :invalid_code}

    assert SSO.claim_session(nil) == {:error, :invalid_code}
    assert SSO.claim_session(42) == {:error, :invalid_code}
  end

  test "an expired claim_code cannot be claimed even though the session is active", %{user: user} do
    seed_session(
      user.id,
      "stale-code",
      DateTime.add(DateTime.utc_now(), -1, :second)
    )

    assert SSO.claim_session("stale-code") == {:error, :invalid_code}
  end

  # ── round trip ────────────────────────────────────────────────────────────

  test "full round trip: register → claim → re-authenticate via credential" do
    identity = %{provider: "authentik", sub: "s-rt", email: "rt@example.com"}
    assert {:ok, session} = SSO.register_user(identity, %{first: "R", last: "T"})

    assert {:ok, claimed} = SSO.claim_session(session.claim_code)
    assert claimed.claim_code == nil

    # uid-shaped attrs hit the same fingerprint as the sub-shaped registration.
    assert {:ok, session3} = SSO.authenticate_sso(:authentik, %{uid: "s-rt"})
    assert session3.user_id == claimed.user_id
    assert credential_count(claimed.user_id) == 1
  end
end
