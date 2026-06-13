'use client'

import {
  Combobox as HeadlessCombobox,
  ComboboxButton,
  ComboboxInput,
  ComboboxOption,
  ComboboxOptions,
  Label,
} from '@headlessui/react'
import { CheckIcon, ChevronDownIcon } from '@heroicons/react/20/solid'
import { useState } from 'react'

export interface ComboboxOption {
  value: string
  label: string
}

export interface ComboboxProps {
  label?: string
  options: ComboboxOption[]
  value: string
  onChange: (value: string) => void
  placeholder?: string
  disabled?: boolean
  error?: string | boolean
  className?: string
}

export function Combobox({
  label,
  options,
  value,
  onChange,
  placeholder = 'Search…',
  disabled = false,
  error,
  className = '',
}: ComboboxProps) {
  const [query, setQuery] = useState('')

  const filtered =
    query === ''
      ? options
      : options.filter((o) =>
          o.label.toLowerCase().includes(query.toLowerCase()),
        )

  const selectedOption = options.find((o) => o.value === value) ?? null

  const inputClass = [
    'twp-combobox-input',
    error ? 'twp-combobox-input-error' : '',
  ]
    .filter(Boolean)
    .join(' ')

  return (
    <div className={className}>
      <HeadlessCombobox
        as="div"
        value={selectedOption}
        onChange={(opt: ComboboxOption | null) => {
          setQuery('')
          onChange(opt?.value ?? '')
        }}
        disabled={disabled}
      >
        {label && (
          <Label className="twp-input-label">{label}</Label>
        )}

        <div className="twp-combobox" style={{ marginTop: label ? 'var(--space-half)' : undefined }}>
          <ComboboxInput
            className={inputClass}
            placeholder={placeholder}
            displayValue={(opt: ComboboxOption | null) => opt?.label ?? ''}
            onChange={(e) => setQuery(e.target.value)}
            onBlur={() => setQuery('')}
          />
          <ComboboxButton className="twp-combobox-button" aria-label="Toggle options">
            <ChevronDownIcon aria-hidden="true" />
          </ComboboxButton>

          <ComboboxOptions className="twp-combobox-options">
            {filtered.length === 0 ? (
              <div className="twp-combobox-empty">No results</div>
            ) : (
              filtered.map((opt) => (
                <ComboboxOption
                  key={opt.value}
                  value={opt}
                  className={({ focus }: { focus: boolean }) =>
                    [
                      'twp-combobox-option',
                      focus ? 'twp-combobox-option-active' : '',
                    ]
                      .filter(Boolean)
                      .join(' ')
                  }
                >
                  {({ selected }: { selected: boolean }) => (
                    <>
                      <span className="flex-1 truncate">{opt.label}</span>
                      {selected && (
                        <CheckIcon className="twp-combobox-check" aria-hidden="true" />
                      )}
                    </>
                  )}
                </ComboboxOption>
              ))
            )}
          </ComboboxOptions>
        </div>

        {error && typeof error === 'string' && (
          <p className="twp-input-error-msg">{error}</p>
        )}
      </HeadlessCombobox>
    </div>
  )
}

// ─── Showcase ────────────────────────────────────────────────────────────────

const SHOWCASE_OPTIONS: ComboboxOption[] = [
  { value: 'react', label: 'React' },
  { value: 'vue', label: 'Vue' },
  { value: 'svelte', label: 'Svelte' },
  { value: 'angular', label: 'Angular' },
  { value: 'solid', label: 'SolidJS' },
  { value: 'qwik', label: 'Qwik' },
]

function ControlledCombobox(props: Omit<ComboboxProps, 'value' | 'onChange'> & { initialValue?: string }) {
  const [value, setValue] = useState(props.initialValue ?? '')
  return <Combobox {...props} value={value} onChange={setValue} />
}

export function ComboboxShowcase() {
  return (
    <div className="twp-showcase">
      <div className="twp-showcase-group">
        <span className="twp-showcase-label">basic</span>
        <div className="twp-showcase-col" style={{ maxWidth: '20rem' }}>
          <ControlledCombobox
            label="Framework"
            options={SHOWCASE_OPTIONS}
            placeholder="Search frameworks…"
          />
        </div>
      </div>

      <div className="twp-showcase-group">
        <span className="twp-showcase-label">with initial value</span>
        <div className="twp-showcase-col" style={{ maxWidth: '20rem' }}>
          <ControlledCombobox
            label="Framework"
            options={SHOWCASE_OPTIONS}
            initialValue="react"
          />
        </div>
      </div>

      <div className="twp-showcase-group">
        <span className="twp-showcase-label">error</span>
        <div className="twp-showcase-col" style={{ maxWidth: '20rem' }}>
          <ControlledCombobox
            label="Framework"
            options={SHOWCASE_OPTIONS}
            placeholder="Search frameworks…"
            error="Please select a framework."
          />
        </div>
      </div>

      <div className="twp-showcase-group">
        <span className="twp-showcase-label">disabled</span>
        <div className="twp-showcase-col" style={{ maxWidth: '20rem' }}>
          <ControlledCombobox
            label="Framework"
            options={SHOWCASE_OPTIONS}
            placeholder="Search frameworks…"
            disabled
          />
        </div>
      </div>
    </div>
  )
}
