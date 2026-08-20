"use client";

import { heading } from "@/lib/ui/typography";
import { Button } from "@/components/primitives/Button";
import { Card } from "@/components/primitives/Card";
import { Kbd } from "@/components/primitives/Kbd";
import { CodeBlock } from "@/components/primitives/CodeBlock";

export function Accessibility() {
  return (
    <div className="flex flex-col gap-6">
      <h2 className={heading.title}>Accessibility</h2>

      <Card>
        <h3 className={heading.heading}>Keyboard focus</h3>
        <p className="text-sm text-muted mt-2">
          Press <Kbd>Tab</Kbd> to focus the button below. Notice the violet
          outer ring — this is the unified focus indicator used on every
          interactive element.
        </p>
        <div className="mt-4">
          <Button>Focus me with Tab</Button>
        </div>
      </Card>

      <Card>
        <h3 className={heading.heading}>Focus ring utility</h3>
        <p className="text-sm text-muted mt-2">
          Every primitive applies the shared <code className="font-mono text-xs">focusRing</code> helper from{" "}
          <code className="font-mono text-xs">lib/utils/focusRing</code>. It produces a violet outer glow on{" "}
          <code className="font-mono text-xs">:focus-visible</code> so keyboard users see focus while mouse users don&apos;t.
        </p>
        <div className="mt-3">
          <CodeBlock
            language="ts"
            code={`import { focusRing } from "@/lib/utils/focusRing";\n\n<button className={clsx("...", focusRing)} />`}
          />
        </div>
      </Card>

      <Card>
        <h3 className={heading.heading}>Reduced motion</h3>
        <p className="text-sm text-muted mt-2">
          Shimmer animations on <code className="font-mono text-xs">Skeleton</code> and{" "}
          <code className="font-mono text-xs">SkeletonGrid</code> honor{" "}
          <code className="font-mono text-xs">prefers-reduced-motion</code>. Users with the OS
          setting enabled will see static placeholders instead of the shimmer
          gradient.
        </p>
      </Card>

      <Card>
        <h3 className={heading.heading}>Skip to content</h3>
        <p className="text-sm text-muted mt-2">
          Pressing <Kbd>Tab</Kbd> from the top of any page reveals a{" "}
          <em>Skip to content</em> link that jumps focus past the sidebar and
          top bar into <code className="font-mono text-xs">&lt;main&gt;</code>. The link is visually
          hidden until focused.
        </p>
      </Card>

      <Card>
        <h3 className={heading.heading}>ARIA live regions</h3>
        <p className="text-sm text-muted mt-2">
          The command palette (<Kbd>⌘</Kbd>
          <span className="text-subtle mx-1">+</span>
          <Kbd>K</Kbd>) announces the current result count via an ARIA live
          region so screen-reader users hear matches as they type.
        </p>
      </Card>
    </div>
  );
}
