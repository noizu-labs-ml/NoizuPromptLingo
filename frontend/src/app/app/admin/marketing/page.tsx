'use client';

import { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import { toast } from 'sonner';
import {
  api,
  type MarketingCounts,
  type MarketingSettingsRow,
  type MarketingSignupRow,
} from '@/lib/api';

const PER_PAGE = 25;

export default function AdminMarketingPage() {
  // Settings form state — empty string means "no cap" (NULL = unlimited).
  const [betaCap, setBetaCap] = useState('');
  const [promoCap, setPromoCap] = useState('');
  const [signupsOpen, setSignupsOpen] = useState(true);
  const [promoActive, setPromoActive] = useState(true);
  const [counts, setCounts] = useState<MarketingCounts | null>(null);
  const [settingsLoaded, setSettingsLoaded] = useState(false);
  const [saving, setSaving] = useState(false);

  // Signups table state.
  const [signups, setSignups] = useState<MarketingSignupRow[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [sourceFilter, setSourceFilter] = useState('');
  const [waitlistedFilter, setWaitlistedFilter] = useState('');
  const [loading, setLoading] = useState(true);

  const fetchSettings = useCallback(async () => {
    try {
      const data = await api.adminMarketingSettings();
      setBetaCap(data.settings.beta_signup_cap === null ? '' : String(data.settings.beta_signup_cap));
      setPromoCap(data.settings.promo_cap === null ? '' : String(data.settings.promo_cap));
      setSignupsOpen(data.settings.signups_open);
      setPromoActive(data.settings.promo_active);
      setCounts(data.counts);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load marketing settings');
    } finally {
      setSettingsLoaded(true);
    }
  }, []);

  const fetchSignups = useCallback(async () => {
    setLoading(true);
    try {
      const data = await api.adminListMarketingSignups({
        page,
        per_page: PER_PAGE,
        source: sourceFilter || undefined,
        waitlisted: waitlistedFilter || undefined,
      });
      setSignups(data.signups);
      setTotal(data.total);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to load signups');
    } finally {
      setLoading(false);
    }
  }, [page, sourceFilter, waitlistedFilter]);

  useEffect(() => {
    fetchSettings();
  }, [fetchSettings]);

  useEffect(() => {
    fetchSignups();
  }, [fetchSignups]);

  async function saveSettings(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    try {
      const data = await api.adminUpdateMarketingSettings({
        beta_signup_cap: betaCap.trim() === '' ? null : Number.parseInt(betaCap, 10),
        promo_cap: promoCap.trim() === '' ? null : Number.parseInt(promoCap, 10),
        signups_open: signupsOpen,
        promo_active: promoActive,
      });
      setCounts(data.counts);
      toast.success('Marketing settings saved');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Save failed');
    } finally {
      setSaving(false);
    }
  }

  const totalPages = Math.max(1, Math.ceil(total / PER_PAGE));

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">Marketing</h1>
        </div>
        <p className="sg-page-intro">
          Landing-page email capture: caps, promo switches, and every signup.{' '}
          <Link href="/app/admin">← Back to Admin</Link>
        </p>

        {counts && (
          <div className="dash-kpis" style={{ marginTop: '1.25rem' }}>
            <div className="kpi-card">
              <span className="kpi-card__label">Signups</span>
              <span className="kpi-card__value">{counts.signups}</span>
            </div>
            <div className="kpi-card">
              <span className="kpi-card__label">Promo awarded</span>
              <span className="kpi-card__value">{counts.promo_awarded}</span>
            </div>
            <div className="kpi-card">
              <span className="kpi-card__label">Waitlisted</span>
              <span className="kpi-card__value">{counts.waitlisted}</span>
            </div>
            <div className="kpi-card">
              <span className="kpi-card__label">Accepting</span>
              <span className="kpi-card__value" data-cy="accepting-state">
                {signupsOpen ? 'Yes' : 'No'}
              </span>
            </div>
          </div>
        )}

        {settingsLoaded && (
          <form className="console-form" onSubmit={saveSettings} style={{ marginTop: '1.5rem' }}>
            <fieldset className="console-form__section">
              <legend className="console-form__legend">Caps &amp; switches</legend>
              <div className="console-field">
                <label className="console-field__label" htmlFor="mk-beta-cap">
                  Beta signup cap
                </label>
                <input
                  id="mk-beta-cap"
                  className="console-field__input"
                  type="number"
                  min={0}
                  value={betaCap}
                  onChange={(e) => setBetaCap(e.target.value)}
                  placeholder="unlimited"
                />
                <p className="console-field__hint">
                  Max accepted (non-waitlisted) signups. Empty = unlimited. When full, new emails
                  are still captured but waitlisted.
                </p>
              </div>
              <div className="console-field">
                <label className="console-field__label" htmlFor="mk-promo-cap">
                  Founding promo cap
                </label>
                <input
                  id="mk-promo-cap"
                  className="console-field__input"
                  type="number"
                  min={0}
                  value={promoCap}
                  onChange={(e) => setPromoCap(e.target.value)}
                  placeholder="unlimited"
                />
                <p className="console-field__hint">
                  How many &quot;2 months free&quot; founding awards exist. Empty = unlimited.
                </p>
              </div>
              <div className="console-field__checks">
                <label className="console-field__check">
                  <input type="checkbox" checked={signupsOpen} onChange={(e) => setSignupsOpen(e.target.checked)} />
                  Signups open (closed ⇒ everyone is waitlisted)
                </label>
                <label className="console-field__check">
                  <input type="checkbox" checked={promoActive} onChange={(e) => setPromoActive(e.target.checked)} />
                  Promo active (awards the founding offer while slots remain)
                </label>
              </div>
            </fieldset>
            <div className="console-form__actions">
              <button className="sg-btn sg-btn--black" type="submit" disabled={saving}>
                {saving ? 'Saving…' : 'Save settings'}
              </button>
            </div>
          </form>
        )}

        <h2 className="sg-page-title" style={{ fontSize: '1.1rem', marginTop: '2rem' }}>
          Signups
        </h2>
        <div className="console-filters">
          <select
            className="sg-input--select"
            value={sourceFilter}
            onChange={(e) => {
              setPage(1);
              setSourceFilter(e.target.value);
            }}
            aria-label="Filter by source"
          >
            <option value="">All sources</option>
            <option value="landing">landing</option>
            <option value="pricing">pricing</option>
            <option value="waitlist">waitlist</option>
            <option value="hero">hero</option>
            <option value="footer">footer</option>
          </select>
          <select
            className="sg-input--select"
            value={waitlistedFilter}
            onChange={(e) => {
              setPage(1);
              setWaitlistedFilter(e.target.value);
            }}
            aria-label="Filter by waitlisted"
          >
            <option value="">All statuses</option>
            <option value="true">Waitlisted</option>
            <option value="false">Accepted</option>
          </select>
        </div>

        {loading ? (
          <p className="console-state">Loading…</p>
        ) : signups.length === 0 ? (
          <p className="console-state console-state--empty">No signups match.</p>
        ) : (
          <div className="console-table__scroll">
            <table className="console-table__grid">
              <thead>
                <tr>
                  <th>Email</th>
                  <th>Source</th>
                  <th>Promo</th>
                  <th>Waitlisted</th>
                  <th>Signed up</th>
                </tr>
              </thead>
              <tbody>
                {signups.map((s) => (
                  <tr key={s.id} className="console-table__row">
                    <td>{s.email}</td>
                    <td>
                      <span className="console-chip console-chip--slug">{s.source}</span>
                    </td>
                    <td>{s.promo_awarded ? '★ awarded' : '—'}</td>
                    <td>{s.waitlisted ? 'waitlist' : 'accepted'}</td>
                    <td>{s.created_at ? new Date(s.created_at).toLocaleString() : '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {total > PER_PAGE && (
          <div className="console-pager">
            <button className="sg-btn sg-btn--outline sg-btn--sm" disabled={page <= 1} onClick={() => setPage((p) => p - 1)}>
              ← Prev
            </button>
            <span className="console-pager__status">
              Page {page} of {totalPages} · {total} signups
            </span>
            <button
              className="sg-btn sg-btn--outline sg-btn--sm"
              disabled={page >= totalPages}
              onClick={() => setPage((p) => p + 1)}
            >
              Next →
            </button>
          </div>
        )}
      </main>
    </div>
  );
}
