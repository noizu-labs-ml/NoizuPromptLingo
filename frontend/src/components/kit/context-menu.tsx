'use client';

import {
  useCallback,
  useEffect,
  useId,
  useRef,
  useState,
  type KeyboardEvent as ReactKeyboardEvent,
  type ReactNode,
} from 'react';
import { kitMenuSurface, kitMenuItem } from './shared';

export interface ContextMenuItem {
  /** Stable id passed back via onSelect. */
  id: string;
  label: string;
  icon?: ReactNode;
  shortcut?: string;
  destructive?: boolean;
  disabled?: boolean;
  /** Render a separator above this item. */
  separatorBefore?: boolean;
  /** Nested items shown on hover/focus. */
  submenu?: ContextMenuItem[];
}

interface ContextMenuProps {
  /** Menu definition. Rebuilt per invocation is fine. */
  items: ContextMenuItem[];
  /** Fired with the id of the activated (non-disabled) item. */
  onSelect: (id: string) => void;
  /** Fired when the menu is dismissed without selection. */
  onClose?: () => void;
  /** Wrapped content; right-clicking it opens the menu. */
  children: ReactNode;
  /** Disable the context menu entirely (children still render). */
  disabled?: boolean;
  /** Accessible label for the menu. */
  menuLabel?: string;
}

function nextEnabled(items: ContextMenuItem[], from: number, dir: 1 | -1): number {
  for (let i = 0; i < items.length; i++) {
    const idx = (from + dir * i + dir + items.length) % items.length;
    if (!items[idx].disabled) return idx;
  }
  return from;
}

/**
 * Right-click context menu. Wrap any content; the menu opens at the cursor,
 * supports icons, destructive styling, disabled items, separators, shortcuts,
 * and one level of submenu. Keyboard (WAI-ARIA menu pattern): arrows navigate,
 * Home/End jump to first/last item, Enter/Space activate, Enter/ArrowRight
 * opens a submenu (ArrowLeft/Esc closes it), Tab dismisses, Esc / click /
 * scroll outside dismiss and focus returns to the trigger.
 */
export default function ContextMenu({
  items,
  onSelect,
  onClose,
  children,
  disabled = false,
  menuLabel = 'Context menu',
}: ContextMenuProps) {
  const [pos, setPos] = useState<{ x: number; y: number } | null>(null);
  const [activeIdx, setActiveIdx] = useState(-1);
  const [openSubmenuIdx, setOpenSubmenuIdx] = useState<number | null>(null);
  const [activeSubIdx, setActiveSubIdx] = useState(-1);
  const menuRef = useRef<HTMLDivElement | null>(null);
  const triggerRef = useRef<HTMLElement | null>(null);
  const menuId = useId();

  const isOpen = pos !== null;

  const close = useCallback(
    (opts: { restoreFocus?: boolean } = {}) => {
      const wasOpen = pos !== null;
      setPos(null);
      setActiveIdx(-1);
      setOpenSubmenuIdx(null);
      setActiveSubIdx(-1);
      if (wasOpen) {
        if (opts.restoreFocus !== false) {
          const t = triggerRef.current;
          if (t && t.isConnected) t.focus({ preventScroll: true });
        }
        triggerRef.current = null;
        onClose?.();
      }
    },
    [pos, onClose],
  );

  // Clamp the open menu inside the viewport.
  useEffect(() => {
    if (!isOpen || !menuRef.current) return;
    const rect = menuRef.current.getBoundingClientRect();
    if (rect.right > window.innerWidth || rect.bottom > window.innerHeight) {
      setPos((p) => p && {
        x: Math.max(4, Math.min(p.x, window.innerWidth - rect.width - 4)),
        y: Math.max(4, Math.min(p.y, window.innerHeight - rect.height - 4)),
      });
    }
  }, [isOpen]);

  // Dismiss on outside click, scroll, or resize. Esc is handled in keydown.
  useEffect(() => {
    if (!isOpen) return;
    function onPointerDown(e: PointerEvent) {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) close();
    }
    function onScrollOrResize() {
      close();
    }
    window.addEventListener('pointerdown', onPointerDown, true);
    // capture: scroll events don't bubble; capture still sees them.
    window.addEventListener('scroll', onScrollOrResize, true);
    window.addEventListener('resize', onScrollOrResize);
    return () => {
      window.removeEventListener('pointerdown', onPointerDown, true);
      window.removeEventListener('scroll', onScrollOrResize, true);
      window.removeEventListener('resize', onScrollOrResize);
    };
  }, [isOpen, close]);

  // Focus the menu when it opens so keyboard nav works immediately.
  useEffect(() => {
    if (isOpen) menuRef.current?.focus();
  }, [isOpen]);

  function openAt(x: number, y: number, trigger: HTMLElement | null) {
    triggerRef.current = trigger;
    setPos({ x, y });
    setActiveIdx(firstEnabledIndex(items));
    setOpenSubmenuIdx(null);
    setActiveSubIdx(-1);
  }

  function openSubmenu(idx: number) {
    const subs = items[idx]?.submenu ?? [];
    setOpenSubmenuIdx(idx);
    setActiveSubIdx(subs.findIndex((s) => !s.disabled));
  }

  function activate(item: ContextMenuItem) {
    if (item.disabled || item.submenu?.length) return;
    onSelect(item.id);
    close();
  }

  function onKeyDown(e: ReactKeyboardEvent) {
    if (!isOpen) return;
    const submenuOpen = openSubmenuIdx !== null && openSubmenuIdx === activeIdx;
    const subs = submenuOpen ? (items[openSubmenuIdx]?.submenu ?? []) : [];

    if (e.key === 'Tab') {
      // Close and let focus move on with the default tab order.
      close({ restoreFocus: false });
      return;
    }
    if (e.key === 'Escape') {
      e.preventDefault();
      if (submenuOpen) {
        // First Esc closes the submenu, second closes the menu.
        setOpenSubmenuIdx(null);
        setActiveSubIdx(-1);
      } else {
        close();
      }
      return;
    }
    if (e.key === 'Home' || e.key === 'End') {
      e.preventDefault();
      if (submenuOpen) {
        const candidates = subs.map((s, i) => ({ s, i })).filter(({ s }) => !s.disabled);
        setActiveSubIdx(candidates.length ? (e.key === 'Home' ? candidates[0].i : candidates[candidates.length - 1].i) : -1);
      } else {
        setActiveIdx(e.key === 'Home' ? firstEnabledIndex(items) : lastEnabledIndex(items));
        setOpenSubmenuIdx(null);
        setActiveSubIdx(-1);
      }
      return;
    }
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
      e.preventDefault();
      const dir = e.key === 'ArrowDown' ? 1 : -1;
      if (submenuOpen) {
        setActiveSubIdx((cur) => nextEnabled(subs, cur, dir));
      } else {
        setActiveIdx((cur) => nextEnabled(items, cur, dir));
        setOpenSubmenuIdx(null);
        setActiveSubIdx(-1);
      }
      return;
    }
    if (e.key === 'ArrowRight') {
      e.preventDefault();
      if (submenuOpen) {
        const sub = subs[activeSubIdx];
        if (sub) activate(sub);
      } else {
        const item = items[activeIdx];
        if (item?.submenu?.length) openSubmenu(activeIdx);
      }
      return;
    }
    if (e.key === 'ArrowLeft') {
      if (submenuOpen) {
        e.preventDefault();
        setOpenSubmenuIdx(null);
        setActiveSubIdx(-1);
      }
      return;
    }
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      if (submenuOpen) {
        const sub = subs[activeSubIdx];
        if (sub) activate(sub);
        return;
      }
      const item = items[activeIdx];
      if (!item) return;
      if (item.submenu?.length) openSubmenu(activeIdx);
      else activate(item);
    }
  }

  const activeDescendant =
    activeIdx >= 0
      ? submenuOpenId(menuId, activeIdx, openSubmenuIdx === activeIdx ? activeSubIdx : null)
      : undefined;

  return (
    <div
      onContextMenu={(e) => {
        if (disabled) return;
        e.preventDefault();
        const trigger =
          document.activeElement instanceof HTMLElement && document.activeElement !== document.body
            ? document.activeElement
            : (e.target as HTMLElement);
        openAt(e.clientX, e.clientY, trigger);
      }}
    >
      {children}
      {isOpen && (
        <div
          ref={menuRef}
          id={menuId}
          role="menu"
          aria-label={menuLabel}
          aria-activedescendant={activeDescendant}
          tabIndex={-1}
          onKeyDown={onKeyDown}
          style={{
            position: 'fixed',
            left: pos.x,
            top: pos.y,
            outline: 'none',
            ...kitMenuSurface,
          }}
        >
          {items.map((item, idx) => (
            <div key={item.id} style={{ position: 'relative' }}>
              {item.separatorBefore && (
                <div role="separator" style={{ height: 1, background: 'var(--border)', margin: '4px 0' }} />
              )}
              <button
                type="button"
                role="menuitem"
                id={submenuOpenId(menuId, idx, null)}
                aria-disabled={item.disabled || undefined}
                aria-haspopup={item.submenu?.length ? 'menu' : undefined}
                aria-expanded={item.submenu?.length ? openSubmenuIdx === idx : undefined}
                style={{
                  ...kitMenuItem({ destructive: item.destructive, disabled: item.disabled }),
                  ...(activeIdx === idx && !item.disabled
                    ? { background: 'var(--accent-dim, var(--bg-3))' }
                    : {}),
                }}
                onMouseEnter={() => {
                  setActiveIdx(idx);
                  setOpenSubmenuIdx(item.submenu?.length ? idx : null);
                  setActiveSubIdx(-1);
                }}
                onClick={() => activate(item)}
              >
                {item.icon ? <span aria-hidden="true" style={{ display: 'inline-flex', width: 16 }}>{item.icon}</span> : null}
                <span style={{ flex: 1 }}>{item.label}</span>
                {item.shortcut ? (
                  <span style={{ fontSize: 10, color: 'var(--text-3)' }}>{item.shortcut}</span>
                ) : null}
                {item.submenu?.length ? (
                  <span aria-hidden="true" style={{ fontSize: 10, color: 'var(--text-3)' }}>▸</span>
                ) : null}
              </button>
              {item.submenu?.length && openSubmenuIdx === idx ? (
                <div
                  role="menu"
                  aria-label={item.label}
                  style={{
                    position: 'absolute',
                    left: '100%',
                    top: 0,
                    ...kitMenuSurface,
                    zIndex: 1001,
                  }}
                >
                  {item.submenu.map((sub, sIdx) => (
                    <button
                      key={sub.id}
                      type="button"
                      role="menuitem"
                      id={submenuOpenId(menuId, idx, sIdx)}
                      aria-disabled={sub.disabled || undefined}
                      style={{
                        ...kitMenuItem({ destructive: sub.destructive, disabled: sub.disabled }),
                        ...(activeSubIdx === sIdx && !sub.disabled
                          ? { background: 'var(--accent-dim, var(--bg-3))' }
                          : {}),
                      }}
                      onMouseEnter={() => setActiveSubIdx(sIdx)}
                      onClick={() => activate(sub)}
                    >
                      {sub.icon ? <span aria-hidden="true" style={{ display: 'inline-flex', width: 16 }}>{sub.icon}</span> : null}
                      <span style={{ flex: 1 }}>{sub.label}</span>
                    </button>
                  ))}
                </div>
              ) : null}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function submenuOpenId(menuId: string, idx: number, subIdx: number | null): string {
  return subIdx === null ? `${menuId}-item-${idx}` : `${menuId}-item-${idx}-${subIdx}`;
}

function firstEnabledIndex(items: ContextMenuItem[]): number {
  const idx = items.findIndex((i) => !i.disabled);
  return idx === -1 ? 0 : idx;
}

function lastEnabledIndex(items: ContextMenuItem[]): number {
  for (let i = items.length - 1; i >= 0; i--) {
    if (!items[i].disabled) return i;
  }
  return items.length - 1;
}
