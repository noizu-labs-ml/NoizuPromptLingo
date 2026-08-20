"use client";

import { useState } from "react";
import { heading } from "@/lib/ui/typography";
import { FilterBar } from "@/components/composites/FilterBar";
import { DetailHeader } from "@/components/composites/DetailHeader";
import { ListRow } from "@/components/composites/ListRow";
import { TabBar, TabPanel } from "@/components/composites/TabBar";
import { SearchBox } from "@/components/forms/SearchBox";
import { FilterListbox } from "@/components/forms/FilterListbox";
import { Badge } from "@/components/primitives/Badge";
import { Button } from "@/components/primitives/Button";
import { PlusIcon } from "@heroicons/react/24/outline";

import { Preview } from "../_components/Preview";

export function Composites() {
  const [search, setSearch] = useState("");
  const [categories, setCategories] = useState<string[]>([]);
  const hasActive = search.length > 0 || categories.length > 0;

  const [tab, setTab] = useState("overview");

  return (
    <div className="flex flex-col gap-8">
      <h2 className={heading.title}>Composites</h2>

      {/* FilterBar */}
      <div className="flex flex-col gap-3">
        <h3 className={heading.heading}>FilterBar</h3>
        <Preview label="search + filter + summary + clear">
          <div className="w-full">
            <FilterBar
              search={
                <SearchBox
                  value={search}
                  onChange={setSearch}
                  onClear={() => setSearch("")}
                  placeholder="Search tools…"
                />
              }
              filters={
                <FilterListbox
                  label="Category"
                  options={[
                    { value: "browser", label: "Browser" },
                    { value: "meta", label: "Meta" },
                    { value: "pm", label: "PM" },
                  ]}
                  selected={categories}
                  onChange={setCategories}
                />
              }
              summary="12 results"
              hasActive={hasActive}
              onClear={() => {
                setSearch("");
                setCategories([]);
              }}
            />
          </div>
        </Preview>
      </div>

      {/* DetailHeader */}
      <div className="flex flex-col gap-3">
        <h3 className={heading.heading}>DetailHeader</h3>
        <Preview label="breadcrumbs + back + actions">
          <div className="w-full">
            <DetailHeader
              backHref="/tools"
              backLabel="Back to tools"
              breadcrumbs={[
                { label: "Tools", href: "/tools" },
                { label: "Browser", href: "/tools?category=browser" },
                { label: "Ping" },
              ]}
              title="Ping"
              description="Check whether a URL is reachable."
              actions={
                <Button size="sm" leadingIcon={<PlusIcon className="h-4 w-4" />}>
                  Invoke
                </Button>
              }
            />
          </div>
        </Preview>
      </div>

      {/* ListRow */}
      <div className="flex flex-col gap-3">
        <h3 className={heading.heading}>ListRow</h3>
        <Preview label="link + onClick + selected">
          <div className="w-full flex flex-col gap-2">
            <ListRow
              href="/tools/ping"
              actions={<Badge dot variant="success">live</Badge>}
            >
              <div className="flex flex-col">
                <span className="text-sm font-medium text-foreground">Ping</span>
                <span className="text-xs text-subtle">browser · 128 calls</span>
              </div>
            </ListRow>
            <ListRow
              onClick={() => {}}
              selected
              actions={<Badge variant="warning">pending</Badge>}
            >
              <div className="flex flex-col">
                <span className="text-sm font-medium text-foreground">
                  ToolSearch (selected)
                </span>
                <span className="text-xs text-subtle">meta · 412 calls</span>
              </div>
            </ListRow>
            <ListRow actions={<Badge variant="info">idle</Badge>}>
              <div className="flex flex-col">
                <span className="text-sm font-medium text-foreground">
                  ToMarkdown (static)
                </span>
                <span className="text-xs text-subtle">browser · 87 calls</span>
              </div>
            </ListRow>
          </div>
        </Preview>
      </div>

      {/* TabBar */}
      <div className="flex flex-col gap-3">
        <h3 className={heading.heading}>TabBar</h3>
        <Preview label="4 tabs with counts">
          <div className="w-full">
            <TabBar
              tabs={[
                { id: "overview", label: "Overview" },
                { id: "calls", label: "Calls", badge: <Badge size="sm">128</Badge> },
                { id: "errors", label: "Errors", badge: <Badge size="sm" variant="danger">3</Badge> },
                { id: "meta", label: "Meta" },
              ]}
              value={tab}
              onChange={setTab}
            >
              <TabPanel>
                <p className="text-sm text-muted">Overview content.</p>
              </TabPanel>
              <TabPanel>
                <p className="text-sm text-muted">Calls content (128 entries).</p>
              </TabPanel>
              <TabPanel>
                <p className="text-sm text-muted">Errors content (3 entries).</p>
              </TabPanel>
              <TabPanel>
                <p className="text-sm text-muted">Meta content.</p>
              </TabPanel>
            </TabBar>
          </div>
        </Preview>
      </div>
    </div>
  );
}
