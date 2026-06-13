"use client";

import { useState } from "react";
import {
  Checkbox, Switch, RadioGroup, Radio,
  TabGroup, TabList, Tab, TabPanels, TabPanel,
  Menu, MenuButton, MenuItems, MenuItem,
  Disclosure, DisclosureButton, DisclosurePanel,
  Combobox, ComboboxInput, ComboboxButton, ComboboxOptions, ComboboxOption,
  Listbox, ListboxButton, ListboxOptions, ListboxOption,
  Popover, PopoverButton, PopoverPanel,
  Dialog, DialogPanel, DialogBackdrop,
  Field, Fieldset, Label, Legend, Input, Select, Textarea, Description,
  Transition,
} from "@headlessui/react";
import { PreviewCode } from "./pkg/preview-code";
import { useSemanticSelection } from "./SemanticSelectionContext";
import type { SemanticClass } from "@styleguide-engine/lib/types";

function ChevronDown({ size = 12 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 12 7" fill="none" className="shrink-0">
      <path d="M1 1l5 5 5-5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function CheckIcon() {
  return (
    <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
      <path d="M1 4l2.5 2.5L9 1" stroke="white" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

// ─── Demos ───

function ButtonDemo({ scClass }: { scClass?: string }) {
  return (
    <div className="flex flex-col gap-[var(--space-1)] items-start">
      <button className={`btn${scClass ? ` ${scClass}` : ""}`}>Default</button>
      <div className="flex gap-[var(--space-1)]">
        <button className={`btn btn-sm${scClass ? ` ${scClass}` : ""}`}>Small</button>
        <button className={`btn btn-lg${scClass ? ` ${scClass}` : ""}`}>Large</button>
        <button className={`btn btn-outline btn-sm${scClass ? ` ${scClass}` : ""}`}>Outline</button>
      </div>
    </div>
  );
}

function CheckboxDemo({ scClass }: { scClass?: string }) {
  const items = [
    { id: "notifs", label: "Notifications" },
    { id: "dark", label: "Dark mode" },
    { id: "beta", label: "Beta access" },
  ];
  const [checked, setChecked] = useState<Record<string, boolean>>({ notifs: true, dark: false, beta: true });

  return (
    <div className="flex flex-col gap-[var(--space-1)]">
      {items.map((item) => (
        <Checkbox key={item.id} checked={checked[item.id]} onChange={(v) => setChecked((p) => ({ ...p, [item.id]: v }))} as="div" className={`hui checkbox-wrap${scClass ? ` ${scClass}` : ""}`}>
          <div className="checkbox-visual">{checked[item.id] && <CheckIcon />}</div>
          <span className="checkbox-label">{item.label}</span>
        </Checkbox>
      ))}
    </div>
  );
}

function SwitchDemo({ scClass }: { scClass?: string }) {
  const items = [
    { id: "wifi", label: "Wi-Fi" },
    { id: "bt", label: "Bluetooth" },
    { id: "vpn", label: "VPN" },
  ];
  const [states, setStates] = useState<Record<string, boolean>>({ wifi: true, bt: false, vpn: true });

  return (
    <div className="flex flex-col gap-[var(--space-1)]">
      {items.map((item) => (
        <Switch key={item.id} checked={states[item.id]} onChange={(v) => setStates((p) => ({ ...p, [item.id]: v }))} as="div" className={`hui switch-wrap${scClass ? ` ${scClass}` : ""}`}>
          <span className="switch-label">{item.label}</span>
          <div className="switch-track"><div className="switch-thumb" /></div>
        </Switch>
      ))}
    </div>
  );
}

function RadioDemo({ scClass }: { scClass?: string }) {
  const options = [
    { value: "read", label: "Read only" },
    { value: "edit", label: "Can edit" },
    { value: "admin", label: "Admin" },
  ];
  const [selected, setSelected] = useState("edit");

  return (
    <RadioGroup value={selected} onChange={setSelected}>
      <div className="flex flex-col gap-[var(--space-1)]">
        {options.map((opt) => (
          <Radio key={opt.value} value={opt.value} as="div" className={`hui radio-option${scClass ? ` ${scClass}` : ""}`}>
            <div className="radio-dot"><div className="radio-dot-inner" /></div>
            <span className="radio-label">{opt.label}</span>
          </Radio>
        ))}
      </div>
    </RadioGroup>
  );
}

function InputDemo({ scClass }: { scClass?: string }) {
  return (
    <div className="flex flex-col gap-[var(--space-1)]">
      <Field className={`field-group${scClass ? ` ${scClass}` : ""}`}>
        <Label>Email address</Label>
        <Input type="email" placeholder="you@example.com" className="field-input" />
      </Field>
      <Field className={`field-group${scClass ? ` ${scClass}` : ""}`}>
        <Label>Username</Label>
        <Input defaultValue="jsmith" className="field-input" />
      </Field>
    </div>
  );
}

function SelectDemo({ scClass }: { scClass?: string }) {
  return (
    <div className="flex flex-col gap-[var(--space-1)]">
      <Field className={`field-group${scClass ? ` ${scClass}` : ""}`}>
        <Label>Region</Label>
        <Select className="field-select">
          <option>US East</option><option>US West</option><option>EU West</option><option>AP South</option>
        </Select>
      </Field>
      <Field className={`field-group${scClass ? ` ${scClass}` : ""}`}>
        <Label>Timezone</Label>
        <Select className="field-select">
          <option>UTC-8 (Pacific)</option><option>UTC-5 (Eastern)</option><option>UTC+0 (London)</option>
        </Select>
      </Field>
    </div>
  );
}

function TextareaDemo({ scClass }: { scClass?: string }) {
  return (
    <Field className={`field-group${scClass ? ` ${scClass}` : ""}`}>
      <Label>Description</Label>
      <Textarea rows={3} placeholder="Write a short description…" className="field-textarea" />
      <Description className="field-hint">Max 280 characters</Description>
    </Field>
  );
}

function FieldsetDemo({ scClass }: { scClass?: string }) {
  return (
    <Fieldset className={`border-0 p-0 m-0 min-w-0 flex flex-col gap-[var(--space-1)]${scClass ? ` ${scClass}` : ""}`}>
      <Legend className="field-section-heading float-none w-auto mb-0 pb-1.5 border-b border-[var(--border)]">
        Personal Info
      </Legend>
      <Field className="field-group">
        <Label>First name</Label>
        <Input defaultValue="Jane" className="field-input" />
      </Field>
      <Field className="field-group">
        <Label>Last name</Label>
        <Input defaultValue="Smith" className="field-input" />
      </Field>
    </Fieldset>
  );
}

function TabsDemo({ scClass }: { scClass?: string }) {
  const tabs = [
    { label: "Overview", content: "Project summary and metrics." },
    { label: "Activity", content: "Recent commits and deploys." },
    { label: "Settings", content: "Repository configuration." },
  ];
  return (
    <TabGroup>
      <TabList className={`hui tab-list${scClass ? ` ${scClass}` : ""}`}>
        {tabs.map((t) => <Tab key={t.label} className="hui tab">{t.label}</Tab>)}
      </TabList>
      <TabPanels>
        {tabs.map((t) => <TabPanel key={t.label} className="hui tab-panel">{t.content}</TabPanel>)}
      </TabPanels>
    </TabGroup>
  );
}

function DisclosureDemo({ scClass }: { scClass?: string }) {
  const items = [
    { q: "What is included?", a: "Full source code, documentation, and 12 months of updates." },
    { q: "Refund policy?", a: "30-day money-back guarantee, no questions asked." },
  ];
  return (
    <div className="flex flex-col gap-[var(--space-1)]">
      {items.map((item) => (
        <Disclosure key={item.q}>
          <DisclosureButton className={`hui disclosure-btn${scClass ? ` ${scClass}` : ""}`}><span>{item.q}</span><ChevronDown size={12} /></DisclosureButton>
          <DisclosurePanel className="hui disclosure-panel">{item.a}</DisclosurePanel>
        </Disclosure>
      ))}
    </div>
  );
}

function MenuDemo({ scClass }: { scClass?: string }) {
  return (
    <div className="relative inline-block">
      <Menu>
        <MenuButton className={`hui menu-btn${scClass ? ` ${scClass}` : ""}`}>Actions <ChevronDown /></MenuButton>
        <MenuItems className={`hui menu-items${scClass ? ` ${scClass}` : ""}`}>
          <MenuItem as="div" className="hui menu-item">Edit</MenuItem>
          <MenuItem as="div" className="hui menu-item">Duplicate</MenuItem>
          <div className="hui menu-sep" />
          <MenuItem as="div" className="hui menu-item">Archive</MenuItem>
          <MenuItem as="div" className="hui menu-item" disabled>Delete</MenuItem>
        </MenuItems>
      </Menu>
    </div>
  );
}

function ComboboxDemo({ scClass }: { scClass?: string }) {
  const people = ["Alice Chen", "Bob Kim", "Carol Day", "Dave Park", "Eve Lam"];
  const [query, setQuery] = useState("");
  const [selected, setSelected] = useState(people[0]);
  const filtered = people.filter((p) => p.toLowerCase().includes(query.toLowerCase()));

  return (
    <Combobox value={selected} onChange={(v) => { if (v) setSelected(v); }}>
      <div className="hui combo-wrap">
        <ComboboxInput className={`hui combo-input${scClass ? ` ${scClass}` : ""}`} displayValue={(p: string) => p} onChange={(e) => setQuery(e.target.value)} placeholder="Search people…" />
        <ComboboxButton className={`hui combo-btn${scClass ? ` ${scClass}` : ""}`}><ChevronDown /></ComboboxButton>
        <ComboboxOptions className={`hui combo-options${scClass ? ` ${scClass}` : ""}`}>
          {filtered.length === 0 ? (
            <div className="px-2.5 py-2 text-sm text-[var(--text-muted)]">No results</div>
          ) : (
            filtered.map((p) => <ComboboxOption key={p} value={p} className="hui combo-option">{p}</ComboboxOption>)
          )}
        </ComboboxOptions>
      </div>
    </Combobox>
  );
}

function ListboxDemo({ scClass }: { scClass?: string }) {
  const options = ["Default", "Comfortable", "Compact", "Cozy"];
  const [selected, setSelected] = useState(options[0]);

  return (
    <Listbox value={selected} onChange={setSelected}>
      <div className="hui listbox-wrap">
        <ListboxButton className={`hui listbox-btn${scClass ? ` ${scClass}` : ""}`}>{selected}</ListboxButton>
        <ListboxOptions className={`hui listbox-options${scClass ? ` ${scClass}` : ""}`}>
          {options.map((opt) => <ListboxOption key={opt} value={opt} className="hui listbox-option">{opt}</ListboxOption>)}
        </ListboxOptions>
      </div>
    </Listbox>
  );
}

function PopoverDemo({ scClass }: { scClass?: string }) {
  return (
    <Popover className="relative inline-block">
      <PopoverButton className={`hui popover-btn${scClass ? ` ${scClass}` : ""}`}>More info ❓</PopoverButton>
      <PopoverPanel className={`hui popover-panel${scClass ? ` ${scClass}` : ""}`}>
        <div className="text-sm font-semibold text-text mb-1.5">Pro plan</div>
        <div className="text-sm text-[var(--text-muted)] leading-relaxed">
          Includes unlimited projects,<br />priority support, and team seats.
        </div>
      </PopoverPanel>
    </Popover>
  );
}

function DialogDemo({ scClass }: { scClass?: string }) {
  const [open, setOpen] = useState(false);

  return (
    <div>
      <button className={`hui menu-btn${scClass ? ` ${scClass}` : ""}`} onClick={() => setOpen(true)}>Open Dialog</button>
      <Dialog open={open} onClose={() => setOpen(false)}>
        <DialogBackdrop className="hui dialog-backdrop" />
        <div className="hui dialog-positioner">
          <DialogPanel className={`hui dialog-panel${scClass ? ` ${scClass}` : ""}`}>
            <div className="hui dialog-title">Confirm action</div>
            <div className="hui dialog-body">
              This will permanently delete the selected items. This action cannot be undone.
            </div>
            <div className="hui dialog-actions">
              <button className="btn btn-outline btn-sm" onClick={() => setOpen(false)}>Cancel</button>
              <button className="btn btn-sm danger" onClick={() => setOpen(false)}>Delete</button>
            </div>
          </DialogPanel>
        </div>
      </Dialog>
    </div>
  );
}

function TransitionDemo({ scClass }: { scClass?: string }) {
  const [show, setShow] = useState(true);

  return (
    <div className="flex flex-col gap-[var(--space-2)] items-start">
      <button className={`hui menu-btn${scClass ? ` ${scClass}` : ""}`} onClick={() => setShow((s) => !s)}>
        {show ? "Hide" : "Show"}
      </button>
      <Transition show={show}>
        <div
          className={`rounded-[var(--radius)] border border-[var(--border)] bg-[var(--surface)] px-[var(--space-3)] py-[var(--space-2)]${scClass ? ` ${scClass}` : ""}`}
          style={{
            transition: "opacity 200ms ease, transform 200ms ease",
            opacity: show ? 1 : 0,
            transform: show ? "translateY(0)" : "translateY(-4px)",
          }}
        >
          <div className="text-sm font-semibold text-text">Animated panel</div>
          <div className="text-sm text-[var(--text-muted)] mt-1">This element fades and slides in/out via Transition.</div>
        </div>
      </Transition>
    </div>
  );
}

// ─── Code strings (HTML that the classes produce) ───

const CODE: Record<string, string> = {
  Button: `<button class="btn">Default</button>
<button class="btn btn-sm">Small</button>
<button class="btn btn-lg">Large</button>
<button class="btn btn-outline btn-sm">Outline</button>`,

  Checkbox: `<div class="hui checkbox-wrap" data-checked>
  <div class="checkbox-visual">✓</div>
  <span class="checkbox-label">Notifications</span>
</div>`,

  Switch: `<div class="hui switch-wrap" data-checked>
  <span class="switch-label">Wi-Fi</span>
  <div class="switch-track">
    <div class="switch-thumb"></div>
  </div>
</div>`,

  "Radio Group": `<div class="hui radio-option" data-checked>
  <div class="radio-dot">
    <div class="radio-dot-inner"></div>
  </div>
  <span class="radio-label">Can edit</span>
</div>`,

  Input: `<div class="field-group">
  <label>Email address</label>
  <input type="email" class="field-input" placeholder="you@example.com" />
</div>`,

  Select: `<div class="field-group">
  <label>Region</label>
  <select class="field-select">
    <option>US East</option>
    <option>US West</option>
  </select>
</div>`,

  Textarea: `<div class="field-group">
  <label>Description</label>
  <textarea class="field-textarea" rows="3" placeholder="Write a short description…"></textarea>
  <p class="field-hint">Max 280 characters</p>
</div>`,

  Fieldset: `<fieldset>
  <legend class="field-section-heading">Personal Info</legend>
  <div class="field-group">
    <label>First name</label>
    <input class="field-input" value="Jane" />
  </div>
</fieldset>`,

  Tabs: `<div class="hui tab-list">
  <button class="hui tab" data-selected>Overview</button>
  <button class="hui tab">Activity</button>
  <button class="hui tab">Settings</button>
</div>
<div class="hui tab-panel">Project summary and metrics.</div>`,

  Disclosure: `<button class="hui disclosure-btn">
  <span>What is included?</span>
  <svg><!-- chevron --></svg>
</button>
<div class="hui disclosure-panel">
  Full source code, documentation, and 12 months of updates.
</div>`,

  "Dropdown Menu": `<button class="hui menu-btn">Actions ▾</button>
<div class="hui menu-items">
  <div class="hui menu-item">Edit</div>
  <div class="hui menu-item">Duplicate</div>
  <div class="hui menu-sep"></div>
  <div class="hui menu-item">Archive</div>
  <div class="hui menu-item" data-disabled>Delete</div>
</div>`,

  Combobox: `<div class="hui combo-wrap">
  <input class="hui combo-input" placeholder="Search people…" />
  <button class="hui combo-btn">▾</button>
  <div class="hui combo-options">
    <div class="hui combo-option">Alice Chen</div>
    <div class="hui combo-option">Bob Kim</div>
  </div>
</div>`,

  Listbox: `<div class="hui listbox-wrap">
  <button class="hui listbox-btn">Default</button>
  <div class="hui listbox-options">
    <div class="hui listbox-option" data-selected>Default</div>
    <div class="hui listbox-option">Comfortable</div>
  </div>
</div>`,

  Popover: `<button class="hui popover-btn">More info ❓</button>
<div class="hui popover-panel">
  <div>Pro plan</div>
  <div>Includes unlimited projects, priority support, and team seats.</div>
</div>`,

  Dialog: `<div class="hui dialog-backdrop"></div>
<div class="hui dialog-positioner">
  <div class="hui dialog-panel">
    <div class="hui dialog-title">Confirm action</div>
    <div class="hui dialog-body">This will permanently delete…</div>
    <div class="hui dialog-actions">
      <button class="btn btn-outline btn-sm">Cancel</button>
      <button class="btn btn-sm danger">Delete</button>
    </div>
  </div>
</div>`,

  Transition: `<!-- Transition wraps any element to animate enter/leave -->
<div data-transition
     data-enter="transition ease-out duration-200"
     data-enter-from="opacity-0 -translate-y-1"
     data-enter-to="opacity-100 translate-y-0"
     data-leave="transition ease-in duration-150"
     data-leave-from="opacity-100 translate-y-0"
     data-leave-to="opacity-0 -translate-y-1">
  <div>Animated panel</div>
  <div>This element fades and slides in/out via Transition.</div>
</div>`,
};

const JSX_CODE: Record<string, string> = {
  Button: `<button className="btn">Default</button>
<button className="btn btn-sm">Small</button>
<button className="btn btn-lg">Large</button>
<button className="btn btn-outline btn-sm">Outline</button>`,

  Checkbox: `import { Checkbox } from "@headlessui/react";

const [checked, setChecked] = useState(true);

<Checkbox checked={checked} onChange={setChecked} as="div" className="hui checkbox-wrap">
  <div className="checkbox-visual">{checked && <CheckIcon />}</div>
  <span className="checkbox-label">Notifications</span>
</Checkbox>`,

  Switch: `import { Switch } from "@headlessui/react";

const [enabled, setEnabled] = useState(true);

<Switch checked={enabled} onChange={setEnabled} as="div" className="hui switch-wrap">
  <span className="switch-label">Wi-Fi</span>
  <div className="switch-track">
    <div className="switch-thumb" />
  </div>
</Switch>`,

  "Radio Group": `import { RadioGroup, Radio } from "@headlessui/react";

const [selected, setSelected] = useState("edit");

<RadioGroup value={selected} onChange={setSelected}>
  <Radio value="read" as="div" className="hui radio-option">
    <div className="radio-dot"><div className="radio-dot-inner" /></div>
    <span className="radio-label">Read only</span>
  </Radio>
</RadioGroup>`,

  Input: `import { Field, Label, Input } from "@headlessui/react";

<Field className="field-group">
  <Label>Email address</Label>
  <Input type="email" className="field-input" placeholder="you@example.com" />
</Field>`,

  Select: `import { Field, Label, Select } from "@headlessui/react";

<Field className="field-group">
  <Label>Region</Label>
  <Select className="field-select">
    <option>US East</option>
    <option>US West</option>
  </Select>
</Field>`,

  Textarea: `import { Field, Label, Textarea, Description } from "@headlessui/react";

<Field className="field-group">
  <Label>Description</Label>
  <Textarea rows={3} className="field-textarea" placeholder="Write a short description…" />
  <Description className="field-hint">Max 280 characters</Description>
</Field>`,

  Fieldset: `import { Fieldset, Legend, Field, Label, Input } from "@headlessui/react";

<Fieldset>
  <Legend className="field-section-heading">Personal Info</Legend>
  <Field className="field-group">
    <Label>First name</Label>
    <Input defaultValue="Jane" className="field-input" />
  </Field>
</Fieldset>`,

  Tabs: `import { TabGroup, TabList, Tab, TabPanels, TabPanel } from "@headlessui/react";

<TabGroup>
  <TabList className="hui tab-list">
    <Tab className="hui tab">Overview</Tab>
    <Tab className="hui tab">Activity</Tab>
  </TabList>
  <TabPanels>
    <TabPanel className="hui tab-panel">Project summary and metrics.</TabPanel>
  </TabPanels>
</TabGroup>`,

  Disclosure: `import { Disclosure, DisclosureButton, DisclosurePanel } from "@headlessui/react";

<Disclosure>
  <DisclosureButton className="hui disclosure-btn">
    <span>What is included?</span>
    <ChevronDown />
  </DisclosureButton>
  <DisclosurePanel className="hui disclosure-panel">
    Full source code, documentation, and 12 months of updates.
  </DisclosurePanel>
</Disclosure>`,

  "Dropdown Menu": `import { Menu, MenuButton, MenuItems, MenuItem } from "@headlessui/react";

<Menu>
  <MenuButton className="hui menu-btn">Actions <ChevronDown /></MenuButton>
  <MenuItems className="hui menu-items">
    <MenuItem as="div" className="hui menu-item">Edit</MenuItem>
    <MenuItem as="div" className="hui menu-item">Duplicate</MenuItem>
    <div className="hui menu-sep" />
    <MenuItem as="div" className="hui menu-item">Archive</MenuItem>
  </MenuItems>
</Menu>`,

  Combobox: `import { Combobox, ComboboxInput, ComboboxButton, ComboboxOptions, ComboboxOption } from "@headlessui/react";

const [selected, setSelected] = useState("Alice Chen");

<Combobox value={selected} onChange={setSelected}>
  <div className="hui combo-wrap">
    <ComboboxInput className="hui combo-input" displayValue={(p) => p} />
    <ComboboxButton className="hui combo-btn"><ChevronDown /></ComboboxButton>
    <ComboboxOptions className="hui combo-options">
      <ComboboxOption value="Alice Chen" className="hui combo-option">Alice Chen</ComboboxOption>
    </ComboboxOptions>
  </div>
</Combobox>`,

  Listbox: `import { Listbox, ListboxButton, ListboxOptions, ListboxOption } from "@headlessui/react";

const [selected, setSelected] = useState("Default");

<Listbox value={selected} onChange={setSelected}>
  <div className="hui listbox-wrap">
    <ListboxButton className="hui listbox-btn">{selected}</ListboxButton>
    <ListboxOptions className="hui listbox-options">
      <ListboxOption value="Default" className="hui listbox-option">Default</ListboxOption>
    </ListboxOptions>
  </div>
</Listbox>`,

  Popover: `import { Popover, PopoverButton, PopoverPanel } from "@headlessui/react";

<Popover>
  <PopoverButton className="hui popover-btn">More info ❓</PopoverButton>
  <PopoverPanel className="hui popover-panel">
    <div>Pro plan</div>
    <div>Includes unlimited projects, priority support, and team seats.</div>
  </PopoverPanel>
</Popover>`,

  Dialog: `import { Dialog, DialogBackdrop, DialogPanel } from "@headlessui/react";

const [open, setOpen] = useState(false);

<Dialog open={open} onClose={() => setOpen(false)}>
  <DialogBackdrop className="hui dialog-backdrop" />
  <div className="hui dialog-positioner">
    <DialogPanel className="hui dialog-panel">
      <div className="hui dialog-title">Confirm action</div>
      <div className="hui dialog-body">This will permanently delete…</div>
      <div className="hui dialog-actions">
        <button className="btn btn-outline btn-sm" onClick={() => setOpen(false)}>Cancel</button>
        <button className="btn btn-sm danger" onClick={() => setOpen(false)}>Delete</button>
      </div>
    </DialogPanel>
  </div>
</Dialog>`,

  Transition: `import { Transition } from "@headlessui/react";

const [show, setShow] = useState(true);

<button onClick={() => setShow((s) => !s)}>
  {show ? "Hide" : "Show"}
</button>

<Transition
  show={show}
  enter="transition ease-out duration-200"
  enterFrom="opacity-0 -translate-y-1"
  enterTo="opacity-100 translate-y-0"
  leave="transition ease-in duration-150"
  leaveFrom="opacity-100 translate-y-0"
  leaveTo="opacity-0 -translate-y-1"
>
  <div>Animated panel</div>
  <div>This element fades and slides in/out via Transition.</div>
</Transition>`,
};

// ─── Cell ───

function Cell({ name, children }: { name: string; children: React.ReactNode }) {
  return (
    <div className="hui showcase-cell">
      <div className="showcase-cell-name">{name}</div>
      <PreviewCode html={CODE[name] || ""} jsx={JSX_CODE[name]}>
        <div className="showcase-cell-content">{children}</div>
      </PreviewCode>
    </div>
  );
}

// ─── Main ───

interface HUIShowcaseProps {
  semanticClasses?: SemanticClass[];
}

export function HUIShowcase({ semanticClasses }: HUIShowcaseProps = {}) {
  const { selected } = useSemanticSelection();
  const sc = semanticClasses?.find((c) => c.name === selected) || semanticClasses?.[0];
  const scClass = sc?.class;

  return (
    <div className={`hui showcase${scClass ? ` ${scClass}` : ""}`}>
      <div className="hui showcase-grid">
        <Cell name="Button"><ButtonDemo scClass={scClass} /></Cell>
        <Cell name="Checkbox"><CheckboxDemo scClass={scClass} /></Cell>
        <Cell name="Switch"><SwitchDemo scClass={scClass} /></Cell>
        <Cell name="Radio Group"><RadioDemo scClass={scClass} /></Cell>
        <Cell name="Input"><InputDemo scClass={scClass} /></Cell>
        <Cell name="Select"><SelectDemo scClass={scClass} /></Cell>
        <Cell name="Textarea"><TextareaDemo scClass={scClass} /></Cell>
        <Cell name="Fieldset"><FieldsetDemo scClass={scClass} /></Cell>
        <Cell name="Tabs"><TabsDemo scClass={scClass} /></Cell>
        <Cell name="Disclosure"><DisclosureDemo scClass={scClass} /></Cell>
        <Cell name="Dropdown Menu"><MenuDemo scClass={scClass} /></Cell>
        <Cell name="Combobox"><ComboboxDemo scClass={scClass} /></Cell>
        <Cell name="Listbox"><ListboxDemo scClass={scClass} /></Cell>
        <Cell name="Popover"><PopoverDemo scClass={scClass} /></Cell>
        <Cell name="Dialog"><DialogDemo scClass={scClass} /></Cell>
        <Cell name="Transition"><TransitionDemo scClass={scClass} /></Cell>
      </div>
    </div>
  );
}
