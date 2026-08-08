'use client';

import { useEffect, useState } from 'react';
import { marked } from 'marked';
import DOMPurify from 'dompurify';

marked.setOptions({ gfm: true, breaks: true });

/**
 * Render a markdown string to sanitized HTML inside a `.wiki-prose` block.
 *
 * DOMPurify needs a DOM, so sanitization runs after mount — the first paint is
 * empty (matching the server render) and the effect fills in the content,
 * avoiding a hydration mismatch.
 */
export function Markdown({ content, className }: { content?: string | null; className?: string }) {
  const [html, setHtml] = useState('');

  useEffect(() => {
    let cancelled = false;
    const raw = (content ?? '').trim();
    if (!raw) {
      setHtml('');
      return;
    }
    Promise.resolve(marked.parse(raw)).then((parsed) => {
      if (!cancelled) setHtml(DOMPurify.sanitize(parsed));
    });
    return () => {
      cancelled = true;
    };
  }, [content]);

  const classes = ['wiki-prose', className].filter(Boolean).join(' ');

  if (!html) {
    return <div className={classes}><p className="wiki-prose__empty">Nothing here yet.</p></div>;
  }

  return <div className={classes} dangerouslySetInnerHTML={{ __html: html }} />;
}
