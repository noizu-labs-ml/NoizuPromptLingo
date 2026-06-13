defmodule Boe.Guardian do
  use Guardian, otp_app: :boe

  alias Boe.Accounts

  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def subject_for_token(_, _) do
    {:error, :unhandled_resource}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user!(String.to_integer(id)) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  rescue
    Ecto.NoResultsError -> {:error, :not_found}
  end
end
