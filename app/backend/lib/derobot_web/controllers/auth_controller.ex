defmodule DerobotWeb.AuthController do
  use DerobotWeb, :controller

  alias Derobot.Guardian

  def register(conn, %{"user" => %{"email" => email, "password" => password} = params}) do
    handle = params["handle"] || email |> String.split("@") |> hd() |> String.replace(~r/[^a-z0-9_]/, "_")

    user_schema = %Derobot.Schema.Users.User{
      id: UUID.uuid4(),
      user_name: handle,
      handle: handle,
      email: String.trim(String.downcase(email)),
      hashed_password: Bcrypt.hash_pwd_salt(password),
      status: :active,
      verified: false,
      flagged: false
    }

    case Derobot.Repo.insert(user_schema) do
      {:ok, user} ->
        context = Noizu.Context.system()

        {:ok, credential} =
          Derobot.Users.Credentials.register(
            Derobot.Users.User.ref(user.id),
            {:login, {user.email, password}},
            context,
            []
          )

        {:ok, session} =
          %Derobot.Users.Sessions.UserSession{
            user: Derobot.Users.User.ref(user.id),
            status: :active,
            details: %{auth_method: "login"},
            time_stamp: Noizu.Entity.TimeStamp.now()
          }
          |> Derobot.EntityRepo.create(context)

        {:ok, access_token, _} =
          Guardian.encode_and_sign(session, %{}, token_type: "access", ttl: {1, :hour})

        {:ok, refresh_token, _} =
          Guardian.encode_and_sign(session, %{}, token_type: "refresh", ttl: {7, :day})

        conn
        |> put_status(:created)
        |> json(%{
          user: serialize_user(user),
          access_token: access_token,
          refresh_token: refresh_token
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_changeset_errors(changeset)})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    context = Noizu.Context.system()

    case Derobot.Users.authenticate({:login, {email, password}}, context) do
      {:ok, session} ->
        user = resolve_user_from_session(session, context)

        {:ok, access_token, _} =
          Guardian.encode_and_sign(session, %{}, token_type: "access", ttl: {1, :hour})

        {:ok, refresh_token, _} =
          Guardian.encode_and_sign(session, %{}, token_type: "refresh", ttl: {7, :day})

        conn
        |> put_status(:ok)
        |> json(%{
          user: serialize_user(user),
          access_token: access_token,
          refresh_token: refresh_token
        })

      {:error, _} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid email or password"})
    end
  end

  def refresh(conn, %{"refresh_token" => refresh_token}) do
    case Guardian.decode_and_verify(refresh_token, %{"typ" => "refresh"}) do
      {:ok, claims} ->
        case Guardian.resource_from_claims(claims) do
          {:ok, session} ->
            {:ok, access_token, _} =
              Guardian.encode_and_sign(session, %{}, token_type: "access", ttl: {1, :hour})

            conn
            |> put_status(:ok)
            |> json(%{access_token: access_token})

          {:error, _} ->
            conn |> put_status(:unauthorized) |> json(%{error: "Invalid refresh token"})
        end

      {:error, _} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid refresh token"})
    end
  end

  def me(conn, _params) do
    session = Guardian.Plug.current_resource(conn)
    context = Noizu.Context.system()
    user = resolve_user_from_session(session, context)

    conn
    |> put_status(:ok)
    |> json(%{user: serialize_user(user)})
  end

  defp resolve_user_from_session(%Derobot.Users.Sessions.UserSession{} = session, context) do
    case session.user do
      {:ref, _, id} ->
        {:ok, user} = Derobot.Users.get_user(id, context)
        user

      %Derobot.Users.User{} = user ->
        user
    end
  end

  defp serialize_user(user) do
    %{
      id: user.id,
      email: user.email,
      user_name: user.user_name,
      handle: user.handle,
      status: user.status,
      verified: user.verified
    }
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
