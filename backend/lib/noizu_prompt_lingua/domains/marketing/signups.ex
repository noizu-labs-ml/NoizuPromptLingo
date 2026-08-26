defmodule NoizuPromptLingua.Domains.Marketing.Signups do
  @moduledoc """
  Public marketing signups (landing email capture) and the admin-editable
  caps that gate them.

  Two INDEPENDENT caps live on the singleton `marketing_settings` row:

    * `beta_signup_cap` — accepted (non-waitlisted) signups; NULL = unlimited
    * `promo_cap` — founding-promo awards ("2 months free"); NULL = unlimited

  `register_signup/3` decides acceptance and promo awarding inside ONE
  transaction, holding a `FOR UPDATE` lock on the settings row so two
  concurrent requests can never both claim the last promo spot (or the last
  beta seat). Cap exhaustion is graceful: the row is still inserted, flagged
  `waitlisted`, rather than bounced.
  """

  import Ecto.Query
  alias Ecto.Changeset
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.MarketingSettings
  alias NoizuPromptLingua.Schema.MarketingSignup

  @price_cents 495
  @email_re ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/

  def price_cents, do: @price_cents

  # ── Settings (singleton) ──────────────────────────────────────────

  @doc """
  The singleton settings row, creating it (best-effort) when the table is
  empty so the public endpoints work even before the seed changeset ran.
  """
  def get_settings! do
    case Repo.get(MarketingSettings, MarketingSettings.singleton_id()) do
      nil ->
        %MarketingSettings{id: MarketingSettings.singleton_id()}
        |> Repo.insert!(on_conflict: :nothing, conflict_target: :id)

        Repo.get!(MarketingSettings, MarketingSettings.singleton_id())

      settings ->
        settings
    end
  end

  def update_settings(attrs) do
    get_settings!()
    |> MarketingSettings.changeset(attrs)
    |> Repo.update()
  end

  # ── Public status ─────────────────────────────────────────────────

  @doc """
  Live marketing status for the landing page: caps, remaining slots
  (nil = unlimited), switches, and the plan price.
  """
  def status do
    settings = get_settings!()
    accepted = accepted_count()
    promo_count = promo_count()

    %{
      signups_open: settings.signups_open,
      beta_cap: settings.beta_signup_cap,
      beta_remaining: remaining(settings.beta_signup_cap, accepted),
      promo_active: settings.promo_active,
      promo_cap: settings.promo_cap,
      promo_remaining: remaining(settings.promo_cap, promo_count),
      price_cents: @price_cents
    }
  end

  # ── Signup registration ───────────────────────────────────────────

  @doc """
  Atomically register `email` (trimmed + lowercased).

  * signups open AND beta cap not exhausted → accepted row; promo awarded iff
    promo is active and a promo slot remained AT INSERT TIME.
  * otherwise → row inserted with `waitlisted: true`, `source: "waitlist"`.

  Returns `{:ok, result_map}`, `{:error, :invalid_email}`, or
  `{:error, changeset}`. Duplicate emails are idempotent:
  `{:ok, %{already_registered: true, ...}}` echoing the existing row.
  """
  def register_signup(email, source \\ "landing", metadata \\ %{})

  def register_signup(email, source, metadata) when is_binary(email) do
    with {:ok, email} <- normalize_email(email) do
      result =
        Repo.transaction(fn ->
          # Serialize cap decisions on the singleton row: the lock is held
          # through the insert, so the Nth+1 caller sees the Nth caller's row.
          settings = lock_settings!()
          accepted = accepted_count()
          promo_count = promo_count()

          beta_left = remaining(settings.beta_signup_cap, accepted)
          promo_left = remaining(settings.promo_cap, promo_count)

          if settings.signups_open and beta_open?(beta_left) do
            promo_awarded? =
              settings.promo_active and
                (is_nil(promo_left) or promo_left > 0)

            case insert(email, source, promo_awarded?, false, metadata) do
              {:ok, _row} ->
                %{
                  accepted: true,
                  waitlisted: false,
                  promo_awarded: promo_awarded?,
                  promo_remaining: decrement(promo_left)
                }

              {:error, changeset} ->
                Repo.rollback(changeset)
            end
          else
            case insert(email, "waitlist", false, true, metadata) do
              {:ok, _row} ->
                %{accepted: true, waitlisted: true, promo_awarded: false, promo_remaining: promo_left}

              {:error, changeset} ->
                Repo.rollback(changeset)
            end
          end
        end)

      case result do
        {:ok, outcome} ->
          {:ok, outcome}

        {:error, %Changeset{errors: [email: {"has already been taken", _}]}} ->
          {:ok, existing_row_outcome(email)}

        {:error, other} ->
          {:error, other}
      end
    end
  end

  def register_signup(_, _, _), do: {:error, :invalid_email}

  # ── Admin listings ────────────────────────────────────────────────

  @doc "Counts for the admin console header cards."
  def counts do
    %{
      signups: Repo.aggregate(MarketingSignup, :count),
      promo_awarded: promo_count(),
      waitlisted: Repo.aggregate(where(MarketingSignup, [s], s.waitlisted == true), :count)
    }
  end

  @doc """
  Paginated signups, newest first. Filters: `source`, `waitlisted` (bool).
  """
  def list_signups(filters \\ %{}, page \\ 1, per_page \\ 50) do
    page = max(page || 1, 1)
    per_page = min(per_page || 50, 200)

    base =
      MarketingSignup
      |> order_by([s], desc: s.inserted_at)
      |> filter_source(filters[:source])
      |> filter_waitlisted(filters[:waitlisted])

    total = Repo.aggregate(base, :count)

    rows =
      base
      |> limit(^per_page)
      |> offset(^((page - 1) * per_page))
      |> Repo.all()

    {rows, total}
  end

  defp filter_source(query, nil), do: query
  defp filter_source(query, source) when source in ["", :undefined], do: query
  defp filter_source(query, source), do: where(query, [s], s.source == ^source)

  defp filter_waitlisted(query, nil), do: query

  defp filter_waitlisted(query, waitlisted) when waitlisted in [true, "true"],
    do: where(query, [s], s.waitlisted == true)

  defp filter_waitlisted(query, waitlisted) when waitlisted in [false, "false"],
    do: where(query, [s], s.waitlisted == false)

  defp filter_waitlisted(query, _), do: query

  # ── Internals ─────────────────────────────────────────────────────

  defp accepted_count,
    do: Repo.aggregate(where(MarketingSignup, [s], s.waitlisted == false), :count)

  defp promo_count,
    do: Repo.aggregate(where(MarketingSignup, [s], s.promo_awarded == true), :count)

  defp remaining(nil, _count), do: nil
  defp remaining(cap, count) when is_integer(cap), do: max(cap - count, 0)

  defp decrement(nil), do: nil
  defp decrement(left) when left > 0, do: left - 1
  defp decrement(0), do: 0

  defp beta_open?(nil), do: true
  defp beta_open?(left) when is_integer(left), do: left > 0

  defp lock_settings! do
    id = MarketingSettings.singleton_id()

    case Repo.one(from s in MarketingSettings, where: s.id == ^id, lock: "FOR UPDATE") do
      nil ->
        %MarketingSettings{id: id}
        |> Repo.insert!(on_conflict: :nothing, conflict_target: :id)

        Repo.one!(from s in MarketingSettings, where: s.id == ^id, lock: "FOR UPDATE")

      settings ->
        settings
    end
  end

  defp insert(email, source, promo_awarded, waitlisted, metadata) do
    %MarketingSignup{}
    |> MarketingSignup.changeset(%{
      email: email,
      source: source,
      promo_awarded: promo_awarded,
      waitlisted: waitlisted,
      metadata: metadata
    })
    |> Repo.insert()
  end

  defp normalize_email(email) do
    email = email |> String.trim() |> String.downcase()

    if Regex.match?(@email_re, email) and String.length(email) <= 255 do
      {:ok, email}
    else
      {:error, :invalid_email}
    end
  end

  defp existing_row_outcome(email) do
    existing = Repo.get_by(MarketingSignup, email: email)

    %{
      accepted: true,
      already_registered: true,
      waitlisted: existing.waitlisted,
      promo_awarded: existing.promo_awarded,
      promo_remaining: remaining(get_settings!().promo_cap, promo_count())
    }
  end
end
