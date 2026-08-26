defmodule NoizuPromptLinguaWeb.MarketingController do
  @moduledoc """
  Public, unauthenticated marketing endpoints for the landing page:

    * GET  /api/v1/public/marketing/status — live caps/switches for the
      pricing promo band (safe to expose; counters only).
    * POST /api/v1/public/marketing/signup — atomic email capture with
      cap-aware promo awarding / waitlisting.

  Email hygiene is intentionally minimal (trim, downcase, shape check) —
  this is a pre-billing interest list, not an auth surface. Per-IP rate
  limiting is applied at the router (marketing_signup action).
  """

  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Domains.Marketing.Signups

  @valid_sources ~w(landing pricing waitlist hero footer)

  def status(conn, _params) do
    json(conn, Signups.status())
  end

  def signup(conn, %{"email" => email} = params) do
    source = normalize_source(params["source"])

    case Signups.register_signup(email, source) do
      {:ok, %{waitlisted: true} = outcome} ->
        conn
        |> put_status(:accepted)
        |> json(%{
          accepted: true,
          waitlisted: true,
          promo_awarded: false,
          promo_remaining: outcome[:promo_remaining]
        })

      {:ok, outcome} ->
        conn
        |> put_status(:created)
        |> json(%{
          accepted: true,
          waitlisted: false,
          promo_awarded: outcome.promo_awarded,
          promo_remaining: outcome.promo_remaining,
          already_registered: outcome[:already_registered] || false
        })

      {:error, :invalid_email} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: "Invalid email address"})

      {:error, _changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: "Could not register email"})
    end
  end

  def signup(conn, _params) do
    conn |> put_status(:unprocessable_entity) |> json(%{error: "Email is required"})
  end

  defp normalize_source(source) when is_binary(source) do
    source = String.downcase(String.trim(source))

    if source in @valid_sources, do: source, else: "landing"
  end

  defp normalize_source(_), do: "landing"
end
