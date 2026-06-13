// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

export function InputWithInlineLeadingAndTrailingAddOns11() {
  return (
    <div>
      <label htmlFor="price" className="block text-sm/6 font-medium text-gray-900 dark:text-white">
        Price
      </label>
      <div className="mt-2">
        <div className="flex items-center rounded-md bg-white px-3 outline-1 -outline-offset-1 outline-gray-300 focus-within:outline-2 focus-within:-outline-offset-2 focus-within:outline-indigo-600 dark:bg-white/5 dark:outline-white/10 dark:focus-within:outline-indigo-500">
          <div className="shrink-0 text-base text-gray-500 select-none sm:text-sm/6 dark:text-gray-400">$</div>
          <input
            id="price"
            name="price"
            type="text"
            placeholder="0.00"
            aria-describedby="price-currency"
            className="block min-w-0 grow bg-white py-1.5 pr-3 pl-1 text-base text-gray-900 placeholder:text-gray-400 focus:outline-none sm:text-sm/6 dark:bg-transparent dark:text-white dark:placeholder:text-gray-500"
          />
          <div
            id="price-currency"
            className="shrink-0 text-base text-gray-500 select-none sm:text-sm/6 dark:text-gray-400"
          >
            USD
          </div>
        </div>
      </div>
    </div>
  )
}
