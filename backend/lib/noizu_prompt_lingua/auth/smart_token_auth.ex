defmodule NoizuPromptLingua.Auth.SmartTokenAuth do
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema
  import Ecto.Query, only: [from: 2]

  @magic_link_validity {:unbound, {:relative, [{:minute, 15}]}}
  @otp_validity {:unbound, {:relative, [{:minute, 10}]}}
  @otp_length 6

  def request_magic_link(email) do
    email = email |> String.trim() |> String.downcase()

    case find_active_user_by_email(email) do
      {:ok, user} ->
        context = Noizu.Context.system()
        {:ok, user_ref} = Noizu.EntityReference.Protocol.ref(user)

        token =
          SmartToken.new(%{
            type: :magic_link,
            resource: {:bind, :recipient},
            context: {:bind, :recipient},
            scope: {:auth, :magic_link},
            validity_period: @magic_link_validity,
            extended_info: %{single_use: true}
          })
          |> SmartToken.bind!(%{recipient: user_ref}, context)

        encoded_key = SmartToken.encoded_key(token)
        {:ok, %{encoded_key: encoded_key, user: user}}

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  def verify_magic_link(token_key, conn) do
    context = Noizu.Context.system()

    case SmartToken.authorize!(token_key, conn, context) do
      {:ok, token} ->
        with {:ok, user} <- Noizu.EntityReference.Protocol.entity(token.resource, context),
             {:ok, user_ref} <- Noizu.EntityReference.Protocol.ref(user) do
          %NoizuPromptLingua.Users.Sessions.UserSession{
            user: user_ref,
            status: :active,
            details: %{auth_method: "magic_link"},
            time_stamp: Noizu.Entity.TimeStamp.now()
          }
          |> NoizuPromptLingua.EntityRepo.create(context)
        end

      {:error, _reason} ->
        {:error, :invalid_token}
    end
  end

  # ---------------------------------------------------------------------------
  # OTP Login
  # ---------------------------------------------------------------------------

  def request_otp_login(email) do
    email = email |> String.trim() |> String.downcase()

    case find_active_user_by_email(email) do
      {:ok, user} ->
        {otp_code, token} = create_otp_token(user, {:auth, :otp_login})
        {:ok, %{otp_code: otp_code, user: user, token: token}}

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  def verify_otp_login(email, otp_code, conn) do
    email = email |> String.trim() |> String.downcase()
    context = Noizu.Context.system()

    case find_active_user_by_email(email) do
      {:ok, user} ->
        {:ok, user_ref} = Noizu.EntityReference.Protocol.ref(user)
        case find_and_authorize_otp(user_ref, otp_code, {:auth, :otp_login}, conn, context) do
          {:ok, _token} ->
            %NoizuPromptLingua.Users.Sessions.UserSession{
              user: user_ref,
              status: :active,
              details: %{auth_method: "otp_login"},
              time_stamp: Noizu.Entity.TimeStamp.now()
            }
            |> NoizuPromptLingua.EntityRepo.create(context)

          {:error, reason} ->
            {:error, reason}
        end

      {:error, :not_found} ->
        {:error, :invalid_code}
    end
  end

  # ---------------------------------------------------------------------------
  # OTP Password Reset
  # ---------------------------------------------------------------------------

  def request_password_reset(email) do
    email = email |> String.trim() |> String.downcase()

    case find_active_user_by_email(email) do
      {:ok, user} ->
        {otp_code, token} = create_otp_token(user, {:auth, :password_reset})
        {:ok, %{otp_code: otp_code, user: user, token: token}}

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  def verify_password_reset(email, otp_code, new_password, conn) do
    email = email |> String.trim() |> String.downcase()
    context = Noizu.Context.system()

    case find_active_user_by_email(email) do
      {:ok, user} ->
        {:ok, user_ref} = Noizu.EntityReference.Protocol.ref(user)
        case find_and_authorize_otp(user_ref, otp_code, {:auth, :password_reset}, conn, context) do
          {:ok, _token} ->
            NoizuPromptLingua.Users.Credentials.update_password(user, new_password, context)

          {:error, reason} ->
            {:error, reason}
        end

      {:error, :not_found} ->
        {:error, :invalid_code}
    end
  end

  # ---------------------------------------------------------------------------
  # Email Verification
  # ---------------------------------------------------------------------------

  def request_email_verification(email) do
    email = email |> String.trim() |> String.downcase()

    case find_active_user_by_email(email) do
      {:ok, user} ->
        context = Noizu.Context.system()
        {:ok, user_ref} = Noizu.EntityReference.Protocol.ref(user)

        token =
          SmartToken.new(%{
            type: :magic_link,
            resource: {:bind, :recipient},
            context: {:bind, :recipient},
            scope: {:auth, :email_verification},
            validity_period: {:unbound, {:relative, [{:hour, 24}]}},
            extended_info: %{single_use: true}
          })
          |> SmartToken.bind!(%{recipient: user_ref}, context)

        encoded_key = SmartToken.encoded_key(token)
        {:ok, %{encoded_key: encoded_key, user: user}}

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  def verify_email_token(token_key) do
    context = Noizu.Context.system()

    case SmartToken.authorize!(token_key, %{}, context) do
      {:ok, token} ->
        with {:ok, user} <- Noizu.EntityReference.Protocol.entity(token.resource, context) do
          import Ecto.Query, only: [from: 2]
          alias NoizuPromptLingua.Schema.Users.User, as: UserSchema

          from(u in UserSchema, where: u.id == ^user.id)
          |> NoizuPromptLingua.Repo.update_all(set: [verified: true])

          {:ok, user}
        end

      {:error, _reason} ->
        {:error, :invalid_token}
    end
  end

  # ---------------------------------------------------------------------------
  # OTP Helpers
  # ---------------------------------------------------------------------------

  defp create_otp_token(user, scope) do
    context = Noizu.Context.system()
    {:ok, user_ref} = Noizu.EntityReference.Protocol.ref(user)
    otp_code = generate_otp()

    token =
      SmartToken.new(%{
        type: :otp,
        resource: {:bind, :recipient},
        context: {:bind, :recipient},
        scope: scope,
        validity_period: @otp_validity,
        extended_info: %{single_use: true},
        state: %{otp_code: otp_code}
      })
      |> SmartToken.bind!(%{recipient: user_ref}, context)

    {otp_code, token}
  end

  defp find_and_authorize_otp(user_ref, otp_code, scope, conn, context) do
    case lookup_otp_token(user_ref, otp_code, scope) do
      {:ok, encoded_key} ->
        SmartToken.authorize!(encoded_key, conn, context)

      {:error, _} ->
        {:error, :invalid_code}
    end
  end

  defp lookup_otp_token(user_ref, otp_code, scope) do
    import Ecto.Query, only: [from: 2]

    q =
      from t in SmartToken.Schema.SmartToken,
        order_by: [desc: t.inserted_at],
        limit: 20

    tokens = NoizuPromptLingua.Repo.all(q)

    match =
      Enum.find(tokens, fn record ->
        case record.smart_token do
          %SmartToken{resource: ^user_ref, scope: ^scope, state: %{otp_code: ^otp_code}} -> true
          _ -> false
        end
      end)

    case match do
      nil -> {:error, :not_found}
      record -> {:ok, SmartToken.encoded_key(record.smart_token)}
    end
  end

  defp generate_otp do
    :crypto.strong_rand_bytes(4)
    |> :binary.decode_unsigned()
    |> rem(trunc(:math.pow(10, @otp_length)))
    |> Integer.to_string()
    |> String.pad_leading(@otp_length, "0")
  end

  defp find_active_user_by_email(email) do
    q =
      from u in UserSchema,
        where: u.email == ^email,
        where: u.status == :active,
        limit: 1

    case NoizuPromptLingua.Repo.one(q) do
      nil ->
        {:error, :not_found}

      record ->
        settings = Noizu.Entity.Meta.persistence(NoizuPromptLingua.Users.User) |> hd
        NoizuPromptLingua.Users.User.from_record(record, settings, Noizu.Context.system(), [])
    end
  end
end
