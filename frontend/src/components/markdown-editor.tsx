'use client';

import { useRef, useState, useCallback } from 'react';
import {
  BoldIcon,
  ItalicIcon,
  H1Icon,
  H2Icon,
  H3Icon,
  ListBulletIcon,
  NumberedListIcon,
  ChatBubbleBottomCenterTextIcon,
  CodeBracketIcon,
  LinkIcon,
  MinusIcon,
} from '@heroicons/react/24/outline';
import { Markdown } from '@/components/markdown';

type Mode = 'write' | 'preview' | 'split';

interface Action {
  key: string;
  title: string;
  Icon: typeof BoldIcon;
  // Wrap the selection, or transform each selected line (for block actions).
  wrap?: [string, string];
  line?: (text: string, index: number) => string;
  insert?: string;
}

const ACTIONS: Action[] = [
  { key: 'bold', title: 'Bold (⌘B)', Icon: BoldIcon, wrap: ['**', '**'] },
  { key: 'italic', title: 'Italic (⌘I)', Icon: ItalicIcon, wrap: ['_', '_'] },
  { key: 'code', title: 'Inline code', Icon: CodeBracketIcon, wrap: ['`', '`'] },
  { key: 'h1', title: 'Heading 1', Icon: H1Icon, line: (t) => `# ${t.replace(/^#+\s*/, '')}` },
  { key: 'h2', title: 'Heading 2', Icon: H2Icon, line: (t) => `## ${t.replace(/^#+\s*/, '')}` },
  { key: 'h3', title: 'Heading 3', Icon: H3Icon, line: (t) => `### ${t.replace(/^#+\s*/, '')}` },
  { key: 'ul', title: 'Bulleted list', Icon: ListBulletIcon, line: (t) => `- ${t.replace(/^[-*]\s*/, '')}` },
  { key: 'ol', title: 'Numbered list', Icon: NumberedListIcon, line: (t, i) => `${i + 1}. ${t.replace(/^\d+\.\s*/, '')}` },
  { key: 'quote', title: 'Quote', Icon: ChatBubbleBottomCenterTextIcon, line: (t) => `> ${t.replace(/^>\s*/, '')}` },
  { key: 'link', title: 'Link', Icon: LinkIcon, wrap: ['[', '](https://)'] },
  { key: 'hr', title: 'Divider', Icon: MinusIcon, insert: '\n\n---\n\n' },
];

export function MarkdownEditor({
  value,
  onChange,
  rows = 18,
  placeholder = 'Write in markdown…',
}: {
  value: string;
  onChange: (next: string) => void;
  rows?: number;
  placeholder?: string;
}) {
  const ref = useRef<HTMLTextAreaElement>(null);
  const [mode, setMode] = useState<Mode>('write');

  const apply = useCallback(
    (action: Action) => {
      const ta = ref.current;
      if (!ta) return;
      const start = ta.selectionStart;
      const end = ta.selectionEnd;
      const selected = value.slice(start, end);
      let next = value;
      let caretStart = start;
      let caretEnd = end;

      if (action.insert) {
        next = value.slice(0, start) + action.insert + value.slice(end);
        caretStart = caretEnd = start + action.insert.length;
      } else if (action.wrap) {
        const [open, close] = action.wrap;
        next = value.slice(0, start) + open + selected + close + value.slice(end);
        caretStart = start + open.length;
        caretEnd = caretStart + selected.length;
      } else if (action.line) {
        // Expand selection to whole lines, then transform each line.
        const lineStart = value.lastIndexOf('\n', start - 1) + 1;
        const lineEndIdx = value.indexOf('\n', end);
        const lineEnd = lineEndIdx === -1 ? value.length : lineEndIdx;
        const block = value.slice(lineStart, lineEnd);
        const transformed = block.split('\n').map((l, i) => action.line!(l, i)).join('\n');
        next = value.slice(0, lineStart) + transformed + value.slice(lineEnd);
        caretStart = lineStart;
        caretEnd = lineStart + transformed.length;
      }

      onChange(next);
      requestAnimationFrame(() => {
        ta.focus();
        ta.setSelectionRange(caretStart, caretEnd);
      });
    },
    [value, onChange],
  );

  const onKeyDown = useCallback(
    (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'b') {
        e.preventDefault();
        apply(ACTIONS[0]);
      } else if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'i') {
        e.preventDefault();
        apply(ACTIONS[1]);
      } else if (e.key === 'Tab') {
        e.preventDefault();
        const ta = e.currentTarget;
        const s = ta.selectionStart;
        const next = value.slice(0, s) + '  ' + value.slice(ta.selectionEnd);
        onChange(next);
        requestAnimationFrame(() => ta.setSelectionRange(s + 2, s + 2));
      }
    },
    [apply, value, onChange],
  );

  return (
    <div className="md-editor">
      <div className="md-toolbar">
        <div className="md-toolbar__group">
          {ACTIONS.map((a) => (
            <button
              key={a.key}
              type="button"
              className="md-tool"
              title={a.title}
              aria-label={a.title}
              disabled={mode === 'preview'}
              onClick={() => apply(a)}
            >
              <a.Icon />
            </button>
          ))}
        </div>
        <div className="md-toolbar__modes" role="group" aria-label="Editor mode">
          {(['write', 'split', 'preview'] as Mode[]).map((m) => (
            <button
              key={m}
              type="button"
              className={`md-mode${mode === m ? ' is-active' : ''}`}
              onClick={() => setMode(m)}
            >
              {m === 'write' ? 'Write' : m === 'split' ? 'Split' : 'Preview'}
            </button>
          ))}
        </div>
      </div>

      <div className={`md-body md-body--${mode}`}>
        {mode !== 'preview' && (
          <textarea
            ref={ref}
            className="md-textarea"
            value={value}
            onChange={(e) => onChange(e.target.value)}
            onKeyDown={onKeyDown}
            placeholder={placeholder}
            rows={rows}
            spellCheck
          />
        )}
        {mode !== 'write' && (
          <div className="md-preview">
            <Markdown content={value} />
          </div>
        )}
      </div>
    </div>
  );
}
