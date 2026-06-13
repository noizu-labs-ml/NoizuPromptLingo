'use client'

import { ChevronDownIcon } from '@heroicons/react/16/solid'
import { SelectHTMLAttributes } from 'react'

export interface SelectOption {
  value: string
  label: string
}

export interface SelectProps extends Omit<SelectHTMLAttributes<HTMLSelectElement>, 'className'> {
  label?: string
  options: SelectOption[]
  error?: string | boolean
  placeholder?: string
  disabled?: boolean
  className?: string
  id?: string
  name?: string
}

export function Select({
  label,
  options,
  error,
  placeholder,
  disabled,
  className = '',
  id,
  name,
  ...rest
}: SelectProps) {
  const selectClass = [
    'twp-select',
    error ? 'twp-select-error' : '',
    className,
  ]
    .filter(Boolean)
    .join(' ')

  return (
    <div>
      {label && (
        <label htmlFor={id} className="twp-select-label">
          {label}
        </label>
      )}
      <div className="twp-select-wrapper">
        <select
          id={id}
          name={name}
          disabled={disabled}
          className={selectClass}
          {...rest}
        >
          {placeholder && (
            <option value="" disabled>
              {placeholder}
            </option>
          )}
          {options.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>
        <span className="twp-select-icon" aria-hidden="true">
          <ChevronDownIcon />
        </span>
      </div>
      {error && typeof error === 'string' && (
        <p className="twp-input-error-msg">{error}</p>
      )}
    </div>
  )
}

const SHOWCASE_OPTIONS: SelectOption[] = [
  { value: 'us', label: 'United States' },
  { value: 'ca', label: 'Canada' },
  { value: 'mx', label: 'Mexico' },
  { value: 'gb', label: 'United Kingdom' },
]

export function SelectShowcase() {
  return (
    <div className="twp-showcase">
      <div className="twp-showcase-group">
        <span className="twp-showcase-label">default</span>
        <div className="twp-showcase-col" style={{ maxWidth: '20rem' }}>
          <Select
            id="select-default"
            label="Country"
            options={SHOWCASE_OPTIONS}
            placeholder="Select a country…"
            defaultValue=""
          />
        </div>
      </div>

      <div className="twp-showcase-group">
        <span className="twp-showcase-label">with value</span>
        <div className="twp-showcase-col" style={{ maxWidth: '20rem' }}>
          <Select
            id="select-value"
            label="Country"
            options={SHOWCASE_OPTIONS}
            defaultValue="ca"
          />
        </div>
      </div>

      <div className="twp-showcase-group">
        <span className="twp-showcase-label">error</span>
        <div className="twp-showcase-col" style={{ maxWidth: '20rem' }}>
          <Select
            id="select-error"
            label="Country"
            options={SHOWCASE_OPTIONS}
            placeholder="Select a country…"
            defaultValue=""
            error="Please select a country."
          />
        </div>
      </div>

      <div className="twp-showcase-group">
        <span className="twp-showcase-label">disabled</span>
        <div className="twp-showcase-col" style={{ maxWidth: '20rem' }}>
          <Select
            id="select-disabled"
            label="Country"
            options={SHOWCASE_OPTIONS}
            defaultValue="us"
            disabled
          />
        </div>
      </div>

      <div className="twp-showcase-group">
        <span className="twp-showcase-label">no label</span>
        <div className="twp-showcase-col" style={{ maxWidth: '20rem' }}>
          <Select
            id="select-nolabel"
            options={SHOWCASE_OPTIONS}
            placeholder="Select a country…"
            defaultValue=""
          />
        </div>
      </div>
    </div>
  )
}
