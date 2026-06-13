// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function NarrowConstrainedWithPaddedContent05() {
  return (
    <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
      {/* We've used 3xl here, but feel free to try other max-widths based on your needs */}
      <div className="mx-auto max-w-3xl">{/* Content goes here */}</div>
    </div>
  )
}
