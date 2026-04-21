"use client";

import { heading } from "@/lib/ui/typography";
import { PageHeader } from "@/components/primitives/PageHeader";
import { FilterBar } from "@/components/composites/FilterBar";
import { DetailHeader } from "@/components/composites/DetailHeader";
import { ListRow } from "@/components/composites/ListRow";
import { SkeletonGrid } from "@/components/primitives/SkeletonGrid";
import { Badge } from "@/components/primitives/Badge";
import { Card } from "@/components/primitives/Card";
import { Input } from "@/components/primitives/Input";
import { Textarea } from "@/components/primitives/Textarea";
import { Select } from "@/components/primitives/Select";
import { FormField } from "@/components/primitives/FormField";
import { Button } from "@/components/primitives/Button";
import { SearchBox } from "@/components/forms/SearchBox";

function PatternFrame({
  label,
  children,
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div className="flex flex-col gap-2">
      <div className="text-label uppercase text-subtle">{label}</div>
      <div className="rounded-lg border border-border bg-surface-0 p-4 flex flex-col gap-4">
        {children}
      </div>
    </div>
  );
}

export function Patterns() {
  return (
    <div className="flex flex-col gap-8">
      <h2 className={heading.title}>Patterns</h2>

      {/* List page */}
      <PatternFrame label="List page layout">
        <PageHeader
          title="Tools"
          description="Every discoverable MCP tool with call stats."
        />
        <FilterBar
          search={<SearchBox value="" onChange={() => {}} placeholder="Search…" />}
          summary="12 tools"
        />
        <SkeletonGrid as="row" count={3} />
        <div className="flex flex-col gap-2">
          <ListRow actions={<Badge dot variant="success">live</Badge>}>
            <span className="text-sm font-medium">Ping</span>
          </ListRow>
          <ListRow actions={<Badge variant="info">idle</Badge>}>
            <span className="text-sm font-medium">ToolSearch</span>
          </ListRow>
          <ListRow actions={<Badge variant="warning">pending</Badge>}>
            <span className="text-sm font-medium">ToMarkdown</span>
          </ListRow>
        </div>
      </PatternFrame>

      {/* Detail page */}
      <PatternFrame label="Detail page layout">
        <DetailHeader
          backHref="/tools"
          breadcrumbs={[{ label: "Tools", href: "/tools" }, { label: "Ping" }]}
          title="Ping"
          description="Check whether a URL is reachable."
        />
        <div className="grid grid-cols-1 md:grid-cols-[1fr,16rem] gap-4">
          <Card density="spacious">
            <p className="text-sm text-muted">
              Primary content — description, recent calls, response samples.
            </p>
          </Card>
          <Card surface={1}>
            <div className="text-label uppercase text-subtle mb-2">Meta</div>
            <dl className="flex flex-col gap-1 text-xs text-muted">
              <div className="flex justify-between">
                <dt>Category</dt>
                <dd className="text-foreground">browser</dd>
              </div>
              <div className="flex justify-between">
                <dt>Calls</dt>
                <dd className="text-foreground tabular-nums">128</dd>
              </div>
            </dl>
          </Card>
        </div>
      </PatternFrame>

      {/* Form */}
      <PatternFrame label="Form composition">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <FormField label="Name" required htmlFor="pf-name">
            <Input id="pf-name" placeholder="e.g. Ping" />
          </FormField>
          <FormField label="Category" htmlFor="pf-cat">
            <Select id="pf-cat" defaultValue="browser">
              <option value="browser">browser</option>
              <option value="meta">meta</option>
              <option value="pm">pm</option>
            </Select>
          </FormField>
          <div className="sm:col-span-2">
            <FormField
              label="Description"
              helper="Markdown supported."
              htmlFor="pf-desc"
            >
              <Textarea id="pf-desc" rows={3} />
            </FormField>
          </div>
        </div>
        <div className="flex items-center justify-end gap-2">
          <Button variant="ghost">Cancel</Button>
          <Button>Save</Button>
        </div>
      </PatternFrame>
    </div>
  );
}
