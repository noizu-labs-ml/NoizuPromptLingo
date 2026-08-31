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

/**
 * Right-click context menu. Wrap any content; the menu opens at the cursor,
 * supports icons, destructive styling, disabled items, separators, shortcuts,
 * and one level of submenu. Keyboard: arrows navigate, Enter/Space activate,
 * Right opens a submenu, Esc / click-outside dismisses.
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
  const menuRef = useRef<HTMLDivElement | null>(null);
  const menuId = useId();

  const isOpen = pos !== null;

  const close = useCallback(() => {
    setPos(null);
    setActiveIdx(-1);
    setOpenSubmenuIdx(null);
    onClose?.();
  }, [onClose]);

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

  // Dismiss on outside click / scroll / Esc handled in keydown below.
  useEffect(() => {
    if (!isOpen) return;
    function onPointerDown(e: PointerEvent) {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) close();
    }
    function onScrollOrBlur() {
      close();
    }
    window.addEventListener('pointerdown', onPointerDown, true);
    window.addEventListener('resize', onScrollOrBlur);
    return () => {
      window.removeEventListener('pointerdown', onPointerDown, true);
      window.removeEventListener('resize', onScrollOrBlur);
    };
  }, [isOpen, close]);

  // Focus the menu when it opens so keyboard nav works immediately.
  useEffect(() => {
    if (isOpen) menuRef.current?.focus();
  }, [isOpen]);

  function openAt(x: number, y: number) {
    setPos({ x, y });
    setActiveIdx(firstEnabledIndex(items));
    setOpenSubmenuIdx(null);
  }

  function activate(item: ContextMenuItem) {
    if (item.disabled || item.submenu?.length) return;
    onSelect(item.id);
    close();
  }

  function onKeyDown(e: ReactKeyboardEvent) {
    if (!isOpen) return;
    const flat = items;
    if (e.key === 'Escape') {
      e.preventDefault();
      close();
      return;
    }
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
      e.preventDefault();
      const dir = e.key === 'ArrowDown' ? 1 : -1;
      let idx = activeIdx;
      for (let i = 0; i < flat.length; i++) {
        idx = (idx + dir + flat.length) % flat.length;
        if (!flat[idx].disabled) break;
      }
      setActiveIdx(idx);
      setOpenSubmenuIdx(null);
      return;
    }
    if (e.key === 'ArrowRight') {
      const item = flat[activeIdx];
      if (item?.submenu?.length) {
        e.preventDefault();
        setOpenSubmenuIdx(activeIdx);
      }
      return;
    }
    if (e.key === 'ArrowLeft' && openSubmenuIdx !== null) {
      e.preventDefault();
      setOpenSubmenuIdx(null);
      return;
    }
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      const item = flat[activeIdx];
      if (item) activate(item);
    }
  }

  return (
    <div
      onContextMenu={(e) => {
        if (disabled) return;
        e.preventDefault();
        openAt(e.clientX, e.clientY);
      }}
    >
      {children}
      {isOpen && (
        <div
          ref={menuRef}
          id={menuId}
          role="menu"
          aria-label={menuLabel}
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
                  {item.submenu.map((sub) => (
                    <button
                      key={sub.id}
                      type="button"
                      role="menuitem"
                      aria-disabled={sub.disabled || undefined}
                      style={kitMenuItem({ destructive: sub.destructive, disabled: sub.disabled })}
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

function firstEnabledIndex(items: ContextMenuItem[]): number {
  const idx = items.findIndex((i) => !i.disabled);
  return idx === -1 ? 0 : idx;
}
