defmodule Codefresh.Guardian do
  use Guardian, otp_app: :codefresh

  alias Codefresh.Accounts
  alias Codefresh.Accounts.User
  alias Codefresh.Repo

  def subject_for_token(%{id: id}, _claims), do: {:ok, to_string(id)}
  def subject_for_token(_, _), do: {:error, :unhandled_resource}

  def resource_from_claims(%{"sub" => id}) when is_binary(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  rescue
    Ecto.Query.CastError -> {:error, :not_found}
  end

  def resource_from_claims(_), do: {:error, :invalid_claims}

  # Back-compat shim for existing Accounts callers
  def _unused, do: Accounts
end
