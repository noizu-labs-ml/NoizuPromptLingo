"use client";

import { heading } from "@/lib/ui/typography";
import {
  MagnifyingGlassIcon,
  ArrowRightIcon,
  PlusIcon,
  TrashIcon,
  InboxIcon,
  Bars3BottomLeftIcon,
  Squares2X2Icon,
  ListBulletIcon,
} from "@heroicons/react/24/outline";

import { Button } from "@/components/primitives/Button";
import { Input } from "@/components/primitives/Input";
import { Textarea } from "@/components/primitives/Textarea";
import { Select } from "@/components/primitives/Select";
import { FormField } from "@/components/primitives/FormField";
import { Badge } from "@/components/primitives/Badge";
import { Card } from "@/components/primitives/Card";
import { EmptyState } from "@/components/primitives/EmptyState";
import { DataTable } from "@/components/primitives/DataTable";
import { CodeBlock } from "@/components/primitives/CodeBlock";
import { Skeleton } from "@/components/primitives/Skeleton";
import { SkeletonGrid } from "@/components/primitives/SkeletonGrid";
import { Tag } from "@/components/primitives/Tag";
import { Segmented } from "@/components/primitives/Segmented";
import { Kbd } from "@/components/primitives/Kbd";
import { ComingSoonBanner } from "@/components/primitives/ComingSoonBanner";
import { StatTile } from "@/components/primitives/StatTile";

import { Preview } from "../_components/Preview";
import { useState } from "react";

function SubHeading({ children }: { children: React.ReactNode }) {
  return <h3 className={heading.heading}>{children}</h3>;
}

function Group({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <div className="flex flex-col gap-3">
      <SubHeading>{title}</SubHeading>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">{children}</div>
    </div>
  );
}

const sampleTableRows = [
  { id: "1", name: "Ping", category: "browser", calls: 128 },
  { id: "2", name: "ToolSearch", category: "meta", calls: 412 },
  { id: "3", name: "ToMarkdown", category: "browser", calls: 87 },
];

export function Primitives() {
  const [seg, setSeg] = useState<"list" | "grid" | "split">("list");

  return (
    <div className="flex flex-col gap-10">
      <h2 className={heading.title}>Primitives</h2>

      {/* Button */}
      <Group title="Button">
        <Preview label="variants" code={`<Button variant="primary">Primary</Button>`}>
          <Button variant="primary">Primary</Button>
          <Button variant="secondary">Secondary</Button>
          <Button variant="ghost">Ghost</Button>
          <Button variant="danger">Danger</Button>
          <Button variant="icon" aria-label="add">
            <PlusIcon className="h-4 w-4" />
          </Button>
        </Preview>
        <Preview label="sizes" code={`<Button size="sm" | "md" | "lg" />`}>
          <Button size="sm">Small</Button>
          <Button size="md">Medium</Button>
          <Button size="lg">Large</Button>
        </Preview>
        <Preview label="states" code={`<Button loading /> <Button disabled />`}>
          <Button loading>Loading</Button>
          <Button disabled>Disabled</Button>
        </Preview>
        <Preview
          label="with icons"
          code={`<Button leadingIcon={<PlusIcon />}>New</Button>`}
        >
          <Button leadingIcon={<PlusIcon className="h-4 w-4" />}>New</Button>
          <Button
            variant="secondary"
            trailingIcon={<ArrowRightIcon className="h-4 w-4" />}
          >
            Continue
          </Button>
          <Button
            variant="danger"
            leadingIcon={<TrashIcon className="h-4 w-4" />}
          >
            Delete
          </Button>
        </Preview>
      </Group>

      {/* Input */}
      <Group title="Input">
        <Preview label="default" code={`<Input placeholder="Name" />`}>
          <Input placeholder="Name" className="max-w-xs" />
        </Preview>
        <Preview
          label="with prefix"
          code={`<Input prefixEl={<MagnifyingGlassIcon />} />`}
        >
          <Input
            placeholder="Search…"
            className="max-w-xs"
            prefixEl={
              <MagnifyingGlassIcon className="h-4 w-4 text-subtle pointer-events-none absolute left-2.5 top-1/2 -translate-y-1/2" />
            }
          />
        </Preview>
        <Preview label="with suffix" code={`<Input suffixEl={<Kbd>⌘K</Kbd>} />`}>
          <Input
            placeholder="Search…"
            className="max-w-xs"
            suffixEl={
              <span className="pointer-events-none absolute right-2 top-1/2 -translate-y-1/2">
                <Kbd>⌘K</Kbd>
              </span>
            }
          />
        </Preview>
        <Preview label="error" code={`<Input error="Required" />`}>
          <Input defaultValue="bad" error="required" className="max-w-xs" />
        </Preview>
        <Preview label="disabled" code={`<Input disabled />`}>
          <Input disabled defaultValue="locked" className="max-w-xs" />
        </Preview>
        <Preview label="size sm" code={`<Input inputSize="sm" />`}>
          <Input inputSize="sm" placeholder="Small" className="max-w-xs" />
        </Preview>
      </Group>

      {/* Textarea */}
      <Group title="Textarea">
        <Preview label="default" code={`<Textarea rows={3} />`}>
          <Textarea placeholder="Notes…" rows={3} className="max-w-md" />
        </Preview>
        <Preview label="mono" code={`<Textarea mono />`}>
          <Textarea
            mono
            defaultValue={`{\n  "ok": true\n}`}
            rows={3}
            className="max-w-md"
          />
        </Preview>
        <Preview label="error" code={`<Textarea error="Required" />`}>
          <Textarea error rows={3} className="max-w-md" defaultValue="bad" />
        </Preview>
      </Group>

      {/* Select */}
      <Group title="Select">
        <Preview label="default" code={`<Select><option>…</option></Select>`}>
          <Select className="max-w-xs" defaultValue="a">
            <option value="a">Option A</option>
            <option value="b">Option B</option>
            <option value="c">Option C</option>
          </Select>
        </Preview>
        <Preview label="error" code={`<Select error />`}>
          <Select className="max-w-xs" error>
            <option>Invalid</option>
          </Select>
        </Preview>
        <Preview label="disabled" code={`<Select disabled />`}>
          <Select className="max-w-xs" disabled defaultValue="a">
            <option value="a">Locked</option>
          </Select>
        </Preview>
      </Group>

      {/* FormField */}
      <Group title="FormField">
        <Preview label="label + input" code={`<FormField label="Name"><Input/></FormField>`}>
          <div className="w-full max-w-sm">
            <FormField label="Name" htmlFor="sg-name">
              <Input id="sg-name" placeholder="e.g. npl-mcp" />
            </FormField>
          </div>
        </Preview>
        <Preview
          label="with helper"
          code={`<FormField helper="Lowercase only." />`}
        >
          <div className="w-full max-w-sm">
            <FormField label="Slug" helper="Lowercase letters and dashes only." htmlFor="sg-slug">
              <Input id="sg-slug" placeholder="my-slug" />
            </FormField>
          </div>
        </Preview>
        <Preview label="with error" code={`<FormField error="Required." />`}>
          <div className="w-full max-w-sm">
            <FormField label="Email" error="This field is required." htmlFor="sg-email">
              <Input id="sg-email" error />
            </FormField>
          </div>
        </Preview>
        <Preview label="required" code={`<FormField required />`}>
          <div className="w-full max-w-sm">
            <FormField label="Title" required htmlFor="sg-title">
              <Input id="sg-title" />
            </FormField>
          </div>
        </Preview>
      </Group>

      {/* Badge */}
      <Group title="Badge">
        <Preview label="variants (md)" code={`<Badge variant="success">ok</Badge>`}>
          <Badge>default</Badge>
          <Badge variant="success">success</Badge>
          <Badge variant="warning">warning</Badge>
          <Badge variant="danger">danger</Badge>
          <Badge variant="info">info</Badge>
          <Badge variant="accent">accent</Badge>
        </Preview>
        <Preview label="size sm" code={`<Badge size="sm" />`}>
          <Badge size="sm">default</Badge>
          <Badge size="sm" variant="success">success</Badge>
          <Badge size="sm" variant="warning">warning</Badge>
          <Badge size="sm" variant="danger">danger</Badge>
        </Preview>
        <Preview label="with dot" code={`<Badge dot variant="success">live</Badge>`}>
          <Badge dot variant="success">live</Badge>
          <Badge dot variant="warning">pending</Badge>
          <Badge dot variant="danger">failed</Badge>
        </Preview>
        <Preview label="dot variant" code={`<Badge variant="dot" />`}>
          <Badge variant="dot" />
          <span className="text-xs text-muted">bare status dot</span>
        </Preview>
      </Group>

      {/* Card */}
      <Group title="Card">
        <Preview label="surface 0 / normal" code={`<Card surface={0} />`}>
          <Card surface={0} className="w-full">surface-0</Card>
        </Preview>
        <Preview label="surface 1 / compact" code={`<Card surface={1} density="compact" />`}>
          <Card surface={1} density="compact" className="w-full">
            surface-1 compact
          </Card>
        </Preview>
        <Preview label="surface 2 / spacious" code={`<Card surface={2} density="spacious" />`}>
          <Card surface={2} density="spacious" className="w-full">
            surface-2 spacious
          </Card>
        </Preview>
        <Preview label="elevated / hoverable" code={`<Card surface="elevated" hoverable />`}>
          <Card surface="elevated" hoverable className="w-full">
            elevated + hover
          </Card>
        </Preview>
      </Group>

      {/* EmptyState */}
      <Group title="EmptyState">
        <Preview
          label="with icon + action"
          code={`<EmptyState icon={<InboxIcon />} title="No items" … />`}
          className="md:col-span-2"
        >
          <div className="w-full">
            <EmptyState
              icon={<InboxIcon />}
              title="No items yet"
              description="Nothing has been created. Start by adding your first entry."
              action={
                <Button leadingIcon={<PlusIcon className="h-4 w-4" />}>
                  New item
                </Button>
              }
            />
          </div>
        </Preview>
      </Group>

      {/* DataTable */}
      <Group title="DataTable">
        <Preview label="sample" className="md:col-span-2">
          <div className="w-full">
            <DataTable
              columns={[
                { key: "name", header: "Name" },
                { key: "category", header: "Category" },
                { key: "calls", header: "Calls", className: "text-right" },
              ]}
              rows={sampleTableRows}
              rowKey={(r) => r.id}
            />
          </div>
        </Preview>
      </Group>

      {/* CodeBlock */}
      <Group title="CodeBlock">
        <Preview label="markdown" className="md:col-span-2">
          <div className="w-full">
            <CodeBlock
              language="markdown"
              code={`# NPL Studio\n\nCompose structured prompts.`}
            />
          </div>
        </Preview>
        <Preview label="json" className="md:col-span-2">
          <div className="w-full">
            <CodeBlock
              language="json"
              code={`{\n  "tool": "Ping",\n  "args": { "url": "https://example.com" }\n}`}
            />
          </div>
        </Preview>
      </Group>

      {/* Skeleton / SkeletonGrid */}
      <Group title="Skeleton">
        <Preview label="single block" code={`<Skeleton width={200} height={16} />`}>
          <Skeleton width={200} height={16} />
        </Preview>
      </Group>
      <div className="flex flex-col gap-3">
        <SubHeading>SkeletonGrid</SubHeading>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          {(["card", "row", "tile", "table"] as const).map((shape) => (
            <Preview key={shape} label={`as="${shape}"`} code={`<SkeletonGrid as="${shape}" count={3} />`}>
              <div className="w-full">
                <SkeletonGrid as={shape} count={3} />
              </div>
            </Preview>
          ))}
        </div>
      </div>

      {/* Tag */}
      <Group title="Tag">
        <Preview label="inactive + active" code={`<Tag label="prompt" />`}>
          <Tag label="prompt" />
          <Tag label="active" active />
          <Tag label="removable" active onRemove={() => {}} />
        </Preview>
      </Group>

      {/* Segmented */}
      <Group title="Segmented">
        <Preview label="3 options with icons" code={`<Segmented options={…} />`}>
          <Segmented
            value={seg}
            onChange={(v) => setSeg(v)}
            aria-label="Layout"
            options={[
              { value: "list", label: "List", icon: <ListBulletIcon className="h-3.5 w-3.5" /> },
              { value: "grid", label: "Grid", icon: <Squares2X2Icon className="h-3.5 w-3.5" /> },
              { value: "split", label: "Split", icon: <Bars3BottomLeftIcon className="h-3.5 w-3.5" /> },
            ]}
          />
        </Preview>
      </Group>

      {/* Kbd */}
      <Group title="Kbd">
        <Preview label="single key" code={`<Kbd>K</Kbd>`}>
          <Kbd>K</Kbd>
        </Preview>
        <Preview label="chorded" code={`<Kbd>⌘</Kbd><Kbd>K</Kbd>`}>
          <span className="inline-flex items-center gap-1">
            <Kbd>⌘</Kbd>
            <span className="text-subtle text-xs">+</span>
            <Kbd>K</Kbd>
          </span>
        </Preview>
      </Group>

      {/* ComingSoonBanner */}
      <Group title="ComingSoonBanner">
        <Preview label="without prdRef" className="md:col-span-2">
          <div className="w-full">
            <ComingSoonBanner />
          </div>
        </Preview>
        <Preview label="with prdRef" className="md:col-span-2">
          <div className="w-full">
            <ComingSoonBanner
              title="Metrics"
              description="Dashboards will surface tool-call volume and error rates."
              prdRef="PRD-014"
            />
          </div>
        </Preview>
      </Group>

      {/* StatTile */}
      <Group title="StatTile">
        <Preview label="without delta">
          <div className="w-full max-w-xs">
            <StatTile label="Tasks" value={42} />
          </div>
        </Preview>
        <Preview label="trend up" code={`<StatTile delta={{ value: '+12', trend: 'up' }} />`}>
          <div className="w-full max-w-xs">
            <StatTile label="Sessions" value={128} delta={{ value: "+12", trend: "up" }} />
          </div>
        </Preview>
        <Preview label="trend down">
          <div className="w-full max-w-xs">
            <StatTile label="Errors" value={3} delta={{ value: "-2", trend: "down" }} />
          </div>
        </Preview>
        <Preview label="as link" code={`<StatTile href="/tasks" />`}>
          <div className="w-full max-w-xs">
            <StatTile label="Artifacts" value={9} href="/artifacts" />
          </div>
        </Preview>
      </Group>
    </div>
  );
}
