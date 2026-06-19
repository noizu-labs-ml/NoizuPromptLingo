"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from "react";
import {
  acceptAllConsent,
  consentCategoryDetails,
  defaultConsentPreferences,
  getConsentState,
  hasConsent,
  onConsentChange,
  rejectOptionalConsent,
  setConsentPreferences,
  type ConsentCategory,
  type ConsentPreferences,
  type ConsentState,
  type OptionalConsentCategory,
} from "@/lib/consent";

interface CookieConsentContextValue {
  state: ConsentState | null;
  preferences: ConsentPreferences;
  hasDecision: boolean;
  isSettingsOpen: boolean;
  openSettings: () => void;
  closeSettings: () => void;
  acceptAll: () => void;
  rejectOptional: () => void;
  savePreferences: (preferences: Partial<Record<ConsentCategory, boolean>>) => void;
  hasCategoryConsent: (category: ConsentCategory) => boolean;
}

const CookieConsentContext = createContext<CookieConsentContextValue | null>(null);

function isOptionalCategory(category: ConsentCategory): category is OptionalConsentCategory {
  return category !== "necessary";
}

export function CookieConsentProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<ConsentState | null>(null);
  const [mounted, setMounted] = useState(false);
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);

  useEffect(() => {
    setState(getConsentState());
    setMounted(true);
    return onConsentChange(setState);
  }, []);

  const openSettings = useCallback(() => setIsSettingsOpen(true), []);
  const closeSettings = useCallback(() => setIsSettingsOpen(false), []);

  const acceptAll = useCallback(() => {
    setState(acceptAllConsent());
    setIsSettingsOpen(false);
  }, []);

  const rejectOptional = useCallback(() => {
    setState(rejectOptionalConsent());
    setIsSettingsOpen(false);
  }, []);

  const savePreferences = useCallback(
    (preferences: Partial<Record<ConsentCategory, boolean>>) => {
      setState(setConsentPreferences(preferences));
      setIsSettingsOpen(false);
    },
    []
  );

  const value = useMemo<CookieConsentContextValue>(
    () => ({
      state,
      preferences: state?.categories ?? defaultConsentPreferences,
      hasDecision: Boolean(state),
      isSettingsOpen,
      openSettings,
      closeSettings,
      acceptAll,
      rejectOptional,
      savePreferences,
      hasCategoryConsent: hasConsent,
    }),
    [
      acceptAll,
      closeSettings,
      isSettingsOpen,
      openSettings,
      rejectOptional,
      savePreferences,
      state,
    ]
  );

  return (
    <CookieConsentContext.Provider value={value}>
      {children}
      {mounted ? <CookieConsentBanner /> : null}
    </CookieConsentContext.Provider>
  );
}

export function useCookieConsent() {
  const context = useContext(CookieConsentContext);
  if (!context) {
    throw new Error("useCookieConsent must be used inside CookieConsentProvider");
  }
  return context;
}

export function CookieSettingsButton({ className }: { className?: string }) {
  const { openSettings } = useCookieConsent();

  return (
    <button
      type="button"
      className={className ?? "sg-btn sg-btn--outline sg-btn--sm"}
      onClick={openSettings}
    >
      Cookie Settings
    </button>
  );
}

export function CookieConsentBanner() {
  const {
    hasDecision,
    isSettingsOpen,
    closeSettings,
    acceptAll,
    rejectOptional,
    savePreferences,
    preferences,
  } = useCookieConsent();
  const [draft, setDraft] = useState<ConsentPreferences>(preferences);

  useEffect(() => {
    if (!hasDecision || isSettingsOpen) {
      setDraft(preferences);
    }
  }, [hasDecision, isSettingsOpen, preferences]);

  if (hasDecision && !isSettingsOpen) return null;

  const updateDraft = (category: OptionalConsentCategory, value: boolean) => {
    setDraft((current) => ({ ...current, [category]: value }));
  };

  return (
    <section
      className="cookie-consent"
      role="dialog"
      aria-modal="false"
      aria-labelledby="cookie-consent-title"
    >
      <div className="cookie-consent__content">
        <div className="cookie-consent__intro">
          <p id="cookie-consent-title" className="cookie-consent__title">
            Cookie choices
          </p>
          <p className="cookie-consent__copy">
            We use necessary storage to keep this app working. Optional categories are
            disabled until you approve them, and you can change your choice later.
          </p>
        </div>

        <div className="cookie-consent__categories">
          {consentCategoryDetails.map((category) => (
            <label key={category.id} className="cookie-consent__category">
              <span>
                <span className="cookie-consent__category-title">{category.label}</span>
                <span className="cookie-consent__category-copy">{category.description}</span>
              </span>
              <input
                type="checkbox"
                checked={draft[category.id]}
                disabled={category.required}
                onChange={(event) => {
                  if (isOptionalCategory(category.id)) {
                    updateDraft(category.id, event.target.checked);
                  }
                }}
                aria-label={`${category.label} cookies`}
              />
            </label>
          ))}
        </div>

        <div className="cookie-consent__actions">
          {hasDecision ? (
            <button type="button" className="sg-btn sg-btn--outline" onClick={closeSettings}>
              Cancel
            </button>
          ) : null}
          <button type="button" className="sg-btn sg-btn--outline" onClick={rejectOptional}>
            Reject optional
          </button>
          <button
            type="button"
            className="sg-btn sg-btn--outline"
            onClick={() => savePreferences(draft)}
          >
            Save choices
          </button>
          <button type="button" className="sg-btn sg-btn--black" onClick={acceptAll}>
            Accept all
          </button>
        </div>
      </div>
    </section>
  );
}
