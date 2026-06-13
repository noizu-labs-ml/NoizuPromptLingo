"use client";

import Link from "next/link";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";

export function PaperLayout({
  title,
  subtitle,
  children,
}: {
  title: string;
  subtitle: string;
  children: React.ReactNode;
}) {
  return (
    <div className="overflow-x-hidden">
      <section className="relative pt-32 pb-8 sm:pt-44 sm:pb-12 overflow-hidden">
        <div className="absolute inset-0 -z-10">
          <div className="absolute top-0 left-1/3 w-[600px] h-[400px] bg-gold-400/6 rounded-full blur-[120px]" />
        </div>
        <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
          <Link
            href="/papers"
            className="inline-flex items-center gap-1.5 text-sm text-zinc-500 hover:text-gold-400 transition-colors mb-6"
          >
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18" />
            </svg>
            Papers
          </Link>
          <h1 className="text-3xl sm:text-5xl font-bold tracking-tight text-white mb-2">
            {title}
          </h1>
          <p className="text-base text-zinc-400 italic">{subtitle}</p>
        </div>
      </section>
      <article className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8 pb-24">
        {children}
      </article>
    </div>
  );
}

export function MarkdownProse({ content }: { content: string }) {
  return (
    <div className="prose-paper">
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        components={{
          h1: ({ children }) => (
            <h1 className="text-2xl font-bold text-white mt-12 mb-4">{children}</h1>
          ),
          h2: ({ children }) => (
            <h2 className="text-xl font-bold text-white mt-10 mb-3 pb-2 border-b border-zinc-800">{children}</h2>
          ),
          h3: ({ children }) => (
            <h3 className="text-lg font-semibold text-zinc-200 mt-8 mb-2">{children}</h3>
          ),
          p: ({ children }) => (
            <p className="text-sm text-zinc-300 leading-relaxed mb-4">{children}</p>
          ),
          em: ({ children }) => (
            <em className="text-zinc-200 italic">{children}</em>
          ),
          strong: ({ children }) => (
            <strong className="text-white font-semibold">{children}</strong>
          ),
          a: ({ href, children }) => (
            <a
              href={href}
              className="text-blue-400 underline hover:text-blue-300 transition-colors"
              target={href?.startsWith("http") ? "_blank" : undefined}
              rel={href?.startsWith("http") ? "noopener noreferrer" : undefined}
            >
              {children}
            </a>
          ),
          blockquote: ({ children }) => (
            <blockquote className="border-l-2 border-gold-400 pl-4 my-4 text-zinc-400 italic">
              {children}
            </blockquote>
          ),
          ul: ({ children }) => (
            <ul className="list-disc list-outside ml-5 mb-4 space-y-1 text-sm text-zinc-300">
              {children}
            </ul>
          ),
          ol: ({ children }) => (
            <ol className="list-decimal list-outside ml-5 mb-4 space-y-1 text-sm text-zinc-300">
              {children}
            </ol>
          ),
          li: ({ children }) => (
            <li className="leading-relaxed">{children}</li>
          ),
          hr: () => (
            <hr className="my-8 border-zinc-800" />
          ),
          code: ({ className, children }) => {
            const isBlock = className?.includes("language-");
            if (isBlock) {
              return (
                <code className="block bg-[#0f172a] border border-[#1e293b] rounded-lg p-4 text-xs text-zinc-300 overflow-x-auto whitespace-pre font-mono">
                  {children}
                </code>
              );
            }
            return (
              <code className="bg-zinc-800 text-zinc-200 px-1.5 py-0.5 rounded text-xs font-mono">
                {children}
              </code>
            );
          },
          pre: ({ children }) => (
            <pre className="my-4">{children}</pre>
          ),
          table: ({ children }) => (
            <div className="overflow-x-auto my-6">
              <table className="w-full text-sm text-zinc-300 border-collapse">
                {children}
              </table>
            </div>
          ),
          thead: ({ children }) => (
            <thead className="border-b border-zinc-700 text-left text-zinc-200">
              {children}
            </thead>
          ),
          th: ({ children }) => (
            <th className="px-3 py-2 font-semibold text-xs">{children}</th>
          ),
          td: ({ children }) => (
            <td className="px-3 py-2 text-xs border-b border-zinc-800">{children}</td>
          ),
          sup: ({ children }) => (
            <sup className="text-blue-400">{children}</sup>
          ),
          section: ({ children, ...props }) => {
            const className = (props as Record<string, string>).className;
            if (className === "footnotes") {
              return (
                <section className="mt-12 pt-6 border-t border-zinc-800">
                  <h3 className="text-sm font-semibold text-zinc-400 uppercase tracking-wider mb-4">Footnotes</h3>
                  <div className="text-xs text-zinc-500 space-y-3">{children}</div>
                </section>
              );
            }
            return <section>{children}</section>;
          },
        }}
      >
        {content}
      </ReactMarkdown>
    </div>
  );
}

export function AccordDivider() {
  return (
    <div className="my-16 flex items-center gap-4">
      <div className="flex-1 border-t border-zinc-700" />
      <span className="text-xs text-zinc-500 uppercase tracking-widest">Full Text of the Accord</span>
      <div className="flex-1 border-t border-zinc-700" />
    </div>
  );
}
